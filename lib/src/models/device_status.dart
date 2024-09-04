part of '../../zkteco.dart';

final class DeviceStatus {
  const DeviceStatus({
    required this.faceCount,
    required this.userCount,
    required this.adminCount,
    required this.faceCapacity,
    required this.userCapacity,
    required this.passwordCount,
    required this.remainingUsers,
    required this.fingerprintCount,
    required this.operationLogCount,
    required this.attendanceLogCount,
    required this.fingerprintCapacity,
    required this.attendanceLogCapacity,
    required this.remainingFingerprints,
    required this.remainingAttendanceLogs,
  });

  factory DeviceStatus._fromByteData(ByteData data) {
    return DeviceStatus(
      faceCount: data.getInt32(80, Endian.little),
      userCount: data.getInt32(16, Endian.little),
      adminCount: data.getInt32(48, Endian.little),
      faceCapacity: data.getInt32(88, Endian.little),
      userCapacity: data.getInt32(60, Endian.little),
      passwordCount: data.getInt32(52, Endian.little),
      remainingUsers: data.getInt32(72, Endian.little),
      fingerprintCount: data.getInt32(24, Endian.little),
      operationLogCount: data.getInt32(40, Endian.little),
      attendanceLogCount: data.getInt32(32, Endian.little),
      fingerprintCapacity: data.getInt32(56, Endian.little),
      attendanceLogCapacity: data.getInt32(64, Endian.little),
      remainingFingerprints: data.getInt32(68, Endian.little),
      remainingAttendanceLogs: data.getInt32(76, Endian.little),
    );
  }

  final int faceCount;
  final int userCount;
  final int adminCount;
  final int faceCapacity;
  final int userCapacity;
  final int passwordCount;
  final int remainingUsers;
  final int fingerprintCount;
  final int operationLogCount;
  final int attendanceLogCount;
  final int fingerprintCapacity;
  final int attendanceLogCapacity;
  final int remainingFingerprints;
  final int remainingAttendanceLogs;

  @override
  String toString() {
    return 'DeviceStatus('
        'faceCount: $faceCount, '
        'userCount: $userCount, '
        'adminCount: $adminCount, '
        'faceCapacity: $faceCapacity, '
        'userCapacity: $userCapacity, '
        'passwordCount: $passwordCount, '
        'remainingUsers: $remainingUsers, '
        'fingerprintCount: $fingerprintCount, '
        'operationLogCount: $operationLogCount, '
        'attendanceLogCount: $attendanceLogCount, '
        'fingerprintCapacity: $fingerprintCapacity, '
        'attendanceLogCapacity: $attendanceLogCapacity, '
        'remainingFingerprints: $remainingFingerprints, '
        'remainingAttendanceLogs: $remainingAttendanceLogs'
        ')';
  }
}
