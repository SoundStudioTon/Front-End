import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class ConcentrationPieChart extends StatelessWidget {
  final double percentage;

  ConcentrationPieChart({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: PieChart(
            PieChartData(
              sections: _generateSections(percentage),
              startDegreeOffset: -90, // 시작 각도를 -90도로 변경
              centerSpaceRadius: 0, // 중앙 공간을 없애고
              sectionsSpace: 0, // 섹션 간격도 없앰
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        Container(
          width: 160, // 내부 흰색 원 크기
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '사용자의 집중도는',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink[200],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _generateSections(double percentage) {
    final filledColor = SweepGradient(
      colors: [
        const Color.fromRGBO(248, 187, 208, 1), // 핑크
        const Color.fromRGBO(244, 143, 177, 1),
      ],
      stops: [0.0, 1.0],
      startAngle: 0,
      endAngle: 3.14 * 2,
    );

    return [
      PieChartSectionData(
        value: percentage,
        color: Colors.purple.shade200,
        radius: 100,
        title: '',
        showTitle: false,
        gradient: filledColor,
      ),
      PieChartSectionData(
        value: 100 - percentage,
        color: Colors.grey.shade200,
        radius: 100,
        title: '',
        showTitle: false,
      ),
    ];
  }
}
