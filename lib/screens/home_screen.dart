import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_period/models/period_cycle_model.dart';
import 'package:my_period/screens/edit_period_date.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;
  late SharedPreferences prefs;

  List<PeriodModel> allPeriodDates = [];
  List<Map<String, DateTime?>> selectedRanges = [];
  PeriodModel? currentPeriodDate;
  int currentPeriodIndex = 0;

  DateTime now = DateTime.now();
  int dDay = 0;

  int calculatePeriodDays(PeriodModel periodModel, DateTime now) {
    if (periodModel.actualStartDate == null) {
      return periodModel.expectedStartDate.difference(now).inDays;
    } else {
      return periodModel.actualStartDate!.difference(now).inDays + 1;
    }
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('history');
    List<dynamic> jsonList = jsonDecode(jsonString!);

    setState(() {
      allPeriodDates =
          jsonList.map((jsonItem) => PeriodModel.fromJson(jsonItem)).toList();
      selectedRanges = makeSelectedRanges(allPeriodDates);
      currentPeriodDate =
          PeriodCycleModel.filterByNow(allPeriodDates, DateTime.now());
      currentPeriodIndex = allPeriodDates.indexOf(currentPeriodDate!);
      dDay = calculatePeriodDays(currentPeriodDate!, now);
    });
  }

  onStartTab(List<PeriodModel> allPeriodDates, int currentPeriodIndex,
      DateTime now) async {
    List<PeriodModel> updatePeriodDates =
        recordActualStartDate(allPeriodDates, currentPeriodIndex, now);
    print('origin $updatePeriodDates');

    DateTime expectedStartDate =
        allPeriodDates[currentPeriodIndex].expectedStartDate;

    //예정일과 시작일 다를 경우
    //PeriodCycleModel 새로 생성 후 기존 데이터에 삽입

    if (expectedStartDate != now) {
      int periodCycle = prefs.getInt('period') ?? 28;
      List<PeriodModel> recalculatedPeriods =
          updatePeriodCycleModel(periodCycle, now);
      updatePeriodDates.removeRange(
          currentPeriodIndex + 1, updatePeriodDates.length);
      updatePeriodDates.insertAll(
          updatePeriodDates.length, recalculatedPeriods);
    }

    List<Map<String, dynamic>> jsonList =
        updatePeriodDates.map((item) => item.toJson()).toList();
    await prefs.setString('history', jsonEncode(jsonList));

    List<Map<String, DateTime?>> updateSelectedRanges =
        makeSelectedRanges(updatePeriodDates);

    setState(() {
      allPeriodDates = updatePeriodDates;
      selectedRanges = updateSelectedRanges;
      currentPeriodDate = PeriodCycleModel.filterByNow(updatePeriodDates, now);
      currentPeriodIndex = updatePeriodDates.indexOf(currentPeriodDate!);
      dDay = calculatePeriodDays(currentPeriodDate!, now);
    });
  }

  List<Map<String, DateTime?>> makeSelectedRanges(
      List<PeriodModel> allPeriodDates) {
    List<Map<String, DateTime?>> selectedRanges = allPeriodDates.map((period) {
      return {
        'start': period.actualStartDate ??
            (DateTime.now().isBefore(
                    period.expectedStartDate.add(const Duration(days: 10)))
                ? period.expectedStartDate
                : null),
        'end': period.actualEndDate ??
            (DateTime.now().isBefore(
                    period.expectedStartDate.add(const Duration(days: 10)))
                ? period.expectedEndDate
                : null),
      };
    }).toList();

    return selectedRanges;
  }

  List<PeriodModel> updatePeriodCycleModel(int periodCycle, DateTime now) {
    return PeriodCycleModel(
            periodCycle: periodCycle,
            lastPeriodStartDate: now,
            lastPeriodEndDate: PeriodCycleModel.getNextPeriodEndDate(now))
        .makeAllPeriodDates(now);
  }

  List<PeriodModel> recordActualStartDate(
      List<PeriodModel> allPeriodDates, int currentPeriodIndex, DateTime now) {
    return allPeriodDates.map((item) {
      if (allPeriodDates.indexOf(item) == currentPeriodIndex) {
        return item.copyWith(
            actualStartDate: now,
            actualEndDate: PeriodCycleModel.getNextPeriodEndDate(now));
      }
      return item;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: currentPageIndex,
        onDestinationSelected: (value) {
          setState(() {
            currentPageIndex = value;
          });
        },
        destinations: [
          NavigationDestination(
              selectedIcon: Icon(
                Icons.home_filled,
                color: Theme.of(context).primaryColor,
              ),
              icon: const Icon(Icons.home_filled),
              label: 'home'),
          NavigationDestination(
              selectedIcon: Icon(
                Icons.calendar_month,
                color: Theme.of(context).primaryColor,
              ),
              icon: const Icon(Icons.calendar_month),
              label: 'calendar')
        ],
      ),
      body: [
        Center(
          child: Column(
            children: [
              const SizedBox(
                height: 300,
              ),
              Column(
                children: [
                  const Text(
                    '생리예정일',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Offstage(
                    offstage: !(currentPeriodDate?.actualStartDate != null),
                    child: Text(
                      '$dDay일째',
                      style: const TextStyle(
                        fontSize: 28,
                      ),
                    ),
                  ),
                  Offstage(
                    offstage: !(currentPeriodDate?.actualStartDate == null &&
                        dDay > 0),
                    child: Text(
                      '$dDay일 전',
                      style: const TextStyle(
                        fontSize: 28,
                      ),
                    ),
                  ),
                  Offstage(
                    offstage: !(currentPeriodDate?.actualStartDate == null &&
                        dDay < 0),
                    child: Text(
                      '$dDay일 지남',
                      style: const TextStyle(
                        fontSize: 28,
                      ),
                    ),
                  ),
                  Offstage(
                    offstage: !(currentPeriodDate?.actualStartDate == null &&
                        dDay == 0),
                    child: const Text(
                      '예정일',
                      style: TextStyle(
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditPeriodDate(),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Visibility(
                          visible: currentPeriodDate?.actualStartDate == null,
                          child: GestureDetector(
                            onTap: () => onStartTab(
                                allPeriodDates, currentPeriodIndex, now),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  '생리시작',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: currentPeriodDate?.actualStartDate != null,
                          child: GestureDetector(
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditPeriodDate(),
                                  fullscreenDialog: true,
                                ),
                              )
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  '생리기간 편집',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(
                height: 80,
              ),
              TableCalendar(
                locale: 'ko_KR',
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2029, 12, 31),
                focusedDay: DateTime.now(),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    for (var range in selectedRanges) {
                      if (range['start'] != null &&
                          day.isAfter(range['start']!) &&
                          range['end'] != null &&
                          day.isBefore(
                              range['end']!.add(const Duration(days: 1)))) {
                        return Container(
                          width: 50,
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: Text(day.day.toString())),
                        );
                      }
                    }
                    return null;
                  },
                ),
                rowHeight: 90,
                headerStyle: const HeaderStyle(
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                  ),
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    '생리기간 편집',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ][currentPageIndex],
    );
  }
}


  // 캘린더
  // 오늘이 생리예정일+10일까지는 생리예정일 기록, 이후에는 실제기록일 null로 설정 후 표시
  // 예정기록일과 실제기록일이 있을 시 실제기록일 기준
  // 시작하기 누르면 해당일 기준 종료일까지 세팅해서 들어감

  // 편집 시에는 시작일이 있고 종료일이 없을 시 종료일에 시작일 넣기
  // 편집 시에 모두 없을 경우에는 null 처리 후 selectedRanges 범위에서 삭제

  //생리예정일 12월 15일
  //12월 25일까지는 예정일 표시 (실제기록일 없을 시)
  //실제기록일 있을 시 실제기록일 표시
  //날짜가 예정일+10이 지나면 실제 기록일 표시, 없으면 null로 표시
  //day가 예정일+10일 이전이면 예정일, 혹 실제기록일 있음 실제기록인
  //day가 예정일+10이후이면 생릭실제기록일 표시


  // 시작하기 버튼 누르면 이벤트
  // 생리하기 텍스트가 '생리기간 편집'으로 바뀐다
  // 생리의 실제시작일이 기록된다
  // 예정생리일과 실제 생리일이 다를 경우 해당 생리일을 시작으로 다음달부터의 예정일을 다시 계산한다

  // 캘린더
  // 오늘이 생리예정일+10일까지는 생리예정일 기록, 이후에는 실제기록일 null로 설정 후 표시
  // 예정기록일과 실제기록일이 있을 시 실제기록일 기준
  // 시작하기 누르면 해당일 기준 종료일까지 세팅해서 들어감

  // 편집 시에는 시작일이 있고 종료일이 없을 시 종료일에 시작일 넣기
  // 편집 시에 모두 없을 경우에는 null 처리 후 selectedRanges 범위에서 삭제

