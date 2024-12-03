import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sound_studio/data/concentration_data.dart';

class ScrollableGreenConcentrationChart extends StatefulWidget {
  final List<ConcentrationData> data;

  ScrollableGreenConcentrationChart({required this.data});

  @override
  State<ScrollableGreenConcentrationChart> createState() =>
      _ScrollableGreenConcentrationChartState();
}

class _ScrollableGreenConcentrationChartState
    extends State<ScrollableGreenConcentrationChart> {
  late ScrollController _scrollController;
  final double _visibleHours = 8;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Container(
              width: 24 * 60.0,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: BarChart(
                BarChartData(
                  barGroups: widget.data.map((d) {
                    final opacity = 0.3 + (d.concentrationRate / 100 * 0.7);

                    return BarChartGroupData(
                      x: d.hour.toInt(),
                      barRods: [
                        BarChartRodData(
                          toY: d.concentrationRate,
                          color: Color.fromRGBO(76, 175, 80, 1)
                              .withOpacity(opacity), // 초록색으로 변경
                          width: 40,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                      showingTooltipIndicators:
                          d.concentrationRate > 0 ? [0] : [],
                    );
                  }).toList(),
                  alignment: BarChartAlignment.center,
                  maxY: 110,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${value.toInt()}시',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < 110) {
                            return Text(
                              '${value.toInt()}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            );
                          } else {
                            return Text('');
                          }
                        },
                        interval: 20,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
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
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1),
                      left: BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        if (rod.toY == 0) return null;

                        return BarTooltipItem(
                          '${rod.toY.toInt()}%',
                          const TextStyle(
                            color: Colors.black38,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                      tooltipPadding: const EdgeInsets.all(0),
                      tooltipMargin: 4,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipColor: (barData) => Colors.transparent,
                    ),
                  ),
                ),
                swapAnimationDuration: Duration(milliseconds: 150),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
