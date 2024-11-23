import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:sound_studio/network/image_services.dart';

// Define the different states of the quiz
enum QuizState { InitialCountdown, QuizPhase, InterPhaseCountdown, Finished }

class MathQuizScreen extends StatefulWidget {
  final int difficulty; // 난이도를 입력받음
  const MathQuizScreen({super.key, required this.difficulty});

  @override
  _MathQuizScreenState createState() => _MathQuizScreenState();
}

class _MathQuizScreenState extends State<MathQuizScreen> {
  // Define phases: first is silence, next three are noisy
  final List<Phase> phases = [
    Phase(duration: 120, hasNoise: false), // Silence phase
    Phase(duration: 120, hasNoise: true), // Noisy phase 1
    Phase(duration: 120, hasNoise: true), // Noisy phase 2
    Phase(duration: 120, hasNoise: true), // Noisy phase 3
  ];

  int currentPhaseIndex = 0;
  Timer? timer;

  int currentProblem = 1;
  int correctAnswers = 0;
  int totalProblems = 0;
  double totalTimeSpent = 0;
  String answer = '';

  QuizState currentState = QuizState.InitialCountdown; // Current state
  int countdownSeconds = 3; // Initial countdown duration
  final int interPhaseCountdownDuration = 10; // 10-second inter-phase countdown

  final List<String> audioAssets = [
    "assets/audio/pink_noise.mp3",
    "assets/audio/green_noise.mp3",
    "assets/audio/white_noise.mp3"
  ];

  late int number1;
  late int number2;
  late String operator;

  // Text field controller (not used in current UI but kept for potential future use)
  final TextEditingController _controller = TextEditingController();

  // Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Camera-related variables
  CameraController? _cameraController;
  Timer? _imageCaptureTimer;
  ImageApi? _imageApi;
  String aiAnalysisResult = 'AI 분석 결과 대기 중...';

  @override
  void initState() {
    super.initState();
    _imageApi = ImageApi(); // Initialize ImageApi
    assignAudioToPhases(); // Assign audio to noisy phases
    generateProblem();
    _initializeCamera(); // Initialize camera
    startCountdown(); // Start initial countdown
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose controller
    timer?.cancel(); // Cancel any active timers
    _imageCaptureTimer?.cancel(); // Cancel image capture timer
    _audioPlayer.dispose(); // Dispose audio player
    _cameraController?.dispose(); // Dispose camera controller
    super.dispose();
  }

  // Assign each noise type to a unique noisy phase
  void assignAudioToPhases() {
    List<String> shuffledAudio = List.from(audioAssets)..shuffle();
    int audioIndex = 0;

    for (int i = 0; i < phases.length; i++) {
      if (phases[i].hasNoise) {
        if (audioIndex < shuffledAudio.length) {
          phases[i].audioAsset = shuffledAudio[audioIndex];
          audioIndex++;
        }
      }
    }
  }

