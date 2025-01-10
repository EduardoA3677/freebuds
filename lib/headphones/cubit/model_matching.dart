import 'dart:typed_data';

import 'package:stream_channel/stream_channel.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart';

import '../framework/bluetooth_headphones.dart';
import '../huawei/freebuds3i.dart';
import '../huawei/freebuds3i_impl.dart';
import '../huawei/freebudspro3.dart';
import '../huawei/freebudspro3_impl.dart';
import '../huawei/freebudspro3_sim.dart';
import '../huawei/mbb.dart';

typedef HeadphonesBuilder = BluetoothHeadphones Function(
    StreamChannel<Uint8List> io, BluetoothDevice device);

typedef MatchedModel = ({
  HeadphonesBuilder builder,
  BluetoothHeadphones placeholder
});

MatchedModel? matchModel(BluetoothDevice matchedDevice) {
  final name = matchedDevice.name.value;
  return switch (name) {
    _ when HuaweiFreeBudsPro3.idNameRegex.hasMatch(name) => (
        builder: (io, dev) => HuaweiFreeBudsPro3Impl(mbbChannel(io), dev),
        placeholder: const HuaweiFreeBudsPro3SimPlaceholder(),
      ) as MatchedModel,
    _ when HuaweiFreeBuds3i.idNameRegex.hasMatch(name) => (
        builder: (io, dev) => HuaweiFreeBuds3iImpl(mbbChannel(io), dev),
        placeholder: const HuaweiFreeBudsPro3SimPlaceholder(),
      ) as MatchedModel,
    _ => null,
  };
}
