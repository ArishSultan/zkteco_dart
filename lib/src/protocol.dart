import 'dart:typed_data';

abstract class ZkProtocol {
  ///
  static Int8List encode(
    int command,
    int session,
    int reply, [
    Uint32List? data,
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
      calculateChecksum(checksumBytes.buffer.asUint8List()),
      Endian.little,
    );

    return packetBytes.buffer.asInt8List();
  }

  static decode() {}

  static int calculateChecksum(List<int> payload) {
    if (payload.length % 2 == 1) {
      payload = List.of(payload)..add(0);
    }

    var checksum = 0;
    for (var j = 1; j < payload.length; j += 2) {
      checksum += payload[j - 1] + (payload[j] << 8);
    }

    return ((checksum & 0xFFFF) + ((checksum & 0xffff0000) >> 16)) ^ 0xFFFF;
  }
}
