import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sound_studio/screens/difficulty_screen.dart';
import 'package:sound_studio/ui/concentration_pie_chart.dart';
import 'package:sound_studio/ui/content_block.dart';
import 'package:sound_studio/ui/time_bar_chart.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return SingleChildScrollView(
            padding:
                EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.05),
            child: Column(
              children: [
                ContentBlock(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  title: '오늘의 집중도 확인',
                  widget: SizedBox(
                    height: screenHeight * 0.2,
                    child: ConcentrationPieChart(percentage: 50),
                  ),
                  ratioHeight: 0.5,
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                ContentBlock(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  ratioHeight: 0.4,
                  title: '집중도 그래프',
                  widget: SizedBox(
                    height: screenHeight * 0.25, // 고정된 높이
                    child: TimeBarChart(),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                Container(
                  height: screenHeight * 0.4,
                  width: constraints.maxWidth * 0.96,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(80, 217, 217, 217),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '총 학습 시간',
                          style: GoogleFonts.inter(
                            fontSize: screenHeight * 0.03,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        Spacer(),
                        Center(
                          child: Text(
                            '학습을 시작하세요',
                            style: GoogleFonts.inter(
                              fontSize: screenHeight * 0.025,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DifficultyScreen(),
                        ));
                  },
                  child: Text(
                    '소음테스트 다시 진행하기',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black54,
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0),
                      )),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
