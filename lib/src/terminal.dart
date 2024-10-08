part of '../zkteco.dart';

///
final class Terminal {
  ///
  const Terminal._(this._bridge);

  final ZKTecoBridge _bridge;

  ///
  static Future<Terminal> connect(InternetAddress address, int port) async {
    final bridge = await ZKTecoBridge.create(address, port);

    await bridge.sendAndReceive(Command.connect);

    return Terminal._(bridge);
  }

  ///
  Future<void> disconnect() {
    _bridge.send(Command.exit);
    return _bridge.dispose();
  }

  ///
  Future<String> get isOnlyRFMachine async =>
      _readDeviceProperty('IsOnlyRFMachine');

  ///
  Future<String> get productTime async => _readDeviceProperty('ProductTime');

  ///
  Future<String> get deviceName async => _readDeviceProperty('DeviceName');

  ///
  Future<String> get pin2Width async => _readDeviceProperty('PIN2Width');

  ///
  Future<String> get showState async => _readDeviceProperty('ShowState');

  ///
  Future<String> get ipAddress async => _readDeviceProperty('IPAddress');

  ///
  Future<String> get udpPort async => _readDeviceProperty('UDPPort');

  ///
  Future<String> get comKey async => _readDeviceProperty('COMKey');

  ///
  Future<String> get deviceId async => _readDeviceProperty('DeviceID');

  ///
  Future<String> get isDHCP async => _readDeviceProperty('DHCP');

  ///
  Future<String> get dns async => _readDeviceProperty('DNS');

  ///
  Future<String> get isEnableProxyServer async =>
      _readDeviceProperty('EnableProxyServer');

  ///
  Future<String> get proxyServerIP async =>
      _readDeviceProperty('ProxyServerIP');

  ///
  Future<String> get proxyServerPort async =>
      _readDeviceProperty('ProxyServerPort');

  ///
  Future<String> get isDaylightSavingTime async =>
      _readDeviceProperty('DaylightSavingTime');

  ///
  Future<String> get language async => _readDeviceProperty('Language');

  ///
  Future<String> get isLockPowerKey async =>
      _readDeviceProperty('LockPowerKey');

  ///
  Future<String> get isVoiceOn async => _readDeviceProperty('VoiceOn');

  ///
  Future<String> get platform async => _readDeviceProperty('Platform');

  ///
  Future<String> get serialNumber async => _readDeviceProperty('SerialNumber');

  ///
  Future<String> get mac async => _readDeviceProperty('MAC');

  ///
  Future<String> get faceVersion async => _readDeviceProperty('ZKFaceVersion');

  ///
  Future<String> get fingerprintVersion async =>
      _readDeviceProperty('ZKFPVersion');

  ///
  Future<String> get oemVendor async => _readDeviceProperty('OEMVendor');

  ///
  Future<bool> get workCode async =>
      (await _readDeviceProperty('WorkCode')) == '1';

  ///
  Future<DeviceStatus> get deviceStatus async {
    final data = await _bridge.receive(_bridge.send(Command.readStatus));

    if (data.length < 92) {
      throw Exception(
        'Insufficient data: expected at least 92 bytes, got ${data.length}',
      );
    }

    return DeviceStatus._fromByteData(data.buffer.asByteData());
  }

  Future<List<User>> get users =>
      _readRecordsList(Command.readUsers, 72, User.fromByteData);

  Future<List<Attendance>> get attendances =>
      _readRecordsList(Command.readAttendances, 40, Attendance.fromByteData);

  Future<String> _readDeviceProperty(String propertyName) async {
    final data = await _bridge.receive(
      _bridge.send(Command.readProperty, '~$propertyName'.codeUnits),
    );

    final strValue = String.fromCharCodes(data).split('=')[1];

    return strValue.substring(0, strValue.length - 1);
  }

  Future<List<T>> _readRecordsList<T>(
    Command command,
    int recordSize,
    T Function(ByteData data) creator,
  ) async {
    final data = await _bridge.sendAndReceive(command);
    final byteData = data.sublist(8).buffer.asByteData();

    final records = <T>[];
    final recordsCount = byteData.getUint32(0, Endian.little) ~/ recordSize;
    for (var i = 0; i < recordsCount; ++i) {
      final offset = 12 + i * recordSize;
      final userBytes = data.sublist(offset, offset + recordSize);

      records.add(creator(userBytes.buffer.asByteData()));
    }

    return records;
  }
}
