/// A raw IR pulse train ready for an [IrTransmitter].
///
/// [timingsUs] is an alternating mark/space list in microseconds,
/// starting with a mark (IR LED on). Even length is preferred; odd
/// lengths leave the last mark without a trailing space.
class IrFrame {
  const IrFrame({
    required this.protocolId,
    required this.brandId,
    required this.carrierHz,
    required this.timingsUs,
    required this.payloadHex,
    this.repeat = 0,
  });

  /// Stable protocol key, e.g. `daikin216`, `panasonic_ac`, `lg`, `gree`.
  final String protocolId;

  /// Registry model id this frame was encoded for.
  final String brandId;

  /// Carrier frequency in Hz (typically 38000).
  final int carrierHz;

  /// Mark/space durations in microseconds.
  final List<int> timingsUs;

  /// Encoded state bytes as lowercase hex (for logs / tests).
  final String payloadHex;

  /// Extra times to retransmit after the first send (hardware-dependent).
  final int repeat;

  bool get isEmpty => timingsUs.isEmpty;

  int get markCount => (timingsUs.length + 1) ~/ 2;

  @override
  String toString() =>
      'IrFrame($protocolId/$brandId, ${timingsUs.length} pulses, '
      'carrier=${carrierHz}Hz, payload=$payloadHex)';
}
