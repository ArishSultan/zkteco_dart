part of '../zkteco.dart';

///
base class ZkBridge {
  ZkBridge._(this.socket, this.deviceHost, this.devicePort) {
    _socketSubscription = socket.listen(_onSocketEvent);
  }

  ///
  final int devicePort;

  ///
  final InternetAddress deviceHost;

  ///
  final RawDatagramSocket socket;

  var _sessionId = 0;
  var _messageId = 0;
  final _pendingReplies = <int, Completer<Uint8List>>{};
  StreamSubscription<RawSocketEvent>? _socketSubscription;

  ///
  static Future<ZkBridge> create(InternetAddress host, int port) async {
    var localPort = 4370;
    const maxPort = 4390;

    while (localPort <= maxPort) {
      try {
        return ZkBridge._(
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, localPort),
          host,
          port,
        );
      } on SocketException catch (_) {
        localPort++;
      }
    }

    throw Exception('Unable to find an available port in range 4370-4390');
  }

  ///
  Future<void> dispose() async {
    await _socketSubscription?.cancel();
    socket.close();
  }

  ///
  Future<int> send(Command command, [List<int>? data]) async {
    _pendingReplies[_messageId] = Completer();
    socket.send(
      _encodeMessage(command._, _sessionId, _messageId, data),
      deviceHost,
      devicePort,
    );

    // increment message id to make it unique
    return _messageId++;
  }

  Future<Uint8List> receive(int messageId) async {
    return _pendingReplies[messageId]!.future;
  }

  Future<void> _onSocketEvent(RawSocketEvent event) async {
    switch (event) {
      case RawSocketEvent.closed:
      case RawSocketEvent.readClosed:
        break;
      case RawSocketEvent.write:
        // TODO: Handle this scenario since, we can not allow writing before the socket is ready.
        break;
      case RawSocketEvent.read:
        final datagram = socket.receive()!;
        final data = datagram.data.buffer.asByteData();

        final code = data.getUint16(0, Endian.little);
        final sessionId = data.getUint16(4, Endian.little);
        final messageId = data.getUint16(6, Endian.little);

        if (sessionId != _sessionId) {
          _sessionId = sessionId;
        }

        //TODO: Manage code here.
        print(messageId);

        _pendingReplies[messageId]!.complete(datagram.data.sublist(8));
        break;
    }
  }
}

Int8List _encodeMessage(
  int command,
  int session,
  int reply, [
  List<int>? data,
]) {
  final packetSize = 6 + (data?.length ?? 0);

  final packetBytes = ByteData(packetSize + 2);
  final checksumBytes = ByteData(packetSize);

  packetBytes
    ..setUint16(0, command, Endian.little)
    ..setUint16(4, session, Endian.little)
    ..setUint16(6, reply, Endian.little);

  checksumBytes
    ..setUint16(0, command, Endian.little)
    ..setUint16(2, session, Endian.little)
    ..setUint16(4, reply, Endian.little);

  if (data != null) {
    for (var i = 0; i < data.length; ++i) {
      packetBytes.setUint8(8 + i, data[i]);
      checksumBytes.setUint8(6 + i, data[i]);
    }
  }

  packetBytes.setUint16(
    2,
    _calculateChecksum(checksumBytes.buffer.asUint8List()),
    Endian.little,
  );

  return packetBytes.buffer.asInt8List();
}

int _calculateChecksum(List<int> payload) {
  if (payload.length % 2 == 1) {
    payload = List.of(payload)..add(0);
  }

  var checksum = 0;
  for (var j = 1; j < payload.length; j += 2) {
    checksum += payload[j - 1] + (payload[j] << 8);
  }

  return ((checksum & 0xFFFF) + ((checksum & 0xffff0000) >> 16)) ^ 0xFFFF;
}
