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

  DateTime now = DateTime.now();
  int dDay = 0;
  bool isStart = false;
  PeriodModel? currentPeriod;

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('history');
    List<dynamic> jsonList = jsonDecode(jsonString!);
    List<PeriodModel> history =
        jsonList.map((jsonItem) => PeriodModel.fromJson(jsonItem)).toList();

    setState(() {
      currentPeriod = filterByNow(history, DateTime.now());
      dDay = calculateDaysUntilExpectedStartDate(
          currentPeriod?.expectedStartDate, now);
    });
  }

  PeriodModel filterByNow(List<PeriodModel> list, DateTime now) {
    print('now $now');
    return list.firstWhere((element) =>
        now.isBefore(element.expectedStartDate.add(const Duration(days: 10))));
  }

  int calculateDaysUntilExpectedStartDate(
      DateTime? expectedStartDate, DateTime now) {
    if (expectedStartDate != null) {
      print('expectedStartDate $expectedStartDate');
      return expectedStartDate.difference(now).inDays;
    }
    return 0;
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
                height: 150,
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
                  dDay > 0
                      ? Text(
                          '$dDay일 전',
                          style: const TextStyle(
                            fontSize: 28,
                          ),
                        )
                      : Text(
                          '${-dDay}일 지남',
                          style: const TextStyle(
                            fontSize: 28,
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
                    child: GestureDetector(
                      onTap: () => {},
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
              TableCalendar(
                locale: 'ko_KR',
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2029, 12, 31),
                focusedDay: DateTime.now(),
                rowHeight: 100,
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
