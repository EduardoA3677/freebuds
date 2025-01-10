import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:freebuddy/headphones/framework/anc.dart';
import 'package:freebuddy/headphones/framework/lrc_battery.dart';
import 'package:freebuddy/headphones/huawei/freebudspro3_impl.dart';
import 'package:freebuddy/headphones/huawei/mbb.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart';

void main() {
  group("FreeBuds Pro 3 implementation tests", () {
    // test with keyword "info" test if impl reacts to info *from* buds
    // ones with "set" test if impl sends correct bytes *to* buds

    late StreamController<Uint8List> inputCtrl;
    late StreamController<Uint8List> outputCtrl;
    late StreamChannel<Uint8List> channel;
    late HuaweiFreeBudsPro3Impl fbPro3;
    setUp(() {
      inputCtrl = StreamController<Uint8List>.broadcast();
      outputCtrl = StreamController<Uint8List>();
      channel = StreamChannel<Uint8List>(inputCtrl.stream, outputCtrl.sink);
      fbPro3 = HuaweiFreeBudsPro3Impl(mbbChannel(channel), const FakeBtDev());
    });
    tearDown(() {
      inputCtrl.close();
      outputCtrl.close();
    });
    test("Request data on start", () async {
      expect(
        outputCtrl.stream.bytesToList(),
        emitsInAnyOrder([
          [90, 0, 3, 0, 1, 8, 223, 115],
          [90, 0, 3, 0, 43, 42, 50, 126],
        ]),
      );
    });
    test("ANC mode set", () async {
      await fbPro3.setAncMode(AncMode.noiseCancelling);
      expect(
        outputCtrl.stream.bytesToList(),
        emitsThrough([90, 0, 7, 0, 43, 4, 1, 2, 1, 255, 255, 236]),
      );
    });
    test("ANC mode info", () async {
      const cmds = [
        MbbCommand(43, 42, {
          1: [4, 1]
        }),
        MbbCommand(43, 42, {
          1: [0, 0]
        }),
        MbbCommand(43, 42, {
          1: [0, 2]
        }),
        MbbCommand(43, 42, {
          1: [0, 2]
        }),
      ];
      for (var c in cmds) {
        inputCtrl.add(c.toPayload());
      }
      expect(
        fbPro3.ancMode,
        emitsInOrder([
          AncMode.noiseCancelling,
          AncMode.off,
          AncMode.transparency,
          AncMode.transparency,
        ]),
      );
    });
    test("Battery info", () async {
      inputCtrl.add(const MbbCommand(1, 39, {
        1: [35],
        2: [35, 70, 99],
        3: [1, 0, 1]
      }).toPayload());
      expect(
        fbPro3.lrcBattery,
        emits(const LRCBatteryLevels(35, 70, 99, true, false, true)),
      );
    });
    test("Properly closes", () async {
      expectLater(
        fbPro3.ancMode,
        emitsInOrder([AncMode.noiseCancelling, emitsDone]),
      );
      expectLater(fbPro3.lrcBattery, emitsDone);
      inputCtrl.add(const MbbCommand(43, 42, {
        1: [4, 1]
      }).toPayload());
      await inputCtrl.close();
    });
  });
}

class FakeBtDev implements BluetoothDevice {
  const FakeBtDev();

  @override
  ValueStream<String> get alias => Stream.value("FreeBuds 😺").shareValue();

  @override
  ValueStream<int> get battery => Stream.value(100).shareValue();

  @override
  ValueStream<bool> get isConnected => Stream.value(true).shareValue();

  @override
  String get mac => "00:11:22:33:44:55";

  @override
  ValueStream<String> get name =>
      Stream.value("HUAWEI FreeBuds Pro 3").shareValue();

  @override
  Future<Set<String>> get uuids => Future.value({});
}

extension on Stream<Uint8List> {
  Stream<List<int>> bytesToList() => map((event) => event.toList());
}
