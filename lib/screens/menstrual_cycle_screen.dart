import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_period/screens/mentsrual_day_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenstrualCycle extends StatefulWidget {
  const MenstrualCycle({super.key});

  @override
  State<MenstrualCycle> createState() => _MenstrualCycleState();
}

class _MenstrualCycleState extends State<MenstrualCycle> {
  late SharedPreferences prefs;
  final List<int> periodList = List.generate(31, (int index) => index + 20);
  late FixedExtentScrollController _scrollController;
  int selectedPeriodIndex = 8;
  bool isLoading = true;

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final int? period = prefs.getInt('period');

    if (period != null) {
      int periodIndex = periodList.indexOf(period);
      setState(() {
        _scrollController =
            FixedExtentScrollController(initialItem: periodIndex);
        selectedPeriodIndex = periodIndex;
        isLoading = false;
      });
      return;
    }
    await prefs.setInt('period', 28);
  }

  @override
  void initState() {
    super.initState();
    _scrollController =
        FixedExtentScrollController(initialItem: selectedPeriodIndex);
    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CircularProgressIndicator();
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 150,
                  ),
                  const Text(
                    '평균 월경주기를 입력해주세요',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 70,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.ideographic,
                    children: [
                      Text('${periodList[selectedPeriodIndex]}',
                          style: const TextStyle(
                            fontSize: 30,
                          )),
                      const Text('일',
                          style: TextStyle(
                            fontSize: 30,
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    height: 200,
                    child: CupertinoPicker(
                        magnification: 1.22,
                        squeeze: 1.2,
                        useMagnifier: true,
                        itemExtent: 32.0,
                        scrollController: _scrollController,
                        onSelectedItemChanged: (int selectedItem) async {
                          await prefs.setInt(
                              'period', periodList[selectedItem]);
                          setState(() {
                            selectedPeriodIndex = selectedItem;
                          });
                        },
                        children: List.generate(periodList.length, (int index) {
                          return Text('${periodList[index]}');
                        })),
                  ),
                  const SizedBox(
                    height: 70,
                  ),
                  const Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '평균 월경주기를 잘 모르겠다면,',
                          ),
                          Text(
                            '28일을 선택해주세요',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MentsrualDayScreen(),
                ),
              ),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    '다음',
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
