import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_period/models/period_cycle_model.dart';
import 'package:my_period/screens/home_screen.dart';
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
  bool isLoading = true;

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    String jsonString = prefs.getString('history')!;
    List<dynamic> jsonList = jsonDecode(jsonString);
    List<PeriodModel> history =
        jsonList.map((jsonItem) => PeriodModel.fromJson(jsonItem)).toList();
    print('history $history');

    setState(() {
      allPeriodDates = history;
      isLoading = false;
    });
  }

  // todo: 각 주기에 순서표시하기
  // startDay가 있을 때
  // startDay인지, startDay-7인지 -> 시작일 변경
  // startDay+7인지 -> 종료일 변경
  // 위의 조건에 부합하지 않는다면 새로운 startDay, endDay 동일한 주기 생성 -> 새로 새성
  checkSelectedDay(List<PeriodModel> allPeriodDates, DateTime day) {
    List<PeriodModel> updatedAllPeriodDates;

    bool isStartDate =
        allPeriodDates.any((period) => period.actualStartDate == day);

    bool isBeforeStartDate = allPeriodDates.any((period) =>
        period.actualStartDate != null &&
        day.isAfter(period.actualStartDate!.add(const Duration(days: -7))) &&
        day.isBefore(period.actualStartDate!));

    bool isAfterStartDate = allPeriodDates.any((period) =>
        period.actualStartDate != null &&
        day.isAfter(period.actualStartDate!) &&
        day.isBefore(period.actualStartDate!.add(const Duration(days: 7))));

    if (isStartDate) {
      //클릭한 날짜가 시작일과 동일할 때, 종료일과 같거나 종료일 전이라면 시작일+1
      updatedAllPeriodDates = allPeriodDates.map((period) {
        if (period.actualStartDate == day) {
          DateTime changedStartDate =
              period.actualStartDate!.add(const Duration(days: 1));

          period.actualStartDate =
              changedStartDate.isBefore(period.actualEndDate!) ||
                      changedStartDate == period.actualEndDate
                  ? changedStartDate
                  : null;

          if (period.actualStartDate == null) {
            period.actualEndDate = null;
          }
        }

        return period;
      }).toList();

      return updatedAllPeriodDates;
    }
    if (isBeforeStartDate) {
      //클릭한 날짜가 시작일-7 이후의 날짜일 경우 시작일 변경
      updatedAllPeriodDates = allPeriodDates.map((period) {
        if (period.actualStartDate != null &&
            day.isAfter(
                period.actualStartDate!.add(const Duration(days: -7))) &&
            day.isBefore(period.actualStartDate!)) {
          period.actualStartDate = day;
        }

        return period;
      }).toList();
      return updatedAllPeriodDates;
    }
    if (isAfterStartDate) {
      //클릭한 날짜가 시작일+7 이내의 날짜일 경우 종료일 변경
      //종료일이거나 종료일 이전 날짜라면 종료일에서 해당일+1 뺀 일 수를 종료일로
      //종료일 이후이면 그대로 종료일 변경

      updatedAllPeriodDates = allPeriodDates.map((period) {
        if (period.actualEndDate != null && period.actualEndDate == day) {
          //선택한 날짜가 종료일과 같다면
          DateTime changedEndDate = day.subtract(const Duration(days: 1));
          period.actualEndDate =
              changedEndDate.isAfter(period.actualStartDate!) ||
                      changedEndDate == period.actualStartDate
                  ? changedEndDate
                  : null;

          if (period.actualEndDate == null) {
            period.actualStartDate = null;
          }
        } else if (period.actualEndDate != null &&
            day.isAfter(
                period.actualStartDate!.add(const Duration(days: -7))) &&
            day.isBefore(period.actualEndDate!)) {
          //선택한 날짜가 종료일 전이라면
          int count = period.actualEndDate!.difference(day).inDays;
          period.actualEndDate =
              period.actualEndDate!.subtract(Duration(days: count + 1));
        } else if (period.actualEndDate != null &&
            day.isAfter(period.actualEndDate!) &&
            day.isBefore(
                period.actualStartDate!.add(const Duration(days: 7)))) {
          // 선택한 날짜가 종료일 후라면
          period.actualEndDate = day;
        }

        return period;
      }).toList();
      updatedAllPeriodDates.removeWhere((item) =>
          item.actualStartDate == null &&
          item.actualEndDate == null &&
          item.actualStartDate == null &&
          item.expectedEndDate == null);
      return updatedAllPeriodDates;
    }

    // startDay, endDay 동일한 주기 새로 생성
    PeriodModel newPeriod =
        PeriodModel(actualStartDate: day, actualEndDate: day);
    allPeriodDates.add(newPeriod);
    updatedAllPeriodDates = allPeriodDates;
    print('newPeriod $newPeriod');

    return updatedAllPeriodDates;
  }

  saveAllPeriodDates(List<PeriodModel> allPeriodDates) async {
    List<Map<String, dynamic>> jsonData =
        allPeriodDates.map((period) => period.toJson()).toList();
    await prefs.setString('history', jsonEncode(jsonData));
    return null;
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CircularProgressIndicator();
    }
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Expanded(
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
                  rowHeight: 90,
                  onDaySelected: (selectedDay, focusedDay) {
                    DateTime modifiedSelectedDay = DateTime.parse(
                        DateFormat('yyyy-MM-dd').format(selectedDay));

                    List<PeriodModel> updatedAllPeriodDates =
                        checkSelectedDay(allPeriodDates, modifiedSelectedDay);

                    setState(() {
                      allPeriodDates = updatedAllPeriodDates;
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      for (var period in allPeriodDates) {
                        if (period.actualStartDate != null &&
                            period.actualStartDate != null &&
                            day.isAfter(period.actualStartDate!) &&
                            day.isBefore(period.actualEndDate!
                                .add(const Duration(days: 1)))) {
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
                                child: Icon(Icons.circle_rounded,
                                    color: Colors.amber),
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
                            child: Icon(Icons.circle_outlined,
                                color: Colors.amber),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  saveAllPeriodDates(allPeriodDates);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 80),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
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

//기존 allPeriodDates 데이터 복사해서 사용

//A의 경우
//처음 선택한 날짜(A)가 실제시작일과 실제종료일 사이의 날짜가 아니며 && 7일 이전 이후 날짜가 아니라면
// 1. 다음 선택한 날짜(B)가 실제시작일과 실제종료일 사이의 날짜가 아니며 && 7일 이전 이후 날짜가 아니며 && 처음 선택한 날짜(A)의 7일 이내의 날짜라면
// 1-1. 날짜를 비교해서 빠른 날짜를 시작일, 느린 날짜를 종료일로 설정 -> 새로운 주기 생성
// 2. 다음 선택한 날짜(B)가 없을 경우 처음 선택한 날짜를 종료일로 설정 -> 새로운 주기 생성
// 3. 다음 선택한 날짜(B)가 처음 선택한 날짜(A)의 7일 이후의 날짜라면 처음 선택한 날짜(A)를 종료일로 설정 -> 새로운 주기 설정

//todo: periodcycle, periodlength, 7일(평균 생리일수) 동적으로 계산
//선택한 날짜가 실제시작일과 실제종료일 사이의 날짜가 아니며 && 시작일 이전 7일 이내의 날짜라면
// 1. 선택한 날짜를 실제시작일로 수정
// 2. 다음 선택한 날짜는 새로운 시작일로 기록
// 2-1. 다다음에 선택한 날짜가 7일 이내의 날짜라면 시작일-종료일로 설정 -> 새로운 주기 설정

//선택한 날짜가 실제기록일과 실제종료일 사이의 날짜가 아니며 && 시작일 이후 7일 이내의 날짜라면
//1. 선택한 날짜를 실제종료일로 수정
//2. 다음 선택한 날짜는 새로운 시작일로 기록
// 2-1. 다다음에 선택한 날짜가 7일 이내의 날짜라면 시작일-종료일로 설정 -> 새로운 주기 설정

//c-1의 경우
//실제시작일을 클릭했을 경우
//실제종료일 이전일 경우 실제시작일 = 실제시작일+1 기록
//실제종료일 이후일 경우 null

//실제종료일을 클릭했을 경우
//실제시작일 이전이면 실제종료일 = 실제종료일-1 기록

//c-2의 경우
//실제시작일과 실제종료일 사이의 값을 선택했을 경우 -> 기존 값 유지

//c-3의 경우
//클릭한 날짜가 실제시작일 7일 이전 날짜일 경우 실제시작일 = 클릭한 날짜로 기록
//클릭한 날짜가 실제시작일 7일 이후 날짜일 경우 실제종료일 = 클릭한 날짜로 기록

//클릭한 날짜가 실제시작일 혹은 실제종료일이냐 -> c-1의 경우 적용
//클릭한 날짜가 실제시작일과 실제종료일 사이의 날짜냐 -> c-2의 경우 적용
//클릭한 날짜가 실제시작일 7일 이내 날짜냐 -> c-3의 경우 적용
//클릭한 날짜가 실제종료일 7일 이후의 날짜냐 -> A의 경우
//A의 경우에도 A을 기준 7일 이내의 다음 날짜가 선택되었을 시 비교해 시작일, 종료일 생성
//7일 이후의 날짜가 선택되면 처음 선택한 날짜가 시작일이자 종료일이 되며 해당 날짜로 다시 시작일 기준.
//7일 이후이자 실제시작일 7일 이내의 날짜에 해당될 경우 실제시작일 혹은 실제종료일 수정

//다음 선택이 없거나 시작일과 종료일 사이의 날짜라면 -> A의 경우 적용
