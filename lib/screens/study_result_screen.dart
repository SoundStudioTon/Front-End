import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sound_studio/screens/main_screen.dart';
import 'package:sound_studio/ui/concentration_cyan_pie_chart.dart';
import 'package:sound_studio/ui/concentration_line_chart.dart';
import 'package:sound_studio/ui/content_block.dart';

class StudyResultScreen extends StatefulWidget {
  final List<Map<String, dynamic>> studyData;
  final DateTime startTime;
  final int totalSeconds;

  const StudyResultScreen({
    super.key,
    required this.studyData,
    required this.startTime,
    required this.totalSeconds,
  });

  @override
  State<StudyResultScreen> createState() => _StudyResultScreenState();
}

class _StudyResultScreenState extends State<StudyResultScreen> {
  @override
  void initState() {
    super.initState();
  }

  String formatStudyTime() {
    int hours = widget.totalSeconds ~/ 3600;
    int minutes = (widget.totalSeconds % 3600) ~/ 60;
    return '${hours}시간 ${minutes}분';
  }

  double calculateAverageConcentration() {
    final validData =
        widget.studyData.where((data) => data['status'] != '0').toList();

    if (validData.isEmpty) return 0;

    int concentratedCount =
        validData.where((data) => data['status'] == '집중함').length;
    return (concentratedCount / validData.length) * 100;
  }

  List<ConcentrationMData> getConcentrationData() {
    final validData =
        widget.studyData.where((data) => data['status'] != '0').toList();

    if (validData.isEmpty) return [];

    Map<int, List<Map<String, dynamic>>> groupedByMinute = {};
    for (var data in validData) {
      int minute = (data['seconds'] / 60).floor();
      groupedByMinute.putIfAbsent(minute, () => []);
      groupedByMinute[minute]!.add(data);
    }

    List<ConcentrationMData> concentrationData = [];
    for (int minute = 0;
        minute <= (widget.totalSeconds / 60).floor();
        minute++) {
      if (groupedByMinute.containsKey(minute)) {
        var minuteData = groupedByMinute[minute]!;
        int totalValidCount = minuteData.length;
        int concentratedCount =
            minuteData.where((data) => data['status'] == '집중함').length;
        double concentrationRate = (concentratedCount / totalValidCount) * 100;

        concentrationData.add(ConcentrationMData(
          minute: minute,
          concentrationRate: concentrationRate,
        ));
      } else {
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
                (route) => false,
              );
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
