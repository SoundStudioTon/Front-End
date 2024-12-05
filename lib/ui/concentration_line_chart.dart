import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConcentrationLineChart extends StatelessWidget {
  final List<ConcentrationMData> data;
  final ScrollController scrollController = ScrollController();

  ConcentrationLineChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int minDataPoints = 60;
    final int dataPoints =
        data.isEmpty ? minDataPoints : max(data.length, minDataPoints);

    double viewportDataPoints = 12;
    double totalWidth = dataPoints * 20.0;
    double viewportWidth = viewportDataPoints * 20.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {});

    return Container(
      padding: const EdgeInsets.all(16),
      height: 350,
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
                      if (value.toInt() < 110) {
                        return Text('${value.toInt()}');
                      } else {
                        return Text('');
                      }
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: dataPoints.toDouble(),
              minY: 0,
              maxY: 120,
              lineBarsData: [
                if (data.isNotEmpty) // 데이터가 있을 때만 라인 표시
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map((entry) => FlSpot(entry.key.toDouble(),
                            entry.value.concentrationRate))
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

class ConcentrationMData {
  final int minute;
  final double concentrationRate;

  ConcentrationMData({
    required this.minute,
    required this.concentrationRate,
  });
}
