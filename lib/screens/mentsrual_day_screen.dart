import 'package:flutter/material.dart';

class MentsrualDayScreen extends StatefulWidget {
  const MentsrualDayScreen({super.key});

  @override
  State<MentsrualDayScreen> createState() => _MentsrualDayScreenState();
}

class _MentsrualDayScreenState extends State<MentsrualDayScreen> {
  late DateTime selectedStartDate = DateTime.now();
  late DateTime selectedEndDate = DateTime.now();

  //todo: 메서드 추출
  Future<void> onStartCalenderTap(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selected != null) {
      setState(() {
        selectedStartDate = selected;
      });
    } else {
      setState(() {
        selectedStartDate = DateTime.now();
      });
    }
  }

  Future<void> onEndCalenderTap(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selected != null) {
      setState(() {
        selectedEndDate = selected;
      });
    } else {
      setState(() {
        selectedEndDate = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        height: 150,
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
                            onTap: () => onStartCalenderTap(context),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
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
                                      '${selectedStartDate.year}년 ${selectedStartDate.month}월 ${selectedStartDate.day}일',
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
                            onTap: () => onEndCalenderTap(context),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
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
                                      '${selectedEndDate.year}년 ${selectedEndDate.month}월 ${selectedEndDate.day}일',
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
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    '설정 완료',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
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
