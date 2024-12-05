import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sound_studio/ui/concentration_cyan_pie_chart.dart';
import 'package:sound_studio/ui/concentration_line_chart.dart';
import 'package:sound_studio/ui/content_block.dart';

class StudyResultScreen extends StatelessWidget {
  final List<Map<String, dynamic>> studyData;
  final DateTime startTime;
  final int totalSeconds;

  const StudyResultScreen({
    super.key,
    required this.studyData,
    required this.startTime,
    required this.totalSeconds,
  });

  String formatStudyTime() {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    return '${hours}시간 ${minutes}분';
  }

  double calculateAverageConcentration() {
    // 0이 아닌 데이터만 필터링
    final validData = studyData.where((data) => data['status'] != '0').toList();

    if (validData.isEmpty) return 0;

    // 집중함 상태의 개수
    int concentratedCount =
        validData.where((data) => data['status'] == '집중함').length;

    // 집중도율 = (집중함 개수) / (0이 아닌 전체 데이터 개수) * 100
    return (concentratedCount / validData.length) * 100;
  }

  List<ConcentrationMData> getConcentrationData() {
    // 0이 아닌 데이터만 필터링
    final validData = studyData.where((data) => data['status'] != '0').toList();

    if (validData.isEmpty) return [];

    // 분 단위로 데이터 그룹화
    Map<int, List<Map<String, dynamic>>> groupedByMinute = {};
    for (var data in validData) {
      int minute = (data['seconds'] / 60).floor();
      groupedByMinute.putIfAbsent(minute, () => []);
      groupedByMinute[minute]!.add(data);
    }

    // 각 분마다의 집중도 계산
    List<ConcentrationMData> concentrationData = [];
    for (int minute = 0; minute <= (totalSeconds / 60).floor(); minute++) {
      if (groupedByMinute.containsKey(minute)) {
        var minuteData = groupedByMinute[minute]!;

        // 해당 분의 전체 유효 데이터 개수
        int totalValidCount = minuteData.length;
        // 해당 분의 집중함 상태 개수
        int concentratedCount =
            minuteData.where((data) => data['status'] == '집중함').length;

        // 집중도 = (집중함 개수 / 전체 유효 데이터 개수) * 100
        double concentrationRate = (concentratedCount / totalValidCount) * 100;

        concentrationData.add(ConcentrationMData(
          minute: minute,
          concentrationRate: concentrationRate,
        ));
      } else {
        // 데이터가 없는 분은 이전 데이터를 유지
        double previousRate = concentrationData.isNotEmpty
            ? concentrationData.last.concentrationRate
            : 0.0;
        concentrationData.add(ConcentrationMData(
          minute: minute,
          concentrationRate: previousRate,
        ));
      }
    }

    return concentrationData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... 기존 코드 ...
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
                      formatStudyTime(),
                      style: GoogleFonts.doHyeon(
                        fontSize: screenWidth * 0.1,
                      ),
                    ),
                    ratioHeight: 0.2),
                SizedBox(height: screenHeight * 0.02),
                ContentBlock(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    title: '학습 평균 집중도',
                    widget: ConcentrationCyanPieChart(
                        percentage: calculateAverageConcentration()),
                    ratioHeight: 0.4),
                SizedBox(height: screenHeight * 0.02),
                ContentBlock(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    title: '학습 집중도 그래프',
                    widget:
                        ConcentrationLineChart(data: getConcentrationData()),
                    ratioHeight: 0.4),
              ],
            ),
          );
        },
      ),
    );
  }
}
