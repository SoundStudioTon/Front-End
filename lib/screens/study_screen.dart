// lib/study_screen.dart

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:audioplayers/audioplayers.dart';
import 'package:sound_studio/network/image_services.dart';
import 'package:sound_studio/network/noise_services.dart';
import 'package:sound_studio/network/user_services.dart';
import 'package:sound_studio/screens/study_result_screen.dart';

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
  bool isPaused = false;
  bool isUploading = false;
  final ImageApi _imageApi =
      ImageApi(baseUrl: 'http://sound-studio.kro.kr:8080');
  String? _latestAiResponse;
  int _seconds = 0; // 타이머를 위한 변수 추가

  final Map<String, int> audioAssetToNumber = {
    "audio/pink_noise.mp3": 1,
    "audio/green_noise.mp3": 2,
    "audio/white_noise.mp3": 3,
  };

  AudioPlayer? _audioPlayer;

  String formatTime() {
    int hours = _seconds ~/ 3600;
    int minutes = (_seconds % 3600) ~/ 60;
    int seconds = _seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    initCamera();
    _audioPlayer = AudioPlayer();
  }

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras == null || cameras!.isEmpty) {
        throw Exception('카메라를 찾을 수 없습니다.');
      }

      _cameraController = CameraController(
        isRearCameraSelected ? cameras![0] : cameras![1],
        ResolutionPreset.high,
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

  void handleStudyTimer(Timer timer) async {
    if (!mounted) return; // mounted 체크 추가

    if (!isPaused) {
      // 일시정지가 아닐 때만 시간 증가
      setState(() {
        _seconds++;
      });
    }

    if (isUploading) return;
    setState(() {
      isUploading = true;
    });

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      File file = File(imageFile.path);

      Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: 60,
        minWidth: 800,
        minHeight: 600,
      );

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
      // 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('에러 발생: $e')),
        );
      }
    } finally {
      if (mounted) {
        // mounted 체크 추가
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  void startStudying() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카메라가 초기화되지 않았습니다.')),
      );
      return;
    }

    String? accessToken = await AuthService.storage.read(key: 'accessToken');
    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    int noiseNumber = await getNoiseNumber(accessToken);
    if (noiseNumber == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('소음 데이터를 가져오지 못했습니다.')),
      );
      return;
    }

    String? audioAsset;
    audioAssetToNumber.forEach((key, value) {
      if (value == noiseNumber) {
        audioAsset = key;
      }
    });

    if (audioAsset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('해당하는 소음 데이터가 없습니다.')),
      );
      return;
    }

    _audioPlayer?.setReleaseMode(ReleaseMode.loop);

    try {
      await _audioPlayer?.play(AssetSource(audioAsset!));
      _timer = Timer.periodic(Duration(seconds: 1), handleStudyTimer);

      setState(() {
        isStudying = true;
        isPaused = false;
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오디오를 재생할 수 없습니다: $e')),
      );
    }
  }

  void stopStudying() {
    // 타이머와 오디오 정지
    _timer?.cancel();
    _audioPlayer?.stop();

    // mounted 체크 추가
    if (!mounted) return;

    // 화면 이동 전에 isStudying 상태 변경
    setState(() {
      isStudying = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StudyResultScreen(
            // 필요한 다른 결과 데이터들 전달
            ),
      ),
    );
  }

  String _getEmoji(String response) {
    switch (response) {
      case "집중함":
        return "😊"; // 집중하는 표정
      case "집중하지 않음":
        return "😑"; // 집중하지 않는 표정
      case "졸음":
        return "😴"; // 졸린 표정
      case "0":
        return "❓"; // 얼굴 인식 실패
      default:
        return "❓";
    }
  }

  Color _getBackgroundColor(String response) {
    switch (response) {
      case "집중함":
        return Colors.green.withOpacity(0.2);
      case "집중하지 않음":
        return Colors.orange.withOpacity(0.2);
      case "졸음":
        return Colors.red.withOpacity(0.2);
      case "0":
        return Colors.grey.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  String _getMessage(String response) {
    switch (response) {
      case "집중함":
        return "집중하고 있어요!";
      case "집중하지 않음":
        return "집중이 필요해요";
      case "졸음":
        return "졸음이 와요";
      case "0":
        return "얼굴이 인식되지 않았어요";
      default:
        return response;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer?.dispose();
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
              Stack(
                children: [
                  Container(
                    width: screenWidth,
                    height: screenWidth * (4 / 3),
                    color: Colors.black,
                    child: _cameraController != null &&
                            _cameraController!.value.isInitialized
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..scale(-1.0, 1.0),
                            child: AspectRatio(
                              aspectRatio: 3 / 4,
                              child: CameraPreview(_cameraController!),
                            ),
                          )
                        : Center(child: CircularProgressIndicator()),
                  ),
                  Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Center(
                        child: Text(
                          formatTime(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 3.0,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              if (isStudying)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isPaused = !isPaused;
                            if (isPaused) {
                              _audioPlayer?.pause();
                            } else {
                              _audioPlayer?.resume();
                            }
                          });
                        },
                        child: Text(
                          isPaused ? '재개하기' : '일시정지',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isPaused ? Colors.green : Colors.orange,
                          minimumSize: Size(120, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: stopStudying,
                        child: Text(
                          '학습 중단하기',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          minimumSize: Size(120, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ElevatedButton(
                  onPressed: startStudying,
                  child: Text(
                    '학습 시작하기',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
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
                child: isStudying
                    ? (_latestAiResponse != null
                        ? Center(
                            child: ListTile(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16),
                              horizontalTitleGap: 2,
                              title: Container(
                                width: 40,
                                height: 80,
                                child: Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        _getEmoji(_latestAiResponse!),
                                        style: TextStyle(fontSize: 24),
                                      ),
                                      Text(
                                        _getMessage(_latestAiResponse!),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(child: Text('AI 응답이 없습니다.')))
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.face,
                              size: 50,
                              color: Colors.blue,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "얼굴이 잘 보이게 카메라를 위치시켜주세요!",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
              ),
              SizedBox(height: screenHeight * 0.01),
            ],
          );
        },
      ),
    );
  }
}
