import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  DateTime selectedDate = DateTime.now();

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

  MonthCalendar() {
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
                onPressed: () {
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        _BuildCalendar(),
      ],
    );
  }

  _BuildCalendar() {
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

    // 시작 공백 추가
    for (int i = 0; i < firstDayOfMonth - 1; i++) {
      dayWidgets.add(Container());
    }

    // 날짜 및 이벤트 추가
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime currentDate =
          DateTime(selectedDate.year, selectedDate.month, day);
      dayWidgets.add(_buildDateCell(currentDate));

      // 주가 끝나면 줄바꿈
      if ((dayWidgets.length % 7) == 0) {
        rows.add(TableRow(children: dayWidgets));
        rows.add(_buildDividerRow()); // 구분선 추가
        dayWidgets = [];
      }
    }

    // 남은 공백 추가
    if (dayWidgets.isNotEmpty) {
      while (dayWidgets.length < 7) {
        dayWidgets.add(Container());
      }
      rows.add(TableRow(children: dayWidgets));
      rows.add(_buildDividerRow()); // 마지막 행 뒤에도 구분선 추가
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
    bool isSelected = date.isAtSameMomentAs(selectedDate);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date;
        });
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
              decoration: isSelected
                  ? BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    )
                  : null,
              margin: EdgeInsets.all(4),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
                fontSize: 16, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
