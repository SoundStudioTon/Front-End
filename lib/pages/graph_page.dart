import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sound_studio/data/concentration_data.dart';
import 'package:sound_studio/network/concentration_services.dart';
import 'package:sound_studio/ui/concentration_green_bar_chart.dart';
import 'package:sound_studio/ui/concentration_green_pie_chart.dart';
import 'package:sound_studio/ui/concentration_pie_chart.dart';
import 'package:sound_studio/ui/content_block.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  DateTime selectedDate = DateTime.now();
  Map<DateTime, double> concentrationData = {};
  bool _isLoading = false;
  ConcentrationServices concentrationServices = ConcentrationServices();

  @override
  void initState() {
    super.initState();
    _fetchMonthData();
  }

  Future<void> _fetchMonthData() async {
    setState(() {
      _isLoading = true;
      concentrationData.clear();
    });

    try {
      // 선택된 월의 데이터 가져오기
      final concentrationResponses =
          await concentrationServices.getMonthConcentrationData(selectedDate);

      // 날짜별로 데이터 그룹화
      Map<DateTime, List<ConcentrationResponse>> dailyGroups = {};

      for (var response in concentrationResponses) {
        DateTime dateKey = DateTime(
          response.date.year,
          response.date.month,
          response.date.day,
        );
        dailyGroups.putIfAbsent(dateKey, () => []);
        dailyGroups[dateKey]!.add(response);
      }

      // 각 날짜별 집중도 계산
      dailyGroups.forEach((date, responses) {
        // 0이 아닌 데이터만 필터링
        var validResponses = responses.where((r) => r.value != '0').toList();

        if (validResponses.isNotEmpty) {
          // 집중도 계산: (집중함 개수) / (0이 아닌 전체 데이터 개수) * 100
          int concentratedCount =
              validResponses.where((r) => r.value == '집중함').length;
          double concentrationRate =
              (concentratedCount / validResponses.length) * 100;

          concentrationData[date] = concentrationRate;
        }
      });
    } catch (e) {
      print('Error fetching month concentration data: $e');
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터를 불러오는데 실패했습니다.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.black,
            ))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: MonthCalendar(),
            ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('ko', 'KR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchMonthData(); // 새로운 달 선택시 데이터 다시 불러오기
    }
  }

  void _navigateToDetailScreen(DateTime date, double concentration) async {
    try {
      final dayData = await concentrationServices.getDayConcentartionData(date);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(
            date: date,
            concentration: concentration,
            concentrationResponses: dayData,
          ),
        ),
      );
    } catch (e) {
      print('Error fetching day detail data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상세 데이터를 불러오는데 실패했습니다.')),
      );
    }
  }

  Widget MonthCalendar() {
    final String year = DateFormat('y').format(selectedDate);
    final String month = DateFormat('M').format(selectedDate);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${year}년 ${month}월',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
        ),
        _BuildCalendar(),
      ],
    );
  }

  Widget _BuildCalendar() {
    return Table(
      children: _generateCalendarRows(),
    );
  }

  List<TableRow> _generateCalendarRows() {
    List<TableRow> rows = [];
    List<Widget> dayWidgets = [];

    final daysInMonth =
        DateUtils.getDaysInMonth(selectedDate.year, selectedDate.month);
    final firstDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month, 1).weekday;

    List<String> weekDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    rows.add(
      TableRow(
        children: weekDays
            .map(
              (day) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    day,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
    rows.add(_buildDividerRow());

    for (int i = 0; i < firstDayOfMonth - 1; i++) {
      dayWidgets.add(Container());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      DateTime currentDate =
          DateTime(selectedDate.year, selectedDate.month, day);
      dayWidgets.add(_buildDateCell(currentDate));

      if ((dayWidgets.length % 7) == 0) {
        rows.add(TableRow(children: dayWidgets));
        rows.add(_buildDividerRow());
        dayWidgets = [];
      }
    }

    if (dayWidgets.isNotEmpty) {
      while (dayWidgets.length < 7) {
        dayWidgets.add(Container());
      }
      rows.add(TableRow(children: dayWidgets));
      rows.add(_buildDividerRow());
    }

    return rows;
  }

  TableRow _buildDividerRow() {
    return TableRow(
      children: List.generate(
        7,
        (index) => Container(
          height: 1,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDateCell(DateTime date) {
    double? concentration = concentrationData[date];

    return GestureDetector(
      onTap: () {
        if (concentration != null) {
          _navigateToDetailScreen(date, concentration);
        }
      },
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(4),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            if (concentration != null)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    Text(
                      '${concentration.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _getConcentrationColor(concentration),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getConcentrationColor(double value) {
    if (value >= 90) return Colors.green;
    if (value >= 80) return Colors.blue;
    if (value >= 70) return Colors.orange;
    return Colors.red;
  }
}

class DetailScreen extends StatelessWidget {
  final DateTime date;
  final double concentration;
  final List<ConcentrationResponse> concentrationResponses;

  const DetailScreen({
    Key? key,
    required this.date,
    required this.concentration,
    required this.concentrationResponses,
  }) : super(key: key);

  List<ConcentrationData> _processHourlyData() {
    // 시간별로 데이터 그룹화
    Map<int, List<ConcentrationResponse>> hourlyGroups = {};

    // 모든 시간대 초기화
    for (int i = 0; i < 24; i++) {
      hourlyGroups[i] = [];
    }

    // 받은 데이터 그룹화
    for (var response in concentrationResponses) {
      int hour = response.date.hour;
      hourlyGroups[hour]!.add(response);
    }

    // 각 시간대별 집중도 계산
    return List.generate(24, (hour) {
      var responses = hourlyGroups[hour]!;
      var validResponses = responses.where((r) => r.value != '0').toList();

      double concentrationRate = 0;
      if (validResponses.isNotEmpty) {
        int concentratedCount =
            validResponses.where((r) => r.value == '집중함').length;
        concentrationRate = (concentratedCount / validResponses.length) * 100;
      }

      return ConcentrationData(
        hour: hour.toDouble(),
        concentrationRate: concentrationRate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double screenHeight = constraints.maxHeight;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              '${DateFormat('y년 M월 d일').format(date)}',
              style: GoogleFonts.jua(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            scrolledUnderElevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                ContentBlock(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  title: '집중도',
                  widget: SizedBox(
                    height: screenHeight * 0.3,
                    child: Center(
                      child: ConcentrationGreenPieChart(
                        percentage: concentration,
                      ),
                    ),
                  ),
                  ratioHeight: 0.3,
                ),
                SizedBox(height: screenHeight * 0.02),
                ContentBlock(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  title: '시간대별 집중도 그래프',
                  widget: ScrollableGreenConcentrationChart(
                    data: _processHourlyData(),
                  ),
                  ratioHeight: 0.45,
                ),
                SizedBox(
                  height: screenHeight * 0.1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
