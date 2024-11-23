import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ConcentrationPieChart extends StatelessWidget {
  final double percentage; // 집중도를 나타내는 퍼센트 (0 ~ 100)

  ConcentrationPieChart({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: _generateSections(percentage),
        startDegreeOffset: 270, // 시작 지점을 위쪽으로 설정
        centerSpaceRadius: 50, // 가운데 공간 크기
        sectionsSpace: 0, // 각 조각 간의 간격
      ),
    );
  }

  /// 퍼센트 기반의 PieChart 섹션을 생성하는 함수
  List<PieChartSectionData> _generateSections(double percentage) {
    return [
      PieChartSectionData(
        color: _generateGradient(percentage),
        value: percentage,
        radius: 60,
        title: '${percentage.toStringAsFixed(1)}%',
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.grey[200], // 비어있는 부분은 회색으로
        value: 100 - percentage,
        radius: 60,
        title: '',
      ),
    ];
  }

  /// 퍼센트에 따라 그라데이션 색상을 생성하는 함수
  Color _generateGradient(double percentage) {
    if (percentage >= 75) {
      return Colors.green; // 높은 집중도는 녹색
    } else if (percentage >= 50) {
      return Colors.blue; // 중간 집중도는 파란색
    } else if (percentage >= 25) {
      return Colors.orange; // 낮은 집중도는 주황색
    } else {
      return Colors.red; // 매우 낮은 집중도는 빨간색
    }
  }
}
