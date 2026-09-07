import 'package:flutter_test/flutter_test.dart';
import 'package:iot_remote_controller/domain/models/ac_state.dart';
import 'package:iot_remote_controller/domain/models/ac_mode.dart';
import 'package:iot_remote_controller/domain/models/fan_speed.dart';
import 'package:iot_remote_controller/data/repositories/simulated_ac_controller.dart';

void main() {
  test('SimulatedAcController toggles power and temp', () async {
    final ctrl = SimulatedAcController();
    expect(ctrl.state.power, isFalse);

    await ctrl.togglePower();
    expect(ctrl.state.power, isTrue);
    expect(ctrl.state.powerOnSince, isNotNull);

    await ctrl.setTemperature(24);
    expect(ctrl.state.temperature, 24);

    await ctrl.cycleMode();
    expect(ctrl.state.mode, isNot(AcMode.cool));

    await ctrl.cycleFan();
    expect(ctrl.state.fan, isNot(FanSpeed.auto));

    await ctrl.cycleTimer();
    expect(ctrl.state.timerOn, isTrue);

    await ctrl.setPower(false);
    expect(ctrl.state.power, isFalse);

    ctrl.dispose();
  });

  test('AcState clamps via copyWith temperature field', () {
    const s = AcState(temperature: 26);
    expect(s.copyWith(temperature: 20).temperature, 20);
  });
}
