import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConcentrationLineChart extends StatelessWidget {
  final List<ConcentrationData> data;

  ConcentrationLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots:
                data.map((d) => FlSpot(d.hour, d.concentrationRate)).toList(),
            isCurved: true,
            color: Colors.blue,
          )
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1, // 1시간 간격
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20, // 0-100% 사이 간격
            ),
          ),
        ),
      ),
    );
  }
}

class ConcentrationData {
  final double hour;
  final double concentrationRate;

  ConcentrationData({required this.hour, required this.concentrationRate});
}
