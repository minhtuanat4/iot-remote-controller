import '../models/ac_mode.dart';
import '../models/ac_state.dart';
import '../models/fan_speed.dart';

/// Abstract AC controller — brand adapters plug in here.
abstract class AcController {
  AcState get state;
  Stream<AcState> get stateStream;

  Future<void> setPower(bool on);
  Future<void> setTemperature(int celsius);
  Future<void> setMode(AcMode mode);
  Future<void> setFan(FanSpeed fan);
  Future<void> setTimerMinutes(int minutes);
  Future<void> togglePower();
  Future<void> temperatureUp();
  Future<void> temperatureDown();
  Future<void> cycleMode();
  Future<void> cycleFan();
  Future<void> cycleTimer();
}
