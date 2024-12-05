import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:sound_studio/network/user_services.dart';

class ConcentrationServices {
  final Dio dio;
  ConcentrationServices({String baseUrl = 'http://sound-studio.kro.kr:8080'})
      : dio = Dio(BaseOptions(baseUrl: baseUrl));

  Future<List<ConcentrationResponse>> recevieConcentration(
      int userId, DateTime startTime, DateTime endTime) async {
    try {
      // ISO 8601 형식으로 날짜를 변환하되, 밀리초를 제거
      String formattedStartTime = startTime.toIso8601String().split('.')[0];
      String formattedEndTime = endTime.toIso8601String().split('.')[0];

      final response = await dio.post(
        '/sendConcentration',
        queryParameters: {
          // body 대신 queryParameters 사용
          'startTime': formattedStartTime,
          'endTime': formattedEndTime,
          'userId': userId,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> responseData = response.data;
        return ConcentrationResponse.parseJsonArray(responseData);
      } else if (response.statusCode == 204) {
        // 데이터가 없는 경우
        return [];
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception details: $e');
      throw Exception('집중도 정보 받기 실패: $e');
    }
  }

  Future<List<ConcentrationResponse>> getMonthConcentrationData(
      DateTime dateTime) async {
    int? userId = await getUserId();
    DateTime selectedDateTime = dateTime;

    // 월의 시작과 끝 날짜 설정
    DateTime startTime =
        DateTime(selectedDateTime.year, selectedDateTime.month, 1);
    DateTime endTime = DateTime(
        selectedDateTime.year, selectedDateTime.month + 1, 0, 23, 59, 59);

    if (userId != null) {
      return await recevieConcentration(userId, startTime, endTime);
    }

    return [];
  }

  Future<List<ConcentrationResponse>> getDayConcentartionData(
      DateTime dateTime) async {
    int? userId = await getUserId();

    // 해당 날짜의 시작과 끝 시간 설정
    DateTime startTime = DateTime(dateTime.year, dateTime.month, dateTime.day);
    DateTime endTime =
        DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);

    if (userId != null) {
      return await recevieConcentration(userId, startTime, endTime);
    }

    return [];
  }
}

class ConcentrationResponse {
  int id;
  DateTime date;
  String value;

  ConcentrationResponse(
      {required this.id, required this.date, required this.value});

  factory ConcentrationResponse.fromJson(Map<String, dynamic> json) {
    return ConcentrationResponse(
        id: json['id'],
        date: DateTime.parse(json['date']),
        value: json['value']);
  }

  // 정적 메서드로 변경
  static List<ConcentrationResponse> parseJsonArray(List<dynamic> jsonArray) {
    return jsonArray
        .map((json) => ConcentrationResponse.fromJson(json))
        .toList();
  }
}
