import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MathQuizScreen extends StatefulWidget {
  final int difficulty; // 난이도를 입력받음
  const MathQuizScreen({super.key, required this.difficulty});

  @override
  _MathQuizScreenState createState() => _MathQuizScreenState();
}

class _MathQuizScreenState extends State<MathQuizScreen> {
  late int remainingSeconds = 180; // 3분(180초) 타이머
  late Timer timer;
  int currentProblem = 1;
  int correctAnswers = 0;
  int totalProblems = 0;
  double totalTimeSpent = 0;
  String answer = '';
  int countdown = 3; // 카운트다운을 위한 변수
  bool isCountdownActive = true; // 카운트다운 활성화 여부

  final audio = [
    "assets/audio/pink_noise.mp3",
    "assets/audio/green_noise.mp3",
    "assets/audio/white_noise.mp3"
  ];

  late int number1;
  late int number2;
  late String operator;

  // 텍스트 필드 컨트롤러
  final TextEditingController _controller = TextEditingController();

  // 문제 생성
  void generateProblem() {
    Random random = Random();
    // 난이도에 맞는 자리수의 숫자를 생성
    int minNumber = pow(10, widget.difficulty - 1)
        .toInt(); // 최소값 (ex. 100 for difficulty 3)
    int maxNumber = pow(10, widget.difficulty).toInt() -
        1; // 최대값 (ex. 999 for difficulty 3)

    number1 = random.nextInt(maxNumber - minNumber + 1) + minNumber;
    number2 = random.nextInt(maxNumber - minNumber + 1) + minNumber;
    operator = random.nextBool() ? '+' : '-';
  }

  // 결과 계산
  int calculateResult() {
    return operator == '+' ? number1 + number2 : number1 - number2;
  }

  // 카운트다운 시작
  void startCountdown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          timer.cancel();
          isCountdownActive = false; // 카운트다운이 끝나면 문제 풀기 시작
          startTimer(); // 문제 풀이 타이머 시작
        }
      });
    });
  }

  // 문제 풀이 시간 타이머
  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          timer.cancel();
          showResults();
        }
      });
    });
  }

  // 시간 포맷을 분:초로 변환
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    generateProblem();
    startCountdown(); // 카운트다운 시작
  }

  // 결과 화면
  void showResults() {
    double averageTime = totalTimeSpent / totalProblems;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("결과"),
        content: Text(
          "정확도: ${(correctAnswers / totalProblems * 100).toStringAsFixed(1)}%\n"
          "평균 문제 풀이 시간: ${averageTime.toStringAsFixed(2)}초",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("확인"),
          ),
        ],
      ),
    );
  }

  // 숫자 입력 처리
  void onNumberPressed(String value) {
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
          // 최대 8자리로 제한
          answer += value;
        }
      }
    });
  }

  // submitAnswer 메서드 수정
  void submitAnswer() {
    setState(() {
      totalProblems++;
      totalTimeSpent += (180 - remainingSeconds) / totalProblems;

      if (int.parse(answer) == calculateResult()) {
        correctAnswers++;
      }
      answer = '';
      currentProblem++;
      generateProblem();
    });
  }

  // 넘버패드 위젯
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

  Widget buildNumberRow(
      List<String> numbers, double screenHeight, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.all(4),
            child: AspectRatio(
              aspectRatio: 1.5, // 버튼의 가로:세로 비율
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

  @override
  void dispose() {
    _controller.dispose(); // 컨트롤러 메모리 해제
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 화면 크기에 따라 동적으로 비율 조정
          double fontSize = constraints.maxWidth * 0.08;
          double padding = constraints.maxWidth * 0.1;
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return Padding(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: isCountdownActive
                  ? Text(
                      countdown > 0 ? '$countdown' : '시작',
                      style: TextStyle(
                          fontSize: fontSize, fontWeight: FontWeight.bold),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          formatTime(remainingSeconds),
                          style: TextStyle(
                              fontSize: fontSize * 0.5,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Text(
                          "$currentProblem번 문제",
                          style: TextStyle(
                              fontSize: fontSize * 0.5,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: padding * 0.5),
                        // 문제 표시 부분 추가
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
                        // 답 입력창
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
                        SizedBox(height: screenHeight * 0.03),
                        // 넘버패드 크기 조절
                        Expanded(
                          child: buildNumberPad(screenWidth, screenHeight),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
