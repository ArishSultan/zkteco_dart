part of '../zkteco.dart';

enum Command {
  connect(1000),
  getFreeSizes(50)
  ;
  const Command(this._);

  final int _;
}