  // Initialize the front camera
  Future<void> _initializeCamera() async {
    // Request camera permission
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        // Permission denied, handle appropriately
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카메라 권한이 필요합니다.')),
        );
        return;
      }
    }

    // Get available cameras
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      setState(() {}); // Update UI once the camera is initialized
    } catch (e) {
      // Handle camera initialization errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카메라 초기화 실패: $e')),
      );
    }
  }

  // Generate a new math problem
  void generateProblem() {
    Random random = Random();
    // Generate numbers based on difficulty
    int minNumber =
        pow(10, widget.difficulty - 1).toInt(); // e.g., 100 for difficulty 3
    int maxNumber =
        pow(10, widget.difficulty).toInt() - 1; // e.g., 999 for difficulty 3

    operator = random.nextBool() ? '+' : '-'; // Randomly choose '+' or '-'

    if (operator == '-') {
      // Ensure number1 >= number2 to avoid negative results
      number1 = random.nextInt(maxNumber - minNumber + 1) + minNumber;
      number2 = random.nextInt(number1 - minNumber + 1) + minNumber;
    } else {
      number1 = random.nextInt(maxNumber - minNumber + 1) + minNumber;
      number2 = random.nextInt(maxNumber - minNumber + 1) + minNumber;
    }
  }

  // Calculate the result of the current problem
  int calculateResult() {
    return operator == '+' ? number1 + number2 : number1 - number2;
  }

  // Start a countdown based on the current state
  void startCountdown() {
    timer = Timer.periodic(Duration(seconds: 1), (countdownTimer) {
      setState(() {
        if (countdownSeconds > 0) {
          countdownSeconds--;
        } else {
          countdownTimer.cancel();
          if (currentState == QuizState.InitialCountdown) {
            // Transition from initial countdown to first quiz phase
            setState(() {
              currentState = QuizState.QuizPhase;
              phaseRemainingSeconds = phases[currentPhaseIndex].duration;
            });
            startPhaseTimer();
          } else if (currentState == QuizState.InterPhaseCountdown) {
            // Transition from inter-phase countdown to next quiz phase
            setState(() {
              currentState = QuizState.QuizPhase;
              phaseRemainingSeconds = phases[currentPhaseIndex].duration;
            });
            startPhaseTimer();
          }
        }
      });
    });
  }

  int phaseRemainingSeconds = 120; // Each phase is 2 minutes

  // Start the timer for the current quiz phase
  void startPhaseTimer() {
    // Start audio if the current phase has noise
    if (phases[currentPhaseIndex].hasNoise) {
      playAssignedAudio(phases[currentPhaseIndex].audioAsset!);
    }

    // Start image capture timer
    _startImageCaptureTimer();

    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (phaseRemainingSeconds > 0) {
          phaseRemainingSeconds--;
        } else {
          // Phase ended, move to inter-phase countdown or finish
          t.cancel();
          stopAudio(); // Stop any playing audio
          _stopImageCaptureTimer(); // Stop image capture

          currentPhaseIndex++;
          if (currentPhaseIndex < phases.length) {
            // Start inter-phase countdown if more phases remain
            setState(() {
              currentState = QuizState.InterPhaseCountdown;
              countdownSeconds = interPhaseCountdownDuration;
            });
            startCountdown();
          } else {
            // All phases completed, show results
            setState(() {
              currentState = QuizState.Finished;
            });
            showResults();
          }
        }
      });
    });
  }

  // Play the assigned audio for the current phase
  void playAssignedAudio(String audioAsset) async {
    // Stop any existing audio before playing a new one
    await _audioPlayer.stop();
    await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop the audio
    await _audioPlayer
        .play(AssetSource(audioAsset.replaceFirst('assets/', '')));
  }

  // Stop any playing audio
  void stopAudio() {
    _audioPlayer.stop();
  }

  // Format time from seconds to MM:SS
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Display the results screen
  void showResults() {
    double averageTime = totalProblems > 0 ? totalTimeSpent / totalProblems : 0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          phases: phases,
          correctAnswers: correctAnswers,
          totalProblems: totalProblems,
          averageTime: averageTime,
        ),
      ),
    );
  }

  // Handle number pad button presses
  void onNumberPressed(String value) {
    if (currentState != QuizState.QuizPhase)
      return; // Only allow input during quiz phases

    setState(() {
      if (value == 'delete') {
        if (answer.isNotEmpty) {
          answer = answer.substring(0, answer.length - 1);
        }
      } else if (value == 'submit') {
        if (answer.isNotEmpty) {
          submitAnswer();
        }
      } else {
        if (answer.length < 8) {
          // Limit to 8 digits
          answer += value;
        }
      }
    });
  }

  // Submit the user's answer
  void submitAnswer() {
    setState(() {
      totalProblems++;
      // Calculate time spent on this problem
      double timeSpent =
          (phases[currentPhaseIndex].duration - phaseRemainingSeconds) /
              totalProblems;
      totalTimeSpent += timeSpent;

      if (int.parse(answer) == calculateResult()) {
        correctAnswers++;
      }
      answer = '';
      currentProblem++;
      generateProblem();
    });
  }

  // Start the image capture timer (captures image every 1 second)
  void _startImageCaptureTimer() {
    _imageCaptureTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      await _captureAndAnalyzeImage();
    });
  }

  // Stop the image capture timer
  void _stopImageCaptureTimer() {
    _imageCaptureTimer?.cancel();
    _imageCaptureTimer = null;
  }

  // Capture an image, compress it, and send it for AI analysis
  Future<void> _captureAndAnalyzeImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      // Capture the image
      XFile imageFile = await _cameraController!.takePicture();
      File file = File(imageFile.path);

      // Compress the image
      Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: 60, // 품질을 0~100 사이로 설정
        minWidth: 800, // 필요에 따라 해상도 조절
        minHeight: 600,
      );

      if (compressedBytes == null) {
        throw Exception('이미지 압축 실패');
      }

      // Upload the image and get AI analysis
      String aiResult =
          await _imageApi!.uploadImage(compressedBytes, imageFile.name);

      // Update the AI analysis result on the UI
      setState(() {
        aiAnalysisResult = aiResult;
        // 현재 페이즈의 AI 분석 결과 리스트에 추가
        phases[currentPhaseIndex].aiAnalysisResults.add(aiResult);
      });
    } catch (e) {
      // Handle errors (e.g., camera errors, upload errors)
      print('Error capturing or uploading image: $e');
      setState(() {
        aiAnalysisResult = 'AI 분석 실패';
      });
    }
  }

  // Build the number pad UI
  Widget buildNumberPad(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildNumberRow(['1', '2', '3'], screenWidth, screenHeight),
          buildNumberRow(['4', '5', '6'], screenWidth, screenHeight),
          buildNumberRow(['7', '8', '9'], screenWidth, screenHeight),
          buildNumberRow(['delete', '0', 'submit'], screenWidth, screenHeight),
        ],
      ),
    );
  }

  // Build a row of buttons for the number pad
  Widget buildNumberRow(
      List<String> numbers, double screenHeight, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.all(4),
            child: AspectRatio(
              aspectRatio: 1.5, // Button width:height ratio
              child: ElevatedButton(
                onPressed: () => onNumberPressed(number),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: number == 'submit'
                      ? Colors.blue
                      : number == 'delete'
                          ? Colors.red
                          : Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: number == 'delete'
                    ? Icon(Icons.backspace, color: Colors.white)
                    : number == 'submit'
                        ? Text('제출',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.02,
                              fontWeight: FontWeight.bold,
                            ))
                        : Text(
                            number,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Determine color based on AI analysis result
  Color _getAiResultColor(String result) {
    switch (result) {
      case '집중함':
        return Colors.green;
      case '집중하지 않음':
        return Colors.orange;
      case '졸음':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Dynamically adjust sizes based on screen size
          double fontSize = constraints.maxWidth * 0.08;
          double padding = constraints.maxWidth * 0.1;
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return Padding(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: () {
                switch (currentState) {
                  case QuizState.InitialCountdown:
                  case QuizState.InterPhaseCountdown:
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$countdownSeconds',
                          style: TextStyle(
                              fontSize: fontSize, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        Text(
                          currentState == QuizState.InitialCountdown
                              ? '시작 준비 중...'
                              : '다음 단계 준비 중...',
                          style: TextStyle(
                              fontSize: fontSize * 0.3,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    );
                  case QuizState.QuizPhase:
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Timer and Problem Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatTime(phaseRemainingSeconds),
                              style: TextStyle(
                                  fontSize: fontSize * 0.5,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "문제 $currentProblem",
                              style: TextStyle(
                                  fontSize: fontSize * 0.5,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // Display the math problem
                        Container(
                          padding: EdgeInsets.all(padding * 0.5),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          width: screenWidth * 0.8,
                          child: Center(
                            child: Text(
                              '$number1 $operator $number2',
                              style: TextStyle(
                                fontSize: fontSize * 0.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: padding * 0.5),
                        // Answer input field
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: padding * 0.5,
                              vertical: padding * 0.2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  answer.isEmpty ? '답을 입력하세요' : answer,
                                  style: TextStyle(
                                    fontSize: fontSize * 0.45,
                                    color: answer.isEmpty
                                        ? Colors.grey[400]
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              if (answer.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      answer = '';
                                    });
                                  },
                                  child: Icon(
                                    Icons.cancel,
                                    color: Colors.grey[400],
                                    size: fontSize * 0.45,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // Display AI Analysis Result
                        Text(
                          'AI 분석: $aiAnalysisResult',
                          style: TextStyle(
                            fontSize: fontSize * 0.35,
                            color: _getAiResultColor(aiAnalysisResult),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        // Number pad
                        Expanded(
                          child: buildNumberPad(screenWidth, screenHeight),
                        ),
                      ],
                    );
                  case QuizState.Finished:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                }
              }(),
            ),
          );
        },
      ),
    );
  }
}

// Phase class definition
class Phase {
  final int duration; // Duration in seconds
  final bool hasNoise;
  String? audioAsset;
  List<String> aiAnalysisResults = []; // AI 분석 결과를 저장할 리스트 추가

  Phase({required this.duration, required this.hasNoise, this.audioAsset});
}

// ResultsScreen 클래스 정의
class ResultsScreen extends StatelessWidget {
  final List<Phase> phases;
  final int correctAnswers;
  final int totalProblems;
  final double averageTime;

  ResultsScreen({
    required this.phases,
    required this.correctAnswers,
    required this.totalProblems,
    required this.averageTime,
  });

  // 페이즈별 집중도율 계산
  double calculateConcentrationRate(Phase phase) {
    int totalSeconds = phase.aiAnalysisResults.length; // 실제 분석된 초 수
    int concentratingCount =
        phase.aiAnalysisResults.where((result) => result == '집중함').length;
    if (totalSeconds == 0) return 0.0;
    return concentratingCount / totalSeconds;
  }

  @override
  Widget build(BuildContext context) {
    double overallConcentrationRate = 0.0;
    for (var phase in phases) {
      overallConcentrationRate += calculateConcentrationRate(phase);
    }
    overallConcentrationRate = (overallConcentrationRate / phases.length) * 100;

    return Scaffold(
      appBar: AppBar(
        title: Text('결과'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 전체 결과 표시
            Text(
              '정확도: ${(correctAnswers / totalProblems * 100).toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '평균 문제 풀이 시간: ${averageTime.toStringAsFixed(2)}초',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '전체 집중도율: ${overallConcentrationRate.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: phases.length,
                itemBuilder: (context, index) {
                  Phase phase = phases[index];
                  double concentrationRate =
                      calculateConcentrationRate(phase) * 100; // 퍼센트로 표시
                  return Card(
                    child: ListTile(
                      title: Text('페이즈 ${index + 1}'),
                      subtitle: Text(
                        '집중도율: ${concentrationRate.toStringAsFixed(1)}%',
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .popUntil((route) => route.isFirst); // 홈 화면으로 이동
              },
              child: Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}
