import 'dart:async';

import '../../domain/models/ac_mode.dart';
import '../../domain/models/ac_state.dart';
import '../../domain/models/fan_speed.dart';
import '../../domain/models/ir_frame.dart';
import '../../domain/services/ac_controller.dart';
import '../../domain/services/ac_ir_encoder.dart';
import '../../domain/services/ir_transmitter.dart';

/// AC controller that keeps local UI state and emits IR frames per command.
///
/// Does not break the Simulated path — this is selected only when transport
/// is [AcTransportKind.irBlaster].
class IrBlasterAcController implements AcController {
  IrBlasterAcController({
    required this.modelId,
    required AcIrEncoder encoder,
    required IrTransmitter transmitter,
    AcState? initial,
  })  : _encoder = encoder,
        _transmitter = transmitter,
        _state = initial ?? const AcState() {
    _controller = StreamController<AcState>.broadcast();
  }

  final String modelId;
  final AcIrEncoder _encoder;
  final IrTransmitter _transmitter;

  AcState _state;
  late final StreamController<AcState> _controller;
  IrFrame? lastFrame;

  static const _timerSteps = [0, 30, 60, 90, 120, 180, 240];

  AcIrEncoder get encoder => _encoder;
  IrTransmitter get transmitter => _transmitter;

  @override
  AcState get state => _state;

  @override
  Stream<AcState> get stateStream => _controller.stream;

  Future<void> _emitAndSend(AcState next) async {
    _state = next;
    _controller.add(_state);
    final frame = _encoder.encode(_state);
    lastFrame = frame;
    await _transmitter.transmit(frame);
  }

  @override
  Future<void> setPower(bool on) async {
    if (on == _state.power) {
      // Still retransmit current state (many remotes re-send on press).
      await _emitAndSend(_state);
      return;
    }
    await _emitAndSend(
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
    await _emitAndSend(_state.copyWith(temperature: clamped));
  }

  @override
  Future<void> temperatureUp() => setTemperature(_state.temperature + 1);

  @override
  Future<void> temperatureDown() => setTemperature(_state.temperature - 1);

  @override
  Future<void> setMode(AcMode mode) async {
    if (mode == _state.mode) return;
    await _emitAndSend(_state.copyWith(mode: mode));
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
    await _emitAndSend(_state.copyWith(fan: fan));
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
    await _emitAndSend(_state.copyWith(timerMinutes: m));
  }

  @override
  Future<void> cycleTimer() async {
    final idx = _timerSteps.indexOf(_state.timerMinutes);
    final nextIdx = (idx + 1) % _timerSteps.length;
    await setTimerMinutes(_timerSteps[nextIdx]);
  }

  /// Apply state without transmitting (used when switching transport/brand).
  void seedState(AcState state) {
    _state = state;
    _controller.add(_state);
  }

  void dispose() {
    _controller.close();
  }
}
