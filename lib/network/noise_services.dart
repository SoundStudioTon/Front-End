import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sound_studio/network/user_services.dart';

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

Future<int> getNoiseNumber(String accessToken) async {
  try {
    Dio dio = Dio();
    final response = await dio.post(
      'http://sound-studio.kro.kr:8080/api/noise/getnoisenumber',
      queryParameters: {
        'AccessToken': accessToken,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      print('Error: ${response.statusCode}');
      return -1;
    }
  } catch (e) {
    print('Exception occurred: $e');
    return -1;
  }
}

Future<String> noiseTransformation(String accesssToken, int noiseNumber) async {
  try {
    Dio dio = Dio(BaseOptions(
      connectTimeout: Duration(milliseconds: 1000),
      receiveTimeout: Duration(milliseconds: 5000),
    ));
    final response = await dio.post(
        'http://sound-studio.kro.kr:8080/api/noise/send',
        queryParameters: {
          "AccessToken": accesssToken,
          "noiseNumber": noiseNumber
        });

    if (response.statusCode == 200) {
      final responseData = response.data;
      return responseData;
    } else {
      print('Error : ${response.statusCode}');
      return "Error";
    }
  } catch (e) {
    print("Exception occured : ${e}");
    return "Error";
  }
}

Future<String> saveAudioFile(String base64audio) async {
  try {
    List<int> audioBytes = base64Decode(base64audio);

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = '${tempDir.path}/transform_audio.mp3';
    return tempPath;
  } catch (e) {
    print("Exception : ${e}");
    return "Error";
  }
}

Future<void> sendReward(int reward) async {
  String? accessToken = await AuthService.storage.read(key: "AccessToken");
  if (accessToken != null) return;
  Dio dio = Dio();
  try {
    final response = await dio.post(
        'http://sound-studio.kro.kr:8080/api/noise/send',
        queryParameters: {"AccessToken": accessToken, "reward": reward});
    if (response.statusCode == 200) {
      print('Success');
    } else {
      print(response.statusCode);
    }
  } catch (e) {
    print(e);
  }
}
