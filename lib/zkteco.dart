import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

part 'src/bridge.dart';

part 'src/command.dart';

part 'src/helpers.dart';

part 'src/terminal.dart';

part 'src/models/attendance.dart';

part 'src/models/device_status.dart';

part 'src/models/user.dart';

void main() async {
  // final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 9000);
  // socket.listen((event) {
  //   if (event == RawSocketEvent.read) {
  //     print(socket.receive()?.data);
  //   }
  // });
  //
  // // [232, 3, 23, 252, 0, 0, 0, 0]
  //
  // print(socket.address);
  // print(socket.port);

  final terminal =
      await Terminal.connect(InternetAddress('192.168.0.201'), 4370);
  // print(await terminal.deviceStatus);
  print(await terminal.attendances);
}
//
// // class A extends ZKDatagramBridge {
// // }
//
// // import 'dart:async';
// // import 'dart:io';
// // import 'dart:typed_data';
// //
// // final class ZKTeco {
// //   ZKTeco(this.host, [this.port = 4370]);
// //
// //   final int port;
// //   final String host;
// //
// //   Future<void> connect() async {
// //     await _bridge.connect((await InternetAddress.lookup(host)).first, port);
// //   }
// //
// //   Future<void> disconnect() async {
// //     await _bridge.disconnect();
// //   }
// //
// //   // Performs all the low level communication
// //   final _bridge = _QueuedDatagramBridge();
// // }
// //
// // final class _QueuedDatagramBridge {
// //   int messagesCount = 0;
// //   int sessionIdentifier = 0;
// //
// //   RawDatagramSocket? _socket;
// //   StreamIterator<RawSocketEvent>? _socketReader;
// //
// //   ///
// //   Future<void> connect(InternetAddress host, int port) async {
// //     _socket = await RawDatagramSocket.bind(host, port);
// //     _socketReader = StreamIterator<RawSocketEvent>(_socket!);
// //   }
// //
// //   ///
// //   Future<void> disconnect() async {
// //     await _socketReader?.cancel();
// //     _socket?.close();
// //
// //     _socket = _socketReader = null;
// //   }
// //
// //   ///
// //   Future<void> comm(int command, List<int> data) async {
// //     final encodedPacket = preparePacket(command, sessionIdentifier, messagesCount);
// //
// //     // increment the messages count to track all the messages, since each reply
// //     // from device will be identifier with this value.
// //     ++messagesCount;
// //
// //     _socket!.send(encodedPacket, _socket.address, port);
// //   }
// //
// ///
// Uint8List preparePacket(
//   int command,
//   int session,
//   int reply, [
//   Uint32List? data,
// ]) {
//   final packetSize = 6 + (data?.length ?? 0);
//
//   final packetBytes = ByteData(packetSize + 2);
//   final checksumBytes = ByteData(packetSize);
//
//   packetBytes
//     ..setUint16(0, command, Endian.little)
//     ..setUint16(4, session, Endian.little)
//     ..setUint16(6, reply, Endian.little);
//
//   checksumBytes
//     ..setUint16(0, command, Endian.little)
//     ..setUint16(2, session, Endian.little)
//     ..setUint16(4, reply, Endian.little);
//
//   if (data != null) {
//     for (var i = 0; i < data.length; ++i) {
//       packetBytes.setUint8(8 + i, data[i]);
//       checksumBytes.setUint8(6 + i, data[i]);
//     }
//   }
//
//   packetBytes.setUint16(
//     2,
//     calculateChecksum(checksumBytes.buffer.asUint8List()),
//     Endian.little,
//   );
//
//   return packetBytes.buffer.asUint8List();
// }
//
//
// decodePackets(Uint8List rawReply) {
//   final data = rawReply.buffer.asByteData();
//
//   return (
//     data.getUint16(0, Endian.little),
//     data.getUint16(4, Endian.little),
//     data.getUint16(6, Endian.little),
//     rawReply.sublist(8)
//   );
// }
//
// void main() {
//   print(preparePacket(
//       1000, 999, 888, Uint32List.fromList([1, 1, 1, 1, 1, 1, 1])));
//   print(decodePackets(Uint8List.fromList([232, 3, 180, 241, 231, 3, 120, 3, 1, 1, 1, 1, 1, 1, 1])));
// }
// //
// // void main() async {
// //   // print(await ZKTeco('8.8.8.8000', 3000).connect());
// // }
// //
// // // import 'dart:io';
// // // import 'dart:typed_data';
// // //
// // // main() async {
// // //   final socket = await RawDatagramSocket.bind('host', 0);
// // //
// // //   // socket.
// // //   // socket.receive();
// // //   print(preparePacket(1000, 0, 0));
// // // }
// // //
