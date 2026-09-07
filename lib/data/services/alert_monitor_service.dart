import 'dart:async';

import '../../domain/models/ac_state.dart';
import '../../domain/models/fan_speed.dart';
import '../../domain/models/notification_settings.dart';
import '../../domain/models/outdoor_weather.dart';
import '../../domain/services/ac_controller.dart';
import 'local_notification_service.dart';
import 'weather_service.dart';

/// Watches AC state and fires local notifications based on settings.
/// All timestamps use device local time ([DateTime.now]).
class AlertMonitorService {
  AlertMonitorService({
    required AcController controller,
    required LocalNotificationService notifications,
  })  : _controller = controller,
        _notifications = notifications;

  final AcController _controller;
  final LocalNotificationService _notifications;

  NotificationSettings _settings = const NotificationSettings();
  StreamSubscription<AcState>? _sub;
  Timer? _tick;

  DateTime? _lowTempHighFanSince;
  bool _acOnTooLongFired = false;
  bool _lowTempHighFanFired = false;
  bool _weatherVsSetpointFired = false;
  int _lastTimerMinutes = 0;

  OutdoorWeather? _outdoorWeather;

  /// Simulated outdoor temperature (°C) fallback when live weather is missing.
  static const double simulatedOutdoorTemp =
      WeatherService.simulatedOutdoorTempC;

  void updateSettings(NotificationSettings settings) {
    _settings = settings;
    if (!settings.weatherVsSetpointEnabled) {
      _weatherVsSetpointFired = false;
    }
  }

  /// Supplies the latest outdoor reading used by weather-vs-setpoint alerts.
  void updateOutdoorWeather(OutdoorWeather? weather) {
    if (weather?.temperatureC != _outdoorWeather?.temperatureC) {
      _weatherVsSetpointFired = false;
    }
    _outdoorWeather = weather;
  }

  void start() {
    _lastTimerMinutes = _controller.state.timerMinutes;
    _sub = _controller.stateStream.listen(_onState);
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      _evaluate(_controller.state);
    });
    _evaluate(_controller.state);
  }

  void stop() {
    _sub?.cancel();
    _tick?.cancel();
  }

  void _onState(AcState state) {
    if (_settings.timerAlertsEnabled &&
        state.timerMinutes != _lastTimerMinutes) {
      final now = DateTime.now();
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      if (state.timerMinutes > 0 && _lastTimerMinutes == 0) {
        _notifications.show(
          id: 100,
          title: 'Hen gio bat',
          body:
              'Da dat hen gio ${state.timerMinutes} phut (luc $timeStr gio may).',
        );
      } else if (state.timerMinutes == 0 && _lastTimerMinutes > 0) {
        _notifications.show(
          id: 101,
          title: 'Hen gio tat',
          body: 'Da tat hen gio (luc $timeStr gio may).',
        );
      }
      _lastTimerMinutes = state.timerMinutes;
    }

    if (!state.power) {
      _acOnTooLongFired = false;
      _lowTempHighFanSince = null;
      _lowTempHighFanFired = false;
      _weatherVsSetpointFired = false;
    }

    _evaluate(state);
  }

  void _evaluate(AcState state) {
    if (!state.power) return;

    final now = DateTime.now();

    if (_settings.acOnTooLongEnabled &&
        state.powerOnSince != null &&
        !_acOnTooLongFired) {
      final elapsed = now.difference(state.powerOnSince!).inMinutes;
      if (elapsed >= _settings.acOnTooLongMinutes) {
        _acOnTooLongFired = true;
        _notifications.show(
          id: 200,
          title: 'May lanh bat qua lau',
          body:
              'Da bat hon ${_settings.acOnTooLongMinutes} phut. Can nhac tat de tiet kiem dien.',
        );
      }
    }

    final isLowTempHighFan = state.temperature <= _settings.lowTempThreshold &&
        state.fan == FanSpeed.high;
    if (_settings.lowTempHighFanEnabled) {
      if (isLowTempHighFan) {
        _lowTempHighFanSince ??= now;
        if (!_lowTempHighFanFired) {
          final mins = now.difference(_lowTempHighFanSince!).inMinutes;
          if (mins >= _settings.lowTempHighFanMinutes) {
            _lowTempHighFanFired = true;
            _notifications.show(
              id: 300,
              title: 'Nhiet do thap + quat manh',
              body:
                  'Da duy tri >=${_settings.lowTempHighFanMinutes} phut. Co the gay kho chiu hoac ton dien.',
            );
          }
        }
      } else {
        _lowTempHighFanSince = null;
        _lowTempHighFanFired = false;
      }
    }

    if (_settings.weatherVsSetpointEnabled && !_weatherVsSetpointFired) {
      final outdoor = _outdoorWeather?.temperatureC ?? simulatedOutdoorTemp;
      if (outdoor < state.temperature) {
        _weatherVsSetpointFired = true;
        final source = (_outdoorWeather?.isSimulated ?? true)
            ? 'gia lap'
            : 'Open-Meteo';
        _notifications.show(
          id: 400,
          title: 'Ngoai troi mat hon setpoint',
          body:
              'Ngoai troi ${outdoor.toStringAsFixed(1)}C < setpoint ${state.temperature}C ($source). Can nhac tat may lanh.',
        );
      }
    }
  }

  Future<void> triggerWeatherAlert(int setpoint) async {
    if (!_settings.weatherVsSetpointEnabled) return;
    final outdoor = _outdoorWeather?.temperatureC ?? simulatedOutdoorTemp;
    final source =
        (_outdoorWeather?.isSimulated ?? true) ? 'gia lap' : 'Open-Meteo';
    await _notifications.show(
      id: 400,
      title: 'Thoi tiet ngoai troi',
      body:
          'Ngoai troi ${outdoor.toStringAsFixed(1)}C, setpoint $setpoint\u00b0C ($source).',
    );
  }

  Future<void> triggerWeatherStubAlert(int setpoint) =>
      triggerWeatherAlert(setpoint);
}
