import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sound_studio/data/concentration_data.dart';

class ConcentrationBarChart extends StatelessWidget {
  final List<ConcentrationData> data;

  ConcentrationBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: data.map((d) {
          // 집중도에 따라 색상의 밝기를 조절 (0-100%)
          // 집중도가 높을수록 더 진한 보라색
          final opacity =
              0.3 + (d.concentrationRate / 100 * 0.7); // 30%-100% 사이의 투명도

          return BarChartGroupData(
            x: d.hour.toInt(),
            barRods: [
              BarChartRodData(
                toY: d.concentrationRate,
                color: Colors.purple.withOpacity(opacity),
                width: 16, // 막대 너비
                borderRadius: BorderRadius.circular(4), // 막대 모서리 둥글기
              ),
            ],
          );
        }).toList(),

        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}h',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                );
              },
              interval: 1, // 1시간 간격
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                );
              },
              interval: 20, // 20% 간격
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.black, width: 1),
            left: BorderSide(color: Colors.black, width: 1),
          ),
        ),

        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.black12,
              strokeWidth: 1,
            );
          },
        ),

        maxY: 100, // 최대값 설정 (100%)
      ),
    );
  }
}
