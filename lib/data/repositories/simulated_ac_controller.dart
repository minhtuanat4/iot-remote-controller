import 'dart:async';

import '../../domain/models/ac_mode.dart';
import '../../domain/models/ac_state.dart';
import '../../domain/models/fan_speed.dart';
import '../../domain/services/ac_controller.dart';

/// In-memory AC controller used for Phase 1 UI/simulation.
class SimulatedAcController implements AcController {
  SimulatedAcController({this.modelId = 'generic'}) {
    _controller = StreamController<AcState>.broadcast();
  }

  final String modelId;
  AcState _state = const AcState();
  late final StreamController<AcState> _controller;

  static const _timerSteps = [0, 30, 60, 90, 120, 180, 240];

  @override
  AcState get state => _state;

  @override
  Stream<AcState> get stateStream => _controller.stream;

  void _emit(AcState next) {
    _state = next;
    _controller.add(_state);
  }

  @override
  Future<void> setPower(bool on) async {
    if (on == _state.power) return;
    _emit(
      _state.copyWith(
        power: on,
        powerOnSince: on ? DateTime.now() : null,
        clearPowerOnSince: !on,
      ),
    );
  }

  @override
  Future<void> togglePower() => setPower(!_state.power);

  @override
  Future<void> setTemperature(int celsius) async {
    final clamped = celsius.clamp(AcState.minTemp, AcState.maxTemp);
    if (clamped == _state.temperature) return;
    _emit(_state.copyWith(temperature: clamped));
  }

  @override
  Future<void> temperatureUp() =>
      setTemperature(_state.temperature + 1);

  @override
  Future<void> temperatureDown() =>
      setTemperature(_state.temperature - 1);

  @override
  Future<void> setMode(AcMode mode) async {
    if (mode == _state.mode) return;
    _emit(_state.copyWith(mode: mode));
  }

  @override
  Future<void> cycleMode() async {
    final values = AcMode.values;
    final next = values[(_state.mode.index + 1) % values.length];
    await setMode(next);
  }

  @override
  Future<void> setFan(FanSpeed fan) async {
    if (fan == _state.fan) return;
    _emit(_state.copyWith(fan: fan));
  }

  @override
  Future<void> cycleFan() async {
    final values = FanSpeed.values;
    final next = values[(_state.fan.index + 1) % values.length];
    await setFan(next);
  }

  @override
  Future<void> setTimerMinutes(int minutes) async {
    final m = minutes < 0 ? 0 : minutes;
    if (m == _state.timerMinutes) return;
    _emit(_state.copyWith(timerMinutes: m));
  }

  @override
  Future<void> cycleTimer() async {
    final idx = _timerSteps.indexOf(_state.timerMinutes);
    final nextIdx = (idx + 1) % _timerSteps.length;
    await setTimerMinutes(_timerSteps[nextIdx]);
  }

  void dispose() {
    _controller.close();
  }
}
