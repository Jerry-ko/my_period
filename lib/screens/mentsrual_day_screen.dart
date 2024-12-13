import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:my_period/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MentsrualDayScreen extends StatefulWidget {
  const MentsrualDayScreen({super.key});

  @override
  State<MentsrualDayScreen> createState() => _MentsrualDayScreenState();
}

class _MentsrualDayScreenState extends State<MentsrualDayScreen> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  late SharedPreferences prefs;

//todo: 메서드 컴포넌트
  initStartDatePrefs() async {
    prefs = await SharedPreferences.getInstance();
    final stringStartDate = prefs.getString('startDate');
    final dateTimeStartDate =
        stringStartDate != null ? DateTime.parse(stringStartDate) : null;

    if (dateTimeStartDate != null) {
      setState(() {
        startDate = dateTimeStartDate;
      });
    } else {
      await prefs.setString('startDate', DateTime.now().toIso8601String());
      setState(() {
        startDate = DateTime.now();
      });
    }
  }

  initEndDatePrefs() async {
    prefs = await SharedPreferences.getInstance();
    final stringEndDate = prefs.getString('endDate');
    final dateTimeEndDate =
        stringEndDate != null ? DateTime.parse(stringEndDate) : null;
    if (dateTimeEndDate != null) {
      setState(() {
        endDate = dateTimeEndDate;
      });
    } else {
      await prefs.setString('endDate', DateTime.now().toIso8601String());
      setState(() {
        endDate = DateTime.now();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initStartDatePrefs();
    initEndDatePrefs();
  }

  //todo: 메서드 추출
  void onStartCalenderTap(Widget child) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(top: false, child: child)),
    );
  }

  void onEndCalenderTap(Widget child) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(top: false, child: child)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      const Align(
                        child: Text(
                          '최근 생리일을 입력해주세요',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '시작일',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          // todo: 위젯으로 추출
                          GestureDetector(
                            onTap: () => onStartCalenderTap(
                              CupertinoDatePicker(
                                initialDateTime: startDate,
                                mode: CupertinoDatePickerMode.date,
                                use24hFormat: true,
                                onDateTimeChanged: (DateTime newTime) async {
                                  await prefs.setString(
                                      'startDate', newTime.toIso8601String());

                                  setState(() {
                                    startDate = newTime;
                                  });
                                },
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Icon(Icons.calendar_month),
                                    Text(
                                      '${startDate.year}년 ${startDate.month}월 ${startDate.day}일',
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      '변경',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          const Text(
                            '종료일',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          GestureDetector(
                            onTap: () => onEndCalenderTap(
                              CupertinoDatePicker(
                                initialDateTime: endDate,
                                minimumDate: startDate,
                                maximumDate: startDate.add(
                                  const Duration(days: 180),
                                ),
                                mode: CupertinoDatePickerMode.date,
                                use24hFormat: true,
                                onDateTimeChanged: (DateTime newTime) async {
                                  await prefs.setString(
                                      'endDate', newTime.toIso8601String());
                                  setState(() {
                                    endDate = newTime;
                                  });
                                },
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Icon(Icons.calendar_month),
                                    Text(
                                      '${endDate.year}년 ${endDate.month}월 ${endDate.day}일',
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      '변경',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomeScreen()));
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    '설정 완료',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
