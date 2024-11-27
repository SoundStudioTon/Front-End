// lib/study_screen.dart

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // 패키지 추가
import 'package:path/path.dart' as path;
import 'package:sound_studio/network/image_services.dart';
import 'package:sound_studio/network/user_services.dart';

class StudyScreen extends StatefulWidget {
  @override
  _StudyScreenState createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool isRearCameraSelected = false;
  Timer? _timer;
  bool isStudying = false;
  bool isUploading = false;
  final ImageApi _imageApi = ImageApi(
      baseUrl: 'http://sound-studio.kro.kr:8080'); // 실제 서버의 Base URL로 변경

  String? _latestAiResponse;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras == null || cameras!.isEmpty) {
        throw Exception('카메라를 찾을 수 없습니다.');
      }

      _cameraController = CameraController(
        isRearCameraSelected ? cameras![0] : cameras![1],
        ResolutionPreset.high, // 해상도를 조정하여 비율에 맞게 설정
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      setState(() {});
    } catch (e) {
      print('카메라 초기화 에러: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카메라 초기화 에러: $e')),
      );
    }
  }

  void toggleCameraDirection() {
    setState(() {
      isRearCameraSelected = !isRearCameraSelected;
    });
    initCamera();
  }

  void startStudying() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print('카메라가 초기화되지 않았습니다.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카메라가 초기화되지 않았습니다.')),
      );
      return;
    }

    if (isStudying) {
      _timer?.cancel();
      setState(() {
        isStudying = false;
      });
    } else {
      _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) async {
        if (isUploading) return;
        setState(() {
          isUploading = true;
        });

        try {
          final XFile imageFile = await _cameraController!.takePicture();
          File file = File(imageFile.path);

          // 이미지 압축 추가
          Uint8List? compressedBytes =
              await FlutterImageCompress.compressWithFile(
            file.absolute.path,
            quality: 60, // 품질을 0~100 사이로 설정
            minWidth: 800, // 필요에 따라 해상도 조절
            minHeight: 600,
          );

          // 압축 결과가 null인지 확인
          if (compressedBytes == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('이미지 압축에 실패했습니다.')),
            );
            setState(() {
              isUploading = false;
            });
            return;
          }

          String fileName = path.basename(file.path);

          int? userId = await getUserId();
          if (userId != null) {
            String aiResponse =
                await _imageApi.uploadImage(userId, compressedBytes, fileName);
            setState(() {
              _latestAiResponse = aiResponse;
            });
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('에러 발생: $e')),
          );
        } finally {
          setState(() {
            isUploading = false;
          });
        }
      });

      setState(() {
        isStudying = true;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenHeight = constraints.maxHeight;
          double screenWidth = constraints.maxWidth;

          return Column(
            children: [
              Container(
                width: screenWidth,
                height: screenWidth * (4 / 3), // 3:4 비율로 설정
                color: Colors.black,
                child: _cameraController != null &&
                        _cameraController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: 3 / 4, // 3:4 비율로 설정
                        child: CameraPreview(_cameraController!),
                      )
                    : Center(child: CircularProgressIndicator()),
              ),
              SizedBox(height: screenHeight * 0.03),
              isStudying
                  ? Container(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      height: 100,
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: startStudying,
                            child: Text(
                              '학습 중지하기',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              minimumSize: Size(150, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: startStudying,
                      child: Text(
                        '학습 시작하기',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54,
                        minimumSize: Size(screenWidth * 0.61, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      ),
                    ),
              SizedBox(height: screenHeight * 0.01),
              Expanded(
                child: _latestAiResponse != null
                    ? ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text(_latestAiResponse!),
                      )
                    : Center(child: Text('AI 응답이 없습니다.')),
              ),
              SizedBox(height: screenHeight * 0.01),
            ],
          );
        },
      ),
    );
  }
}
