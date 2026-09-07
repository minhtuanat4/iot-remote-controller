import 'package:flutter/foundation.dart';

import '../data/models/ac_model_registry.dart';
import '../data/repositories/ir_blaster_ac_controller.dart';
import '../data/repositories/simulated_ac_controller.dart';
import '../data/services/alert_monitor_service.dart';
import '../data/services/local_notification_service.dart';
import '../data/services/notification_settings_store.dart';
import '../domain/models/ac_model_info.dart';
import '../domain/models/ac_state.dart';
import '../domain/models/ac_transport_kind.dart';
import '../domain/models/ir_frame.dart';
import '../domain/models/notification_settings.dart';
import '../domain/services/ac_controller.dart';
import '../domain/services/ir_transmitter.dart';

/// Root app state: AC controller + transport + notification settings.
class AppState extends ChangeNotifier {
  AppState({
    LocalNotificationService? notifications,
    NotificationSettingsStore? store,
    LoggingIrTransmitter? transmitter,
  })  : _notifications = notifications ?? LocalNotificationService(),
        _store = store ?? NotificationSettingsStore(),
        _transmitter = transmitter ?? LoggingIrTransmitter();

  final LocalNotificationService _notifications;
  final NotificationSettingsStore _store;
  final LoggingIrTransmitter _transmitter;

  late AcController _controller;
  late AlertMonitorService _monitor;
  NotificationSettings _settings = const NotificationSettings();
  AcModelInfo _model = AcModelRegistry.models.first;
  AcTransportKind _transport = AcTransportKind.simulated;
  IrFrame? _lastIrFrame;
  bool _ready = false;

  AcController get controller => _controller;
  AcState get acState => _controller.state;
  NotificationSettings get settings => _settings;
  AcModelInfo get selectedModel => _model;
  AcTransportKind get transport => _transport;
  LoggingIrTransmitter get irTransmitter => _transmitter;
  IrFrame? get lastIrFrame => _lastIrFrame;
  bool get ready => _ready;
  AlertMonitorService get monitor => _monitor;
  LocalNotificationService get notifications => _notifications;

  String get transportStatusVi {
    switch (_transport) {
      case AcTransportKind.simulated:
        return 'Mô phỏng';
      case AcTransportKind.irBlaster:
        return _transmitter.labelVi;
    }
  }

  Future<void> init() async {
    await _notifications.init();
    _settings = await _store.load();
    var modelId = await _store.loadSelectedModelId();
    _transport = await _store.loadTransportKind();
    _model = AcModelRegistry.getById(modelId);
    if (_transport == AcTransportKind.irBlaster && !_model.supportsIr) {
      _model = AcModelRegistry.irCapableModels.first;
      modelId = _model.id;
      await _store.saveSelectedModelId(modelId);
    }
    _transmitter.onTransmit = (frame) {
      _lastIrFrame = frame;
      notifyListeners();
    };
    _controller = AcModelRegistry.createController(
      modelId,
      transport: _transport,
      transmitter: _transmitter,
    );
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

  Future<void> selectTransport(AcTransportKind kind) async {
    if (_transport == kind) return;
    var model = _model;
    if (kind == AcTransportKind.irBlaster && !model.supportsIr) {
      model = AcModelRegistry.irCapableModels.first;
    }
    await _rebuildController(modelId: model.id, transport: kind);
    _model = model;
    _transport = kind;
    await _store.saveSelectedModelId(_model.id);
    await _store.saveTransportKind(kind);
    notifyListeners();
  }

  Future<void> selectModel(String modelId) async {
    final next = AcModelRegistry.getById(modelId);
    if (_model.id == next.id) return;

    var transport = _transport;
    if (transport == AcTransportKind.irBlaster && !next.supportsIr) {
      // Generic has no IR encoder — fall back to simulated.
      transport = AcTransportKind.simulated;
    }

    await _rebuildController(modelId: next.id, transport: transport);
    _model = next;
    _transport = transport;
    await _store.saveSelectedModelId(next.id);
    await _store.saveTransportKind(transport);
    notifyListeners();
  }

  Future<void> _rebuildController({
    required String modelId,
    required AcTransportKind transport,
  }) async {
    final previous = _controller.state;
    _monitor.stop();
    _disposeController();
    _controller = AcModelRegistry.createController(
      modelId,
      transport: transport,
      transmitter: _transmitter,
    );
    // Carry over UI state when switching brand / transport.
    if (_controller is IrBlasterAcController) {
      (_controller as IrBlasterAcController).seedState(previous);
    } else {
      await _controller.setTemperature(previous.temperature);
      await _controller.setMode(previous.mode);
      await _controller.setFan(previous.fan);
      await _controller.setTimerMinutes(previous.timerMinutes);
      if (previous.power) await _controller.setPower(true);
    }
    _controller.stateStream.listen((_) => notifyListeners());
    _monitor = AlertMonitorService(
      controller: _controller,
      notifications: _notifications,
    );
    _monitor.updateSettings(_settings);
    _monitor.start();
  }

  void _disposeController() {
    if (_controller is SimulatedAcController) {
      (_controller as SimulatedAcController).dispose();
    } else if (_controller is IrBlasterAcController) {
      (_controller as IrBlasterAcController).dispose();
    }
  }

  @override
  void dispose() {
    _monitor.stop();
    _disposeController();
    super.dispose();
  }
}
