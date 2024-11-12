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
  int? answer;
  int countdown = 3; // 카운트다운을 위한 변수
  bool isCountdownActive = true; // 카운트다운 활성화 여부

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

  // 사용자가 답 제출
  void submitAnswer() {
    setState(() {
      totalProblems++;
      totalTimeSpent += (180 - remainingSeconds) / totalProblems;

      if (answer == calculateResult()) {
        correctAnswers++;
      }
      answer = null;
      _controller.clear(); // 제출 후 텍스트 필드의 내용을 지움
      currentProblem++;
      generateProblem();
    });
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
                              fontSize: fontSize * 0.9,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: padding),
                        Text(
                          "$currentProblem번 문제",
                          style: TextStyle(fontSize: fontSize * 0.7),
                        ),
                        SizedBox(height: padding),
                        Container(
                          padding: EdgeInsets.all(padding),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                operator,
                                style: GoogleFonts.inter(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: screenWidth * 0.05,
                              ),
                              Column(
                                children: [
                                  Text(
                                    "$number1",
                                    style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "$number2",
                                    style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: padding),
                        TextField(
                          controller: _controller, // 텍스트 필드에 컨트롤러 연결
                          decoration: InputDecoration(
                            labelText: "답 입력",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            answer = int.tryParse(value);
                          },
                        ),
                        SizedBox(height: padding),
                        ElevatedButton(
                          onPressed: submitAnswer,
                          child: Padding(
                            child: Text(
                              '제출',
                              style: GoogleFonts.inter(
                                fontSize: screenWidth * 0.04,
                                color: Colors.white,
                              ),
                            ),
                            padding: EdgeInsets.only(
                                left: screenWidth * 0.05,
                                right: screenWidth * 0.05,
                                top: screenWidth * 0.015,
                                bottom: screenWidth * 0.015),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black54,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                          ),
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
