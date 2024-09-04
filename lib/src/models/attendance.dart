part of '../../zkteco.dart';

final class Attendance {
  const Attendance({
    required this.state,
    required this.userId,
    required this.userSn,
    required this.createdAt,
    required this.verificationType,
  });

  factory Attendance.fromByteData(ByteData data) {
    return Attendance(
      userSn: data.getUint16(0, Endian.little),
      userId: _truncatedStringFromBytes(data.buffer.asUint8List(2, 9)),
      verificationType: VerificationType.fromCode(data.getUint8(26)),
      createdAt: _timestampToDate(data.getUint32(27, Endian.little)),
      state: AttendanceState.fromCode(data.getUint8(31)),
    );
  }

  ///
  final int userSn;

  ///
  final String userId;

  ///
  final DateTime createdAt;

  ///
  final AttendanceState state;

  ///
  final VerificationType verificationType;

  @override
  String toString() {
    return 'Attendance('
        'state: $state, '
        'userId: $userId, '
        'userSn: $userSn, '
        'createdAt: $createdAt, '
        'verificationType: $verificationType'
        ')';
  }
}

///
enum AttendanceState {
  ///
  checkIn,

  ///
  checkOut,

  ///
  breakIn,

  ///
  breakOut,

  ///
  overtimeIn,

  ///
  overtimeOut;

  factory AttendanceState.fromCode(int code) {
    return switch (code) {
      0 => checkIn,
      1 => checkOut,
      2 => breakOut,
      3 => breakIn,
      4 => overtimeIn,
      5 => overtimeOut,
      _ => throw Exception('Invalid AttendanceState ($code)'),
    };
  }
}

///
enum VerificationType {
  ///
  password,

  ///
  fingerprint,

  ///
  rfCard;

  factory VerificationType.fromCode(int code) {
    return switch (code) {
      0 => password,
      1 => fingerprint,
      2 => rfCard,
      _ => throw Exception('Invalid VerificationType ($code)'),
    };
  }
}
