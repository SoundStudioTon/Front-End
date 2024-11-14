import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ImageApi {
  final Dio _dio;

  ImageApi({String baseUrl = 'http://sound-studio.kro.kr:8080'})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: Duration(milliseconds: 10000),
          receiveTimeout: Duration(milliseconds: 50000),
        ));

  /// `previewImage` API 호출
  ///
  /// **주의:** Spring의 `/previewImage`는 GET 요청으로 MultipartFile을 받도록 설계되어 있습니다.
  /// 일반적으로 GET 요청은 본문을 포함하지 않으므로, 파일을 Base64로 인코딩하여 쿼리 파라미터로 전송합니다.
  /// 서버 측에서도 이에 맞게 처리해야 합니다.
  Future<Uint8List> previewImage(Uint8List fileBytes, String fileName) async {
    try {
      // 파일을 Base64로 인코딩
      String base64File = base64Encode(fileBytes);

      // GET 요청 시 파일을 쿼리 파라미터로 전송
      final response = await _dio.get(
        '/previewImage',
        queryParameters: {
          'file': base64File,
          // 'fileName': fileName, // 파일명을 별도로 전송할 필요가 있을 경우 추가
        },
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Content-Type': 'application/octet-stream',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Uint8List;
      } else {
        throw Exception('이미지 미리보기 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('이미지 미리보기 에러: $e');
    }
  }

  /// `uploadImage` API 호출
  Future<String> uploadImage(Uint8List fileBytes, String fileName) async {
    try {
      // 파일의 MIME 타입을 추측
      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
      final mimeTypeParts = mimeType.split('/');

      // Multipart 파일 생성
      MultipartFile multipartFile = MultipartFile.fromBytes(
        fileBytes,
        filename: fileName,
        contentType: MediaType(mimeTypeParts[0], mimeTypeParts[1]),
      );

      // FormData 생성
      FormData formData = FormData.fromMap({
        'file': multipartFile,
      });

      // POST 요청 전송
      final response = await _dio.post(
        '/uploadImage',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        // AI 서버의 응답을 그대로 반환
        return response.data.toString();
      } else {
        throw Exception('이미지 업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('이미지 업로드 에러: $e');
    }
  }

  /// `sendToFront` API 호출
  Future<String> sendToFront(Map<String, dynamic> focusData) async {
    try {
      // JSON 직렬화
      String focusDataJson = jsonEncode(focusData);

      // POST 요청 전송
      final response = await _dio.post(
        '/sendToFront',
        data: focusDataJson,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // 서버로부터 받은 JSON 문자열 반환
        return response.data.toString();
      } else {
        throw Exception('프론트로 전송 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('프론트로 전송 에러: $e');
    }
  }
}
