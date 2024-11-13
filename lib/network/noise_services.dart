import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool> checkUserNoiseData(String accessToken) async {
  try {
    Dio dio = Dio();
    final response =
        await dio.post('http://sound-studio.kro.kr:8080/api/noise/isnoisethere',
            data: {
              'AccessToken': accessToken,
            },
            options: Options(contentType: Headers.formUrlEncodedContentType));

    if (response.statusCode == 200) {
      return response.data as bool;
    }
    return false;
  } catch (e) {
    if (e is DioException) {
      if (e.response?.data['message'] == '유효하지 않은 액세스 토큰입니다') {
        Fluttertoast.showToast(
          msg: "토큰이 만료되었습니다. 다시 로그인해주세요.",
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
      } else if (e.response?.data['message'] == '사용자를 찾을 수 없습니다') {
        Fluttertoast.showToast(
          msg: "사용자 정보를 찾을 수 없습니다.",
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
      }
    }
    print('Check noise data error: $e');
    return false;
  }
}

Future<bool> saveFirstNoiseData(String accessToken, int noiseNumber) async {
  try {
    Dio dio = Dio();
    final response = await dio.post(
      'http://sound-studio.kro.kr:8080/api/noise/savefirstnoise',
      queryParameters: {
        'AccessToken': accessToken,
        'noiseNumber': noiseNumber,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "소음 데이터가 저장되었습니다.",
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
      return true;
    }
    return false;
  } catch (e) {
    if (e is DioException) {
      if (e.response?.data['message'] == '유효하지 않은 액세스 토큰입니다') {
        Fluttertoast.showToast(
          msg: "토큰이 만료되었습니다. 다시 로그인해주세요.",
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
      } else if (e.response?.data['message'] == '사용자를 찾을 수 없습니다') {
        Fluttertoast.showToast(
          msg: "사용자 정보를 찾을 수 없습니다.",
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
      }
    }
    print('Save first noise data error: $e');
    return false;
  }
}
