import 'package:flutter/foundation.dart';

import '../data/models/ac_model_registry.dart';
import '../data/repositories/simulated_ac_controller.dart';
import '../data/services/alert_monitor_service.dart';
import '../data/services/local_notification_service.dart';
import '../data/services/notification_settings_store.dart';
import '../domain/models/ac_model_info.dart';
import '../domain/models/ac_state.dart';
import '../domain/models/notification_settings.dart';
import '../domain/services/ac_controller.dart';

/// Root app state: AC controller + notification settings.
class AppState extends ChangeNotifier {
  AppState({
    LocalNotificationService? notifications,
    NotificationSettingsStore? store,
  })  : _notifications = notifications ?? LocalNotificationService(),
        _store = store ?? NotificationSettingsStore();

  final LocalNotificationService _notifications;
  final NotificationSettingsStore _store;

  late AcController _controller;
  late AlertMonitorService _monitor;
  NotificationSettings _settings = const NotificationSettings();
  AcModelInfo _model = AcModelRegistry.models.first;
  bool _ready = false;

  AcController get controller => _controller;
  AcState get acState => _controller.state;
  NotificationSettings get settings => _settings;
  AcModelInfo get selectedModel => _model;
  bool get ready => _ready;
  AlertMonitorService get monitor => _monitor;
  LocalNotificationService get notifications => _notifications;

  Future<void> init() async {
    await _notifications.init();
    _settings = await _store.load();
    final modelId = await _store.loadSelectedModelId();
    _model = AcModelRegistry.getById(modelId);
    _controller = AcModelRegistry.createController(modelId);
    _controller.stateStream.listen((_) => notifyListeners());
    _monitor = AlertMonitorService(
      controller: _controller,
      notifications: _notifications,
    );
    _monitor.updateSettings(_settings);
    _monitor.start();
    _ready = true;
    notifyListeners();
  }

  Future<void> updateSettings(NotificationSettings next) async {
    _settings = next;
    _monitor.updateSettings(next);
    await _store.save(next);
    notifyListeners();
  }

  Future<void> selectModel(String modelId) async {
    if (_model.id == modelId) return;
    final previous = _controller.state;
    _monitor.stop();
    if (_controller is SimulatedAcController) {
      (_controller as SimulatedAcController).dispose();
    }
    _model = AcModelRegistry.getById(modelId);
    _controller = AcModelRegistry.createController(modelId);
    // Carry over simulated state when switching brand stubs.
    await _controller.setTemperature(previous.temperature);
    await _controller.setMode(previous.mode);
    await _controller.setFan(previous.fan);
    await _controller.setTimerMinutes(previous.timerMinutes);
    if (previous.power) await _controller.setPower(true);
    _controller.stateStream.listen((_) => notifyListeners());
    _monitor = AlertMonitorService(
      controller: _controller,
      notifications: _notifications,
    );
    _monitor.updateSettings(_settings);
    _monitor.start();
    await _store.saveSelectedModelId(modelId);
    notifyListeners();
  }

  @override
  void dispose() {
    _monitor.stop();
    if (_controller is SimulatedAcController) {
      (_controller as SimulatedAcController).dispose();
    }
    super.dispose();
  }
}
