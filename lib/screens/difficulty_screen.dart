import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sound_studio/screens/math_quiz_screen.dart';

class DifficultyScreen extends StatefulWidget {
  const DifficultyScreen({super.key});

  @override
  _DifficultyScreenState createState() => _DifficultyScreenState();
}

class _DifficultyScreenState extends State<DifficultyScreen> {
  int difficulty = 3;

  void _increaseDifficulty() {
    setState(() {
      if (difficulty < 8) difficulty++;
    });
  }

  void _decreaseDifficulty() {
    setState(() {
      if (difficulty > 1) difficulty--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 화면 너비에 따라 폰트 크기 및 요소 크기를 조절
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;
          double fontSizeTitle = constraints.maxWidth * 0.08;
          double fontSizeNumber = constraints.maxWidth * 0.10;
          double iconSize = constraints.maxWidth * 0.2; // 아이콘 크기를 줄임
          double padding = constraints.maxWidth * 0.05;

          return Center(
              child: Padding(
            padding: EdgeInsets.symmetric(vertical: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: screenHeight * 0.12,
                ),
                Text('난이도 설정',
                    style: GoogleFonts.bebasNeue(
                      color: Color.fromARGB(180, 0, 0, 0),
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    )),
                SizedBox(height: screenHeight * 0.04),
                Text(
                  '$difficulty',
                  style: TextStyle(
                    fontSize: fontSizeNumber, // 가변 숫자 크기
                    color: Color.fromARGB(180, 0, 0, 0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                Row(
                  mainAxisSize: MainAxisSize.min, // Row 크기를 최소화하여 간격 줄이기
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _decreaseDifficulty,
                      child: Image.asset(
                        'assets/left_arrow.png',
                        height: screenHeight * 0.12,
                        width: screenHeight * 0.095,
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.1,
                    ),
                    GestureDetector(
                      onTap: _increaseDifficulty,
                      child: Image.asset(
                        'assets/right_arrow.png',
                        height: screenHeight * 0.12,
                        width: screenHeight * 0.095,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.1),
                ElevatedButton(
                  onPressed: () {
                    // 테스트 시작 로직
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MathQuizScreen(difficulty: difficulty),
                        ));
                  },
                  child: Padding(
                    child: Text(
                      '테스트 시작하기',
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
                Spacer(),
                Padding(
                  padding: EdgeInsets.all(padding), // 가변 패딩
                  child: Text(
                    '소음 테스트를 진행합니다. 난이도의 숫자는 숫자의 자릿 수를 의미합니다. ',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ));
        },
      ),
    );
  }
}
