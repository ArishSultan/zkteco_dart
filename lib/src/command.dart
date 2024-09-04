part of '../zkteco.dart';

enum Command {
  connect(1000),
  exit(1001),
  enableDevice(1002),
  disableDevice(1003),
  restart(1004),
  powerOff(1005),
  sleep(1006),
  resume(1007),
  readStatus(50),
  readUsers(9),
  readProperty(11),
  readAttendances(13);

  const Command(this._);

  final int _;
}
