import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConcentrationLineChart extends StatelessWidget {
  final List<ConcentrationData> data;
  final ScrollController scrollController = ScrollController();

  ConcentrationLineChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double viewportDataPoints = 12;
    double totalWidth = data.length * 20.0;
    double viewportWidth = viewportDataPoints * 20.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });

    return Container(
      padding: const EdgeInsets.all(16),
      height: 300,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: Container(
          width: totalWidth,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      int minute = value.toInt();
                      int hour = minute ~/ 60;
                      int min = minute % 60;
                      return Text(
                        '${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}',
                        style: GoogleFonts.inter(fontSize: 8),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}%');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: data.length.toDouble(),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: data
                      .asMap()
                      .entries
                      .map((entry) => FlSpot(
                          entry.key.toDouble(), entry.value.concentrationRate))
                      .toList(),
                  isCurved: true,
                  color: Colors.cyan[100],
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.cyan.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConcentrationData {
  final int minute;
  final double concentrationRate;

  ConcentrationData({
    required this.minute,
    required this.concentrationRate,
  });
}

// 예시 데이터 (90분, 1분 간격)
List<ConcentrationData> generateSampleData() {
  List<ConcentrationData> data = [];

  // 5분 단위의 기준 집중도
  Map<int, int> baseConcentrations = {
    0: 83, // 0분
    5: 84, // 5분
    10: 85, // 10분
    15: 90, // 15분
    20: 95, // 20분
    25: 100, // 25분
    30: 95, // 30분
    35: 90, // 35분
    40: 85, // 40분
    45: 88, // 45분
    50: 84, // 50분
    55: 85, // 55분
    60: 87, // 60분
    65: 90, // 65분
    70: 92, // 70분
    75: 80, // 75분
    80: 78, // 80분
    85: 80, // 85분
    90: 70, // 90분
  };

  for (int minute = 0; minute < 90; minute++) {
    int baseMinute = (minute ~/ 5) * 5;
    int nextBaseMinute = baseMinute + 5;

    int currentBase = baseConcentrations[baseMinute] ?? 65;
    int nextBase = baseConcentrations[nextBaseMinute] ?? currentBase;

    int minuteInInterval = minute % 5;
    double progress = minuteInInterval / 5;

    int concentration =
        currentBase + ((nextBase - currentBase) * progress).round();

    data.add(ConcentrationData(
        minute: minute, concentrationRate: concentration.toDouble()));
  }

  return data;
}
