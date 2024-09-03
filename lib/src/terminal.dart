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

  Future<DeviceStatus> get deviceStatus async {
    final data = Uint8List.fromList(
      await _bridge.receive(await _bridge.send(Command.getFreeSizes)),
    );

    if (data.length < 92) {
      throw Exception(
        'Insufficient data: expected at least 92 bytes, got ${data.length}',
      );
    }

    return DeviceStatus.fromByteData(data.buffer.asByteData());
  }

  ///
// Future<void> disconnect() {}
//
// Future<void> enableDevice() {}
//
// Future<void> disableDevice() {}
}
