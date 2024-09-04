part of '../zkteco.dart';

String _truncatedStringFromBytes(List<int> bytes) {
  final endIndex = bytes.indexOf(0);

  return String.fromCharCodes(
    bytes.sublist(0, endIndex == -1 ? bytes.length : endIndex),
  );
}
