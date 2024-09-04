part of '../zkteco.dart';

/// This class represents a bridge to communicate with the ZKTeco device.
/// It handles the communication over UDP sockets, sending commands, and receiving responses.
class ZKTecoBridge {
  /// Creates a [ZKTecoBridge] instance by binding to a socket and initiating the connection.
  ZKTecoBridge._(this._socket, this._deviceHost, this._devicePort) {
    _socketSubscription = _socket.listen(_handleSocketEvent);
  }

  /// The port of the device to connect to.
  final int _devicePort;

  /// The IP address of the device.
  final InternetAddress _deviceHost;

  /// The socket used for communication.
  final RawDatagramSocket _socket;

  /// The current session ID for communication with the device.
  int _sessionId = 0;

  /// The current message ID for tracking requests.
  int _messageId = 0;

  ///
  final Map<int, Uint8List> _replyChunks = {};

  /// Pending replies that are waiting for responses from the device.
  final Map<int, Completer<Uint8List>> _pendingReplies = {};

  /// Subscription to listen for socket events.
  StreamSubscription<RawSocketEvent>? _socketSubscription;

  /// Factory method to create a [ZKTecoBridge] instance.
  /// It binds the UDP socket and retries on different ports if needed.
  static Future<ZKTecoBridge> create(InternetAddress host, int port) async {
    var localPort = 4370;
    const maxPort = 4390;

    while (localPort <= maxPort) {
      try {
        return ZKTecoBridge._(
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

  /// Disposes the resources used by the bridge, including socket subscription and closing the socket.
  Future<void> dispose() async {
    await _socketSubscription?.cancel();

    // Complete all the pending replies with no-data
    for (final item in _pendingReplies.values) {
      item.complete(Uint8List(0));
    }

    _socket.close();
  }

  int send(Command command, [List<int>? data]) {
    // Register a pending reply for this message.
    _pendingReplies[_messageId] = Completer();

    _socket.send(
      _encodeMessage(command._, _sessionId, _messageId, data),
      _deviceHost,
      _devicePort,
    );

    return _messageId++;
  }

  /// Receives the response for the given [messageId].
  Future<Uint8List> receive(int messageId) async {
    final data = await _pendingReplies[messageId]!.future;

    // remove this from pending responses;
    _pendingReplies.remove(messageId);

    return data;
  }

  Future<Uint8List> sendAndReceive(Command command, [List<int>? data]) async {
    return receive(send(command, data));
  }

  /// Handles socket events like receiving data or connection closure.
  Future<void> _handleSocketEvent(RawSocketEvent event) async {
    switch (event) {
      case RawSocketEvent.closed:
      case RawSocketEvent.readClosed:
        return dispose();
      case RawSocketEvent.write:
        // TODO: Handle write events if necessary.
        break;
      case RawSocketEvent.read:
        // do nothing here;
        break;
    }

    final datagram = _socket.receive();
    if (datagram == null) {
      // since nothing was received;
      return;
    }

    final byteData = datagram.data.buffer.asByteData();

    final replyCode = byteData.getUint16(0, Endian.little);
    final messageId = byteData.getUint16(6, Endian.little);

    // Change the current session id since it is device dependent.
    _sessionId = byteData.getUint16(4, Endian.little);

    var replyData = datagram.data.sublist(8);
    switch (replyCode) {
      // This code determines if the request was successfully completed.
      case 2000:
      case 2005:
        // check if we have chunks from previous streams;
        if (_replyChunks.containsKey(messageId)) {
          if (replyData.isNotEmpty) {
            replyData = Uint8List.fromList(
              _replyChunks[messageId]!.followedBy(replyData).toList(),
            );
          } else {
            replyData = _replyChunks[messageId]!;
          }

          _replyChunks.remove(messageId);
        }

        _pendingReplies[messageId]!.complete(replyData);
        break;

      // This code determines if there was an error while processing the request.
      case 2001:
        // TODO: Make this error better.
        return _pendingReplies[messageId]!.completeError(replyData);

      // This code determines that the device is preparing data and it will be
      // sent in chunks.
      case 1500:
        _replyChunks[messageId] = replyData;
        break;

      // This code determines that this reply is one of the chunks from previous
      // requests. sent after reply code `1500`.
      case 1501:
        _replyChunks[messageId] = Uint8List.fromList(
          _replyChunks[messageId]!.followedBy(replyData).toList(),
        );
    }
  }
}

Int8List _encodeMessage(
  int command,
  int sessionId,
  int messageId, [
  List<int>? data,
]) {
  final packetSize = 6 + (data?.length ?? 0);
  final packetBytes = ByteData(packetSize + 2);
  final checksumBytes = ByteData(packetSize);

  packetBytes
    ..setUint16(0, command, Endian.little)
    ..setUint16(4, sessionId, Endian.little)
    ..setUint16(6, messageId, Endian.little);

  checksumBytes
    ..setUint16(0, command, Endian.little)
    ..setUint16(2, sessionId, Endian.little)
    ..setUint16(4, messageId, Endian.little);

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
