import 'package:flutter/cupertino.dart';

class PeriodModel {
  DateTime? expectedStartDate, expectedEndDate, actualStartDate, actualEndDate;

  PeriodModel({
    this.expectedStartDate,
    this.expectedEndDate,
    this.actualStartDate,
    this.actualEndDate,
  });

  PeriodModel copyWith({
    required DateTime? actualStartDate,
    required DateTime? actualEndDate,
  }) {
    return PeriodModel(
        expectedStartDate: expectedStartDate,
        expectedEndDate: expectedEndDate,
        actualStartDate: actualStartDate,
        actualEndDate: actualEndDate);
  }

  PeriodModel.fromJson(Map<String, dynamic> json)
      : expectedStartDate = DateTime.parse(json['expectedStartDate']),
        expectedEndDate = DateTime.parse(json['expectedEndDate']),
        actualStartDate = json['actualStartDate'] != null
            ? DateTime.parse(json['actualStartDate'])
            : null,
        actualEndDate = json['actualEndDate'] != null
            ? DateTime.parse(json['actualEndDate'])
            : null;

  Map<String, dynamic> toJson() {
    return {
      'expectedStartDate': expectedStartDate?.toIso8601String(),
      'expectedEndDate': expectedEndDate?.toIso8601String(),
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
  static late int periodLength;

  PeriodCycleModel({
    required this.periodCycle,
    required this.lastPeriodStartDate,
    required this.lastPeriodEndDate,
  }) {
    periodLength = lastPeriodEndDate.difference(lastPeriodStartDate).inDays;
  }

  //메서드와 함수의 차이..?

  //예정시작일 계산
  DateTime getNextPeriodStartDate(DateTime currentStartDate) {
    return currentStartDate.add(Duration(days: periodCycle));
  }

  //예정종료일 계산
  static DateTime getNextPeriodEndDate(DateTime startDate) {
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

  static PeriodModel filterByNow(
      List<PeriodModel> allPeriodDates, DateTime now) {
    print('allPeriodDates, $allPeriodDates');
    print('now $now');
    return allPeriodDates.firstWhere((element) =>
        now.isBefore(element.expectedStartDate!.add(const Duration(days: 10))));
  }

  //생리실제시작일 기록, 생리실제종료일도 시작일 기준으로 기록
  //allPeriodDates에서 해당 아이템의 실제시작일과 실제 종료일 기록
  //예상일과 시작이리 다르다면,
  //allPeriodDates에서 해당 아이템 인덱스 찾기
  //해당 시작일 기준으로 2029년도까지 예상일 다시 계산
  //위의 리스트를 기존 리스트에 덮어쓰기 (아까 찾은 인덱스+1부터)

//??
  void recordActualStartDate(List<PeriodModel> allPeriodDates,
      PeriodModel currentPeriod, DateTime now) {
    allPeriodDates = allPeriodDates.map((el) {
      if (el == currentPeriod) {
        el.actualStartDate = now;
        el.actualEndDate = getNextPeriodEndDate(now);
      }
      return el;
    }).toList();
  }
}
