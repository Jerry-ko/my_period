import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class EditPeriodDate extends StatefulWidget {
  const EditPeriodDate({super.key});

  @override
  State<EditPeriodDate> createState() => _EditPeriodDateState();
}

class _EditPeriodDateState extends State<EditPeriodDate> {
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime.utc(2024, 01, 01),
            lastDay: DateTime.now().add(
              const Duration(days: 60),
            ),
            locale: 'ko',
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
            calendarStyle: CalendarStyle(
              isTodayHighlighted: false,
              rangeHighlightColor:
                  Theme.of(context).primaryColor.withOpacity(0.5),
              rangeStartDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle),
              rangeEndDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle),
            ),
            rangeSelectionMode: RangeSelectionMode.toggledOn,
            rowHeight: 130,
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            onRangeSelected: (start, end, focusedDay) {
              setState(() {
                _rangeStart = start;
                _rangeEnd = end;
              });
            },
          ),
        ));
  }
}
