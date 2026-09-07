import '../models/ir_frame.dart';

/// Hardware (or mock) sink for encoded IR frames.
///
/// Future adapters: Flutter platform channel (phone IR), Broadlink RM,
/// ESP8266/ESP32 IRremote, USB IR blaster.
abstract class IrTransmitter {
  String get id;
  String get labelVi;
  bool get isHardware;

  Future<void> transmit(IrFrame frame);
}

/// Logs frames instead of driving an IR LED — default for development.
class LoggingIrTransmitter implements IrTransmitter {
  LoggingIrTransmitter({this.onTransmit});

  /// Optional sink for tests / UI toast hooks (mutable for late wiring).
  void Function(IrFrame frame)? onTransmit;

  final List<IrFrame> history = <IrFrame>[];

  @override
  String get id => 'logging';

  @override
  String get labelVi => 'IR giả lập (log)';

  @override
  bool get isHardware => false;

  @override
  Future<void> transmit(IrFrame frame) async {
    history.add(frame);
    // Keep history bounded for long sessions.
    if (history.length > 200) {
      history.removeRange(0, history.length - 200);
    }
    // ignore: avoid_print
    print('[IrTransmitter/logging] $frame');
    onTransmit?.call(frame);
  }

  void clearHistory() => history.clear();
}
