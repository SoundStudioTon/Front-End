import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool> signup(String email, String nickname, String password) async {
  try {
    Dio dio = Dio();
    final response = await dio.post(
      'http://localhost:8080/userreg',
      data: {
        'email': email,
        'name': nickname,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  } catch (e) {
    print('Signup error: $e');
    return false;
  }
}

Future<bool?> login(String email, String password) async {
  try {
    Dio dio = Dio();
    final response = await dio.post(
      'http://sound-studio.kro.kr:8080/api/login',
      data: {
        'email': email,
        'password': password,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    print('status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final loginResponse = UserLoginResponse.fromJson(response.data);

      // 로그인 성공시 토큰 저장
      await AuthService.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
        email: loginResponse.email,
        name: loginResponse.name,
      );

      return true;
    }
    return false;
  } catch (e) {
    print('Login error: $e');
    return false;
  }
}

Future<bool> logout(String refreshToken) async {
  try {
    Dio dio = Dio();
    final response = await dio.delete(
      'http://sound-studio.kro.kr:8080/logout',
      data: {
        'refreshToken': refreshToken,
      },
    );

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  } catch (e) {
    Fluttertoast.showToast(msg: "로그아웃 중 오류가 발생했습니다.");
    print('Logout error: $e');
    return false;
  }
}

class UserLoginResponse {
  final String accessToken;
  final String refreshToken;
  final String email;
  final String name;

  UserLoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.email,
    required this.name,
  });

  factory UserLoginResponse.fromJson(Map<String, dynamic> json) {
    return UserLoginResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      email: json['email'],
      name: json['name'],
    );
  }
}

Future<UserLoginResponse?> refreshAccessToken(String refreshToken) async {
  try {
    Dio dio = Dio();
    final response = await dio.post(
      'http://sound-studio.kro.kr:8080/refreshToken',
      data: {
        'refreshToken': refreshToken,
      },
    );

    if (response.statusCode == 200) {
      return UserLoginResponse.fromJson(response.data);
    }
    return null;
  } catch (e) {
    if (e is DioException) {
      if (e.response?.data['message'] == 'Refresh token not found') {
        Fluttertoast.showToast(msg: "리프레시 토큰이 유효하지 않습니다.");
      } else if (e.response?.data['message'] == 'Member not found') {
        Fluttertoast.showToast(msg: "사용자를 찾을 수 없습니다.");
      } else {
        Fluttertoast.showToast(msg: "토큰 갱신 중 오류가 발생했습니다.");
      }
    }
    print('Token refresh error: $e');
    return null;
  }
}

class AuthService {
  static const storage = FlutterSecureStorage();

  // 토큰 저장
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String email,
    required String name,
  }) async {
    await storage.write(key: 'accessToken', value: accessToken);
    await storage.write(key: 'refreshToken', value: refreshToken);
    await storage.write(key: 'email', value: email);
    await storage.write(key: 'userName', value: name);
  }

  // 토큰 삭제
  static Future<void> clearTokens() async {
    await storage.deleteAll();
  }

  // 자동 로그인 체크
  static Future<bool> autoLogin() async {
    try {
      final refreshToken = await storage.read(key: 'refreshToken');

      if (refreshToken == null) {
        return false;
      }

      // refreshToken으로 새로운 accessToken 발급
      final response = await refreshAccessToken(refreshToken);

      if (response != null) {
        // 새로운 토큰 저장
        await saveTokens(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          email: response.email,
          name: response.name,
        );
        return true;
      }

      // 토큰 갱신 실패시 저장된 정보 삭제
      await clearTokens();
      return false;
    } catch (e) {
      print('Auto login error: $e');
      return false;
    }
  }
}
