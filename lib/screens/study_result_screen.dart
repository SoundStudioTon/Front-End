import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sound_studio/screens/main_screen.dart';
import 'package:sound_studio/ui/concentration_cyan_pie_chart.dart';
import 'package:sound_studio/ui/concentration_line_chart.dart';
import 'package:sound_studio/ui/content_block.dart';

class StudyResultScreen extends StatelessWidget {
  const StudyResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(),
                  ));
            },
            child: Text(
              '홈 화면으로 돌아가기',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black54,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3))),
          ),
          SizedBox(
            width: 16,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                ContentBlock(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    title: '학습 시간',
                    widget: Text(
                      '1시간 49분',
                      style: GoogleFonts.doHyeon(
                        fontSize: screenWidth * 0.1,
                      ),
                    ),
                    ratioHeight: 0.2),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                ContentBlock(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    title: '학습 평균 집중도',
                    widget: ConcentrationCyanPieChart(percentage: 86),
                    ratioHeight: 0.4),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                ContentBlock(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    title: '학습 집중도 그래프',
                    widget: ConcentrationLineChart(data: generateSampleData()),
                    ratioHeight: 0.4),
              ],
            ),
          );
        },
      ),
    );
  }
}
