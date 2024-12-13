import 'package:flutter/material.dart';
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
  // todo: 상수로 빼기
  final List<int> periodList = List.generate(31, (int index) => index + 20);

  int period = 28;
  int periodDays = 0;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  DateTime ovulationDay = DateTime.now();
  DateTime expectedPeriodDate = DateTime.now();
  int numberOfDaysLeft = 5;

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();

    setState(() {
      period = periodList[prefs.getInt('period')!];
      startDate = DateTime.parse(prefs.getString('startDate')!);
      endDate = DateTime.parse(prefs.getString('endDate')!);
      periodDays = endDate.difference(startDate).inDays;
      ovulationDay = startDate.add(Duration(days: period - 14));
      expectedPeriodDate = ovulationDay.add(const Duration(days: 14));
      numberOfDaysLeft = expectedPeriodDate.difference(DateTime.now()).inDays;
    });
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('period: $period');
    debugPrint('startDate: $startDate');
    debugPrint('endDate: $endDate');
    debugPrint('periodDays: $periodDays');
    debugPrint('ovulationDay: $ovulationDay');
    debugPrint('expectedDate: $expectedPeriodDate');
    debugPrint('left: $numberOfDaysLeft');

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
                  Text(
                    '$numberOfDaysLeft일 전',
                    style: const TextStyle(
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
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
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
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
