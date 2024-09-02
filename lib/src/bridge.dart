part of '../zkteco.dart';

///
base class ZKDatagramBridge {
  ZKDatagramBridge(this.deviceAddress, [this.devicePort = 4370]);

  final int devicePort;
  final InternetAddress deviceAddress;

  Future<void> communicate(Commands command, List<int> data) async {
    _socket!.send(
      ZkProtocol.encode(command._, _sessionId, _messageId++),
      deviceAddress,
      devicePort,
    );

    while (await _socketReader!.moveNext()) {
      switch (_socketReader!.current) {
        case RawSocketEvent.closed:
        case RawSocketEvent.readClosed:
          // TODO: Create a proper message here;
          throw Exception('Socket has been closed and this one needs to read response');
        case RawSocketEvent.read:
          break;
        case RawSocketEvent.write:
          // continue since we need to wait for a `read` message.
          continue;
      }

      break;
    }

    final message = _socket!.receive();
    if (message != null) {
      message.data;
    }

    return null;
  }

  /// Binds a UDP socket to the provided host and port
  Future<void> bind(InternetAddress host, int port) async {
    _socket = await RawDatagramSocket.bind(host, port);
    _socketReader = StreamIterator<RawSocketEvent>(_socket!);
  }

  /// Closes the UDP socket and also disposes the socket reader
  Future<void> close() async {
    await _socketReader?.cancel();
    _socket?.close();

    _socketReader = null;
    _socket = null;
  }

  int _sessionId = 0;
  int _messageId = 0;

  RawDatagramSocket? _socket;
  StreamIterator<RawSocketEvent>? _socketReader;
}
