import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sound_studio/data/concentration_data.dart';
import 'package:sound_studio/network/concentration_services.dart';
import 'package:sound_studio/screens/difficulty_screen.dart';
import 'package:sound_studio/ui/concentration_bar_chart.dart';
import 'package:sound_studio/ui/concentration_pie_chart.dart';
import 'package:sound_studio/ui/content_block.dart';
import 'package:sound_studio/ui/scrollable_concentration_chart.dart';
import 'package:sound_studio/ui/time_bar_chart.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ConcentrationServices concentrationServices = ConcentrationServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(249, 249, 249, 0),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return SingleChildScrollView(
            padding:
                EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.05),
            child: Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                ContentBlock(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  title: '오늘의 집중도 확인',
                  widget: SizedBox(
                    height: screenHeight * 0.3 < 250 ? 250 : screenHeight * 0.3,
                    child: Center(
                      child: ConcentrationPieChart(percentage: 100),
                    ),
                  ),
                  ratioHeight: 0.45,
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                ContentBlock(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  ratioHeight: 0.50,
                  title: '집중도 그래프',
                  widget: SizedBox(
                    height: screenHeight * 0.2 < 260
                        ? 260
                        : screenHeight * 0.2, // 고정된 높이
                    child: ScrollableConcentrationChart(data: [
                      ConcentrationData(hour: 0, concentrationRate: 0), // 자는 시간
                      ConcentrationData(hour: 1, concentrationRate: 0),
                      ConcentrationData(hour: 2, concentrationRate: 0),
                      ConcentrationData(hour: 3, concentrationRate: 0),
                      ConcentrationData(hour: 4, concentrationRate: 0),
                      ConcentrationData(hour: 5, concentrationRate: 0), // 기상 시작

                      // 아침 시간대 (6-11시): 집중도 상승
                      ConcentrationData(hour: 6, concentrationRate: 0), // 아침 활동
                      ConcentrationData(hour: 7, concentrationRate: 0),
                      ConcentrationData(
                          hour: 8, concentrationRate: 85), // 업무/학습 시작
                      ConcentrationData(
                          hour: 9, concentrationRate: 90), // 오전 피크
                      ConcentrationData(hour: 10, concentrationRate: 85),
                      ConcentrationData(
                          hour: 11, concentrationRate: 75), // 점심 전

                      // 오후 시간대 (12-17시): 변동있는 집중도
                      ConcentrationData(
                          hour: 12, concentrationRate: 0), // 점심 시간
                      ConcentrationData(hour: 13, concentrationRate: 0), // 졸음시간
                      ConcentrationData(hour: 14, concentrationRate: 80),
                      ConcentrationData(
                          hour: 15, concentrationRate: 90), // 오후 업무
                      ConcentrationData(hour: 16, concentrationRate: 75),
                      ConcentrationData(
                          hour: 17, concentrationRate: 70), // 퇴근 시간

                      // 저녁 시간대 (18-23시): 점진적 감소
                      ConcentrationData(
                          hour: 18, concentrationRate: 0), // 저녁 활동
                      ConcentrationData(hour: 19, concentrationRate: 0),
                      ConcentrationData(hour: 20, concentrationRate: 0),
                      ConcentrationData(hour: 21, concentrationRate: 0), // 휴식
                      ConcentrationData(
                          hour: 22, concentrationRate: 0), // 취침 준비
                      ConcentrationData(
                          hour: 23, concentrationRate: 0), // 취침 시간
                    ]),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                ContentBlock(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    title: '총 학습 시간',
                    widget: Center(
                      child: Text(
                        '7시간 30분',
                        style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.04),
                      ),
                    ),
                    ratioHeight: 0.4),
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
