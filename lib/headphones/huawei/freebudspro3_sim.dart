import 'package:rxdart/rxdart.dart';

import '../framework/anc.dart';
import '../simulators/anc_sim.dart';
import '../simulators/bluetooth_headphones_sim.dart';
import '../simulators/lrc_battery_sim.dart';
import 'freebudspro3.dart';
import 'settings.dart';

final class HuaweiFreeBudsPro3Sim extends HuaweiFreeBudsPro3
    with BluetoothHeadphonesSim, LRCBatteryAlwaysFullSim, AncSim {
  // ehhhhhh...

  final _settingsCtrl = BehaviorSubject<HuaweiFreeBudsPro3Settings>.seeded(
    const HuaweiFreeBudsPro3Settings(
      doubleTapLeft: DoubleTap.playPause,
      doubleTapRight: DoubleTap.playPause,
      holdBoth: Hold.cycleAnc,
      holdBothToggledAncModes: {
        AncMode.noiseCancelling,
        AncMode.off,
        AncMode.transparency,
      },
      autoPause: true,
    ),
  );

  @override
  ValueStream<HuaweiFreeBudsPro3Settings> get settings => _settingsCtrl.stream;

  @override
  Future<void> setSettings(HuaweiFreeBudsPro3Settings newSettings) async {
    _settingsCtrl.add(
      _settingsCtrl.value.copyWith(
        doubleTapLeft: newSettings.doubleTapLeft,
        doubleTapRight: newSettings.doubleTapRight,
        holdBoth: newSettings.holdBoth,
        holdBothToggledAncModes: newSettings.holdBothToggledAncModes,
        autoPause: newSettings.autoPause,
      ),
    );
  }
}

/// Class to use as placeholder for Disabled() widget
// this is not done with mixins because we may want to fill it with
// last-remembered values in future, and we will pretty much override
// all of this
//
// ...or not. I just don't know yet 🤷
final class HuaweiFreeBudsPro3SimPlaceholder extends HuaweiFreeBudsPro3
    with
        BluetoothHeadphonesSimPlaceholder,
        LRCBatteryAlwaysFullSimPlaceholder,
        AncSimPlaceholder {
  const HuaweiFreeBudsPro3SimPlaceholder();

  @override
  ValueStream<HuaweiFreeBudsPro3Settings> get settings => BehaviorSubject();

  @override
  Future<void> setSettings(HuaweiFreeBudsPro3Settings newSettings) async {}
}
