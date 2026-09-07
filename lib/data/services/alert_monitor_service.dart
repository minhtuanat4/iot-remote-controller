import 'dart:async';

import '../../domain/models/ac_state.dart';
import '../../domain/models/fan_speed.dart';
import '../../domain/models/notification_settings.dart';
import '../../domain/services/ac_controller.dart';
import 'local_notification_service.dart';

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
  int _lastTimerMinutes = 0;

  /// Simulated outdoor temperature (°C) for weather-vs-setpoint stub.
  static const double simulatedOutdoorTemp = 34.0;

  void updateSettings(NotificationSettings settings) {
    _settings = settings;
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
    // Timer on/off alerts (device local time in message).
    if (_settings.timerAlertsEnabled &&
        state.timerMinutes != _lastTimerMinutes) {
      final now = DateTime.now();
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      if (state.timerMinutes > 0 && _lastTimerMinutes == 0) {
        _notifications.show(
          id: 100,
          title: 'Hẹn giờ bật',
          body:
              'Đã đặt hẹn giờ ${state.timerMinutes} phút (lúc $timeStr giờ máy).',
        );
      } else if (state.timerMinutes == 0 && _lastTimerMinutes > 0) {
        _notifications.show(
          id: 101,
          title: 'Hẹn giờ tắt',
          body: 'Đã tắt hẹn giờ (lúc $timeStr giờ máy).',
        );
      }
      _lastTimerMinutes = state.timerMinutes;
    }

    if (!state.power) {
      _acOnTooLongFired = false;
      _lowTempHighFanSince = null;
      _lowTempHighFanFired = false;
    }

    _evaluate(state);
  }

  void _evaluate(AcState state) {
    if (!state.power) return;

    final now = DateTime.now();

    // AC on too long
    if (_settings.acOnTooLongEnabled &&
        state.powerOnSince != null &&
        !_acOnTooLongFired) {
      final elapsed = now.difference(state.powerOnSince!).inMinutes;
      if (elapsed >= _settings.acOnTooLongMinutes) {
        _acOnTooLongFired = true;
        _notifications.show(
          id: 200,
          title: 'Máy lạnh bật quá lâu',
          body:
              'Đã bật hơn ${_settings.acOnTooLongMinutes} phút. Cân nhắc tắt để tiết kiệm điện.',
        );
      }
    }

    // Low temp + high fan too long
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
              title: 'Nhiệt độ thấp + quạt mạnh',
              body:
                  'Đã duy trì ≥${_settings.lowTempHighFanMinutes} phút. Có thể gây khó chịu hoặc tốn điện.',
            );
          }
        }
      } else {
        _lowTempHighFanSince = null;
        _lowTempHighFanFired = false;
      }
    }

    // Weather outdoor vs setpoint stub
    if (_settings.weatherVsSetpointEnabled) {
      final gap = simulatedOutdoorTemp - state.temperature;
      if (gap >= 12) {
        // Soft stub notification once per evaluate cycle is noisy;
        // only tip when power just on — handled lightly via id 400 coalesce.
        // Phase 1: no spam; exposed as toggle for future weather API.
      }
    }
  }

  /// Manual stub trigger for weather alert (settings screen test).
  Future<void> triggerWeatherStubAlert(int setpoint) async {
    if (!_settings.weatherVsSetpointEnabled) return;
    await _notifications.show(
      id: 400,
      title: 'Thời tiết ngoài trời',
      body:
          'Ngoài trời ~${simulatedOutdoorTemp.toStringAsFixed(0)}°C, setpoint $setpoint°C (stub — chưa gọi API thời tiết).',
    );
  }
}
