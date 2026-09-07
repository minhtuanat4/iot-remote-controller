import '../../../domain/models/ac_mode.dart';
import '../../../domain/models/ac_state.dart';
import '../../../domain/models/fan_speed.dart';
import '../../../domain/models/ir_frame.dart';
import '../../../domain/services/ac_ir_encoder.dart';
import '../ir_pulse_builder.dart';

/// LG AC encoder (IRremoteESP8266 `IRLgAc`, 28-bit command word).
///
/// Sources:
/// - https://github.com/crankyoldgit/IRremoteESP8266/blob/master/src/ir_LG.h
/// - https://github.com/crankyoldgit/IRremoteESP8266/blob/master/src/ir_LG.cpp
///
/// Timing (µs, LG / NEC-like): hdr 8500/4250, bit mark 550, one 1600,
/// zero 550, trailing mark + gap. Carrier 38000 Hz.
///
/// Bit layout (simplified from community docs):
///   bits 27..20 = address/model nibble pair (0x08 typical)
///   bits 19..16 = mode
///   bits 15..8  = temperature (Celsius, offset encoding)
///   bits 7..4   = fan
///   bits 3..0   = checksum nibble
class LgIrEncoder implements AcIrEncoder {
  LgIrEncoder({this.brandId = 'lg'});

  @override
  final String brandId;

  @override
  String get protocolId => 'lg_ac';

  @override
  String get labelVi => 'LG (LG AC 28-bit)';

  static const int carrierHz = 38000;
  static const int hdrMark = 8500;
  static const int hdrSpace = 4250;
  static const int bitMark = 550;
  static const int oneSpace = 1600;
  static const int zeroSpace = 550;
  static const int gap = 54000;

  @override
  IrFrame encode(AcState state) {
    final word = _buildWord(state);
    final bytes = <int>[
      (word >> 20) & 0xFF,
      (word >> 12) & 0xFF,
      (word >> 4) & 0xFF,
      (word & 0x0F) << 4,
    ];

    final b = IrPulseBuilder();
    b.header(hdrMark, hdrSpace);
    for (var i = 27; i >= 0; i--) {
      final one = ((word >> i) & 1) == 1;
      b.bit(
        one: one,
        markUs: bitMark,
        oneSpaceUs: oneSpace,
        zeroSpaceUs: zeroSpace,
      );
    }
    b.mark(bitMark);
    b.footerGap(gap);

    return IrFrame(
      protocolId: protocolId,
      brandId: brandId,
      carrierHz: carrierHz,
      timingsUs: b.pulses,
      payloadHex: IrPulseBuilder.toHex(bytes),
    );
  }

  int _buildWord(AcState state) {
    const address = 0x08; // common LG AC remote address nibble pair high
    final mode = switch (state.mode) {
      AcMode.cool => 0x0,
      AcMode.dry => 0x1,
      AcMode.fan => 0x2,
      AcMode.auto => 0x3,
      AcMode.heat => 0x4,
    };
    // LG often encodes temp as (celsius - 15) in a nibble/byte field.
    final temp =
        (state.temperature.clamp(AcState.minTemp, AcState.maxTemp) - 15) & 0x0F;
    final fan = switch (state.fan) {
      FanSpeed.low => 0x0,
      FanSpeed.medium => 0x2,
      FanSpeed.high => 0x4,
      FanSpeed.auto => 0x5,
    };
    final powerBit = state.power ? 0x1 : 0x0;

    // Pack: [addr:8][mode:4][temp:4][fan:4][power:4] then checksum nibble.
    var raw = 0;
    raw |= (address & 0xFF) << 20;
    raw |= (mode & 0x0F) << 16;
    raw |= (temp & 0x0F) << 12;
    raw |= (fan & 0x0F) << 8;
    raw |= (powerBit & 0x0F) << 4;
    final checksum = _checksumNibble(raw);
    raw |= checksum & 0x0F;
    return raw & 0x0FFFFFFF;
  }

  /// LG AC checksum: sum of nibbles 1..6, then low nibble (community formula).
  int _checksumNibble(int rawWithoutCs) {
    var sum = 0;
    for (var shift = 4; shift <= 24; shift += 4) {
      sum += (rawWithoutCs >> shift) & 0x0F;
    }
    return sum & 0x0F;
  }
}
