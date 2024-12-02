import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sound_studio/ui/concentration_line_chart.dart';
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

  @override
  void initState() {
    super.initState();
    // 샘플 데이터 추가
    addConcentrationData(DateTime.now(), 85.5);
    addConcentrationData(DateTime.now().subtract(Duration(days: 1)), 92.0);
  }

  void addConcentrationData(DateTime date, double value) {
    setState(() {
      concentrationData[DateTime(date.year, date.month, date.day)] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
    double? concentration =
        concentrationData[DateTime(date.year, date.month, date.day)];

    return GestureDetector(
      onTap: () {
        if (concentration != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                date: date,
                concentration: concentration,
              ),
            ),
          );
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
                      '${concentration.toStringAsFixed(1)}%',
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

  const DetailScreen({
    Key? key,
    required this.date,
    required this.concentration,
  }) : super(key: key);

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
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                ContentBlock(
                  screenWidth: MediaQuery.of(context).size.width,
                  screenHeight: MediaQuery.of(context).size.height,
                  title: '집중도',
                  widget: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Center(
                      child: ConcentrationPieChart(percentage: concentration),
                    ),
                  ),
                  ratioHeight: 0.3,
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                ContentBlock(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    title: '학습 그래프',
                    widget: ConcentrationLineChart(data: generateSampleData()),
                    ratioHeight: 0.4),
              ],
            ),
          ),
        );
      },
    );
  }
}
