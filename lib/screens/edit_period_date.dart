import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_period/models/period_cycle_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class EditPeriodDate extends StatefulWidget {
  const EditPeriodDate({super.key});

  @override
  State<EditPeriodDate> createState() => _EditPeriodDateState();
}

class _EditPeriodDateState extends State<EditPeriodDate> {
  late SharedPreferences prefs;
  List<PeriodModel> allPeriodDates = [];

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    String jsonString = prefs.getString('history')!;
    List<dynamic> jsonList = jsonDecode(jsonString);
    List<PeriodModel> history =
        jsonList.map((jsonItem) => PeriodModel.fromJson(jsonItem)).toList();

    setState(() {
      allPeriodDates = history;
    });
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: TableCalendar(
          focusedDay: DateTime.now(),
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2029, 12, 31),
          locale: 'ko',
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
          ),
          calendarStyle: const CalendarStyle(
            isTodayHighlighted: false,
          ),
          rangeSelectionMode: RangeSelectionMode.toggledOn,
          rowHeight: 100,
          onDaySelected: (selectedDay, focusedDay) {
            print('selectedDay $selectedDay');
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              for (var period in allPeriodDates) {
                if (period.actualStartDate != null &&
                    period.actualStartDate != null &&
                    day.isAfter(period.actualStartDate!) &&
                    day.isBefore(period.actualEndDate!)) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(day.day.toString()),
                      const SizedBox(
                        height: 4,
                      ),
                      const SizedBox(
                        width: 35,
                        height: 35,
                        child: Icon(Icons.circle_rounded, color: Colors.amber),
                      ),
                    ],
                  );
                }
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(day.day.toString()),
                  const SizedBox(
                    height: 4,
                  ),
                  const SizedBox(
                    width: 35,
                    height: 35,
                    child: Icon(Icons.circle_outlined, color: Colors.amber),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}


//DateTime.now() 활용해 다음달까지민 캘린더 생성
//실제생리일만 기록 
//시작일만 있고 종료일만 있을 경우에는 종료일에도 시작일 넣어 기록


//sharedpreference에서 history 가져온다
//json에서 List<PeriodModel>로 변경하여 변수 allPeriodDates에 담는다
//allPeriodDates를 맵으로 순회하며 start:actualStart와 end:actualEnd 데이터를 담는다. 변수 selectedRangs=[];
//calendarbuiler를 이용해 selectedRanges를 map으로 순회하며 각 day를 체크해 day가 selectedRange 범위 이내이면
//컬러로 표시 아니면 null 반환

//위의 디폴트 상태에서 편집시
