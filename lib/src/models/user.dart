part of '../../zkteco.dart';

final class User {
  const User({
    required this.id,
    required this.name,
    required this.role,
    required this.password,
    required this.disabled,
    this.groupId = 0,
    this.timezone1 = 0,
    this.timezone2 = 0,
    this.timezone3 = 0,
    this.cardNumber = 0,
    this.isUserTimezone = 0,
    required this.serialNumber,
  });

  factory User.fromByteData(ByteData data) {
    final permissionToken = data.getUint8(2);

    return User(
      serialNumber: data.getUint16(0, Endian.little),
      disabled: permissionToken & 0x1 == 1,
      role: switch ((permissionToken >> 1) & 0x7) {
        0x1 => UserRole.enroller,
        0x3 => UserRole.manager,
        0x7 => UserRole.admin,
        _ => UserRole.normal,
      },
      password: _truncatedStringFromBytes(data.buffer.asUint8List(3, 8)),
      name: _truncatedStringFromBytes(data.buffer.asUint8List(11, 24)),
      cardNumber: data.getUint32(35, Endian.little),
      groupId: data.getUint8(39),
      isUserTimezone: data.getUint16(40, Endian.little),
      timezone1: data.getUint16(42, Endian.little),
      timezone2: data.getUint16(44, Endian.little),
      timezone3: data.getUint16(46, Endian.little),
      id: _truncatedStringFromBytes(data.buffer.asUint8List(48, 9)),
    );
  }

  final String id;
  final String name;
  final String password;
  final UserRole role;

  ///
  final bool disabled;

  final int groupId;
  final int cardNumber;

  final int timezone1;
  final int timezone2;
  final int timezone3;
  final int isUserTimezone;

  final int serialNumber;

  @override
  String toString() {
    return 'User('
        'serialNumber: $serialNumber, '
        'disabled: $disabled, '
        'role: $role, '
        'password: $password, '
        'name: $name, '
        'cardNumber: $cardNumber, '
        'groupId: $groupId, '
        'isUserTimezone: $isUserTimezone, '
        'timezone1: $timezone1, '
        'timezone2: $timezone2, '
        'timezone3: $timezone3, '
        'id: $id'
        ')';
  }
}

enum UserRole { admin, normal, manager, enroller }
