import 'package:flutter/cupertino.dart';

class PeriodModel {
  DateTime expectedStartDate;
  DateTime expectedEndDate;
  final DateTime? actualStartDate, actualEndDate;

  PeriodModel({
    required this.expectedStartDate,
    required this.expectedEndDate,
    this.actualStartDate,
    this.actualEndDate,
  });

  PeriodModel.fromJson(Map<String, dynamic> json)
      : expectedStartDate = DateTime.parse(json['expectedStartDate']),
        expectedEndDate = DateTime.parse(json['expectedEndDate']),
        actualStartDate = json['actualStartDate'],
        actualEndDate = json['actualEndDate'];

  Map<String, dynamic> toJson() {
    return {
      'expectedStartDate': expectedStartDate.toIso8601String(),
      'expectedEndDate': expectedEndDate.toIso8601String(),
      'actualStartDate': actualStartDate?.toIso8601String(),
      'actualEndDate': actualEndDate?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'PeriodModel{ expectedStartDate: $expectedStartDate, expectedEndDate: $expectedEndDate, actualStartDate: $actualStartDate, actualEndDate: $actualEndDate }';
  }
}

class PeriodCycleModel {
  int periodCycle;
  DateTime lastPeriodStartDate, lastPeriodEndDate;
  late int periodLength;
  late List<PeriodModel> allPeriodDates;

  PeriodCycleModel({
    required this.periodCycle,
    required this.lastPeriodStartDate,
    required this.lastPeriodEndDate,
  }) {
    periodLength = lastPeriodEndDate.difference(lastPeriodStartDate).inDays;
    allPeriodDates = makeAllPeriodDates(lastPeriodStartDate);
  }

  //메서드와 함수의 차이..?

  //예정시작일 계산
  DateTime getNextPeriodStartDate(DateTime currentStartDate) {
    return currentStartDate.add(Duration(days: periodCycle));
  }

  //예정종료일 계산
  DateTime getNextPeriodEndDate(DateTime startDate) {
    return startDate.add(Duration(days: periodLength));
  }

  //2029년까지 periodModelList 생성
  List<PeriodModel> makeAllPeriodDates(DateTime startDate) {
    List<PeriodModel> periodDates = [];
    DateTime currentStartDate = startDate;

    while (currentStartDate.year < 2030) {
      DateTime expectedStartDate = getNextPeriodStartDate(currentStartDate);
      DateTime expectedEndDate = getNextPeriodEndDate(expectedStartDate);
      PeriodModel data = PeriodModel(
          expectedStartDate: expectedStartDate,
          expectedEndDate: expectedEndDate);
      periodDates.add(data);
      currentStartDate = expectedStartDate;
    }
    return periodDates;
  }

  PeriodModel filterByNow(List<PeriodModel> allPeriodDates, DateTime now) {
    return allPeriodDates.firstWhere((element) =>
        element.expectedStartDate.add(const Duration(days: 10)).isBefore(now));
  }
}
