part of '../zkteco.dart';

///
final class Terminal {
  ///
  const Terminal._(this._bridge);

  final ZkBridge _bridge;

  int get port => _bridge.devicePort;

  InternetAddress get host => _bridge.deviceHost;

  ///
  static Future<Terminal> connect(InternetAddress address, int port) async {
    final bridge = await ZkBridge.create(address, port);

    await bridge.receive(await bridge.send(Command.connect));

    return Terminal._(bridge);
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
    final data = await _bridge.receive(await _bridge.send(Command.readStatus));

    if (data.length < 92) {
      throw Exception(
        'Insufficient data: expected at least 92 bytes, got ${data.length}',
      );
    }

    return DeviceStatus.fromByteData(data.buffer.asByteData());
  }

  Future<String> _readDeviceProperty(String propertyName) async {
    final data = await _bridge.receive(
      await _bridge.send(Command.readProperty, '~$propertyName'.codeUnits),
    );

    final strValue = String.fromCharCodes(data).split('=')[1];

    return strValue.substring(0, strValue.length - 1);
  }
}
