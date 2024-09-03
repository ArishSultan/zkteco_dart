part of '../zkteco.dart';

enum Command {
  connect(1000),
  readStatus(50),
  readProperty(11),
  ;
  const Command(this._);

  final int _;
}
