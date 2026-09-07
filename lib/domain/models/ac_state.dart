import 'ac_mode.dart';
import 'fan_speed.dart';

/// Simulated AC remote state.
class AcState {
  const AcState({
    this.power = false,
    this.temperature = 26,
    this.mode = AcMode.cool,
    this.fan = FanSpeed.auto,
    this.timerMinutes = 0,
    this.powerOnSince,
  });

  final bool power;
  final int temperature;
  final AcMode mode;
  final FanSpeed fan;

  /// Remaining timer in minutes; 0 means off.
  final int timerMinutes;

  /// When power was last turned on (device local time); null if off.
  final DateTime? powerOnSince;

  static const int minTemp = 16;
  static const int maxTemp = 30;

  bool get timerOn => timerMinutes > 0;

  AcState copyWith({
    bool? power,
    int? temperature,
    AcMode? mode,
    FanSpeed? fan,
    int? timerMinutes,
    DateTime? powerOnSince,
    bool clearPowerOnSince = false,
  }) {
    return AcState(
      power: power ?? this.power,
      temperature: temperature ?? this.temperature,
      mode: mode ?? this.mode,
      fan: fan ?? this.fan,
      timerMinutes: timerMinutes ?? this.timerMinutes,
      powerOnSince: clearPowerOnSince
          ? null
          : (powerOnSince ?? this.powerOnSince),
    );
  }
}
