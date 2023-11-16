import 'package:cloud_firestore/cloud_firestore.dart';

class computeTime {
  late String computedTime;
  Timestamp currentTime = Timestamp.now();
  late int hour;
  late int days;
  late int hours;
  late int minutes;
  late int seconds;
  DateTime current = Timestamp.now().toDate();
  late DateTime deadLineDate;
  late Duration difference;

  String compute(Timestamp deadLine) {
    if (deadLine.compareTo(currentTime) == 0) {
      computedTime = 'TIMES ARE EQUAL';
    } else if (deadLine.compareTo(currentTime) < 0) {
      computedTime = 'DEADLINE HAS PASSED';
    } else if (deadLine.compareTo(currentTime) > 0) {
      deadLineDate = deadLine.toDate();
      difference = deadLineDate.difference(current);
      days = difference.inDays;
      hour = difference.inHours;
      minutes = difference.inMinutes;
      seconds = difference.inSeconds;
      if (days > 1) {
        computedTime = '$days days left';
      } else if (days > 0) {
        computedTime = '$days day left';
      } else if (hour > 1) {
        computedTime = '$hour hours left';
      } else if (hour > 0) {
        computedTime = '$hour hour left';
      } else if (minutes > 1) {
        computedTime = '$minutes minutes left';
      } else if (minutes > 0) {
        computedTime = '$minutes minute left';
      } else if (minutes > 1) {
        computedTime = '$seconds seconds left';
      } else {
        computedTime = '$seconds second left';
      }
    }

    return computedTime;
  }
}
