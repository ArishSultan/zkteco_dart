part of '../zkteco.dart';

String _truncatedStringFromBytes(List<int> bytes) {
  final endIndex = bytes.indexOf(0);

  return String.fromCharCodes(
    bytes.sublist(0, endIndex == -1 ? bytes.length : endIndex),
  );
}

DateTime _timestampToDate(num timestamp) {
  final second = timestamp % 60;
  timestamp = timestamp / 60;

  final minute = timestamp % 60;
  timestamp = timestamp / 60;

  final hour = timestamp % 24;
  timestamp = timestamp / 24;

  final day = timestamp % 31 + 1;
  timestamp = timestamp / 31;

  final month = timestamp % 12 + 1;
  timestamp = timestamp / 12;

  return DateTime(
    (timestamp + 2000).floor(),
    month.toInt(),
    day.toInt(),
    hour.toInt(),
    minute.toInt(),
    second.toInt(),
  );
}
