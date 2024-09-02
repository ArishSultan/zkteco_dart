import 'dart:async';
import 'dart:io';

import 'package:zkteco/src/protocol.dart';

part 'src/command.dart';
part 'src/bridge.dart';

// class A extends ZKDatagramBridge {
// }

// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
//
// final class ZKTeco {
//   ZKTeco(this.host, [this.port = 4370]);
//
//   final int port;
//   final String host;
//
//   Future<void> connect() async {
//     await _bridge.connect((await InternetAddress.lookup(host)).first, port);
//   }
//
//   Future<void> disconnect() async {
//     await _bridge.disconnect();
//   }
//
//   // Performs all the low level communication
//   final _bridge = _QueuedDatagramBridge();
// }
//
// final class _QueuedDatagramBridge {
//   int messagesCount = 0;
//   int sessionIdentifier = 0;
//
//   RawDatagramSocket? _socket;
//   StreamIterator<RawSocketEvent>? _socketReader;
//
//   ///
//   Future<void> connect(InternetAddress host, int port) async {
//     _socket = await RawDatagramSocket.bind(host, port);
//     _socketReader = StreamIterator<RawSocketEvent>(_socket!);
//   }
//
//   ///
//   Future<void> disconnect() async {
//     await _socketReader?.cancel();
//     _socket?.close();
//
//     _socket = _socketReader = null;
//   }
//
//   ///
//   Future<void> comm(int command, List<int> data) async {
//     final encodedPacket = preparePacket(command, sessionIdentifier, messagesCount);
//
//     // increment the messages count to track all the messages, since each reply
//     // from device will be identifier with this value.
//     ++messagesCount;
//
//     _socket!.send(encodedPacket, _socket.address, port);
//   }
//
//   ///
//   static Int8List preparePacket(
//     int command,
//     int session,
//     int reply, [
//     Uint32List? data,
//   ]) {
//     final packetSize = 6 + (data?.length ?? 0);
//
//     final packetBytes = ByteData(packetSize + 2);
//     final checksumBytes = ByteData(packetSize);
//
//     packetBytes
//       ..setUint16(0, command, Endian.little)
//       ..setUint16(4, session, Endian.little)
//       ..setUint16(6, reply, Endian.little);
//
//     checksumBytes
//       ..setUint16(0, command, Endian.little)
//       ..setUint16(2, session, Endian.little)
//       ..setUint16(4, reply, Endian.little);
//
//     if (data != null) {
//       for (var i = 0; i < data.length; ++i) {
//         packetBytes.setUint8(8 + i, data[i]);
//         checksumBytes.setUint8(6 + i, data[i]);
//       }
//     }
//
//     packetBytes.setUint16(
//       2,
//       calculateChecksum(checksumBytes.buffer.asUint8List()),
//       Endian.little,
//     );
//
//     return packetBytes.buffer.asInt8List();
//   }
//
//   ///
//   static int calculateChecksum(List<int> payload) {
//     if (payload.length % 2 == 1) {
//       payload = List.of(payload)..add(0);
//     }
//
//     var checksum = 0;
//     for (var j = 1; j < payload.length; j += 2) {
//       checksum += payload[j - 1] + (payload[j] << 8);
//     }
//
//     return ((checksum & 0xFFFF) + ((checksum & 0xffff0000) >> 16)) ^ 0xFFFF;
//   }
// }
//
// void main() async {
//   // print(await ZKTeco('8.8.8.8000', 3000).connect());
// }
//
// // import 'dart:io';
// // import 'dart:typed_data';
// //
// // main() async {
// //   final socket = await RawDatagramSocket.bind('host', 0);
// //
// //   // socket.
// //   // socket.receive();
// //   print(preparePacket(1000, 0, 0));
// // }
// //
