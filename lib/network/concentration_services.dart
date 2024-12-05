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
      final response = await dio.post(
        '/sendConcentration',
        data: {
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'userId': userId,
        },
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200) {
        // JSON 배열로 받았다고 가정
        List<dynamic> responseData = response.data;
        return ConcentrationResponse.parseJsonArray(responseData);
      } else {
        throw Exception('서버 응답 오류');
      }
    } catch (e) {
      throw Exception('집중도 정보 받기 실패: $e');
    }
  }

  Future<List<ConcentrationResponse>> getDayConcentartionData(
      DateTime dateTime) async {
    int? userId = await getUserId();
    DateTime selectedDateTime = dateTime;
    DateTime startTime = DateTime(
        selectedDateTime.year, selectedDateTime.month, selectedDateTime.day);
    DateTime endTime = DateTime(selectedDateTime.year, selectedDateTime.month,
        selectedDateTime.day, 23, 59, 59, 999);

    if (userId != null) {
      return await recevieConcentration(userId, startTime, endTime);
    }

    return []; // userId가 null인 경우 빈 리스트 반환
  }

  Future<List<ConcentrationResponse>> getMonthConcentrationData(
      DateTime dateTime) async {
    int? userId = await getUserId();
    DateTime selectedDateTime = dateTime;
    DateTime startTime =
        DateTime(selectedDateTime.year, selectedDateTime.month);
    DateTime endTime = DateTime(
        selectedDateTime.year, selectedDateTime.month + 1, 0, 23, 59, 59, 999);
    if (userId != null) {
      return await recevieConcentration(userId, startTime, endTime);
    }

    return []; // userId가 null인 경우 빈 리스트 반환
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
