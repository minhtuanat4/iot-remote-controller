import '../../../domain/models/ac_mode.dart';
import '../../../domain/models/ac_state.dart';
import '../../../domain/models/fan_speed.dart';
import '../../../domain/models/ir_frame.dart';
import '../../../domain/services/ac_ir_encoder.dart';
import '../ir_pulse_builder.dart';

/// Gree-family AC encoder (IRremoteESP8266 `IRGreeAC`, 64-bit / 8 bytes).
///
/// Used in Vietnam for **Casper** and **Funiki** wall units that OEM on
/// Gree protocol (YAA / YAC variants). Model differences are mostly in
/// model-id nibbles; we use the common YAA block layout.
///
/// Sources:
/// - https://github.com/crankyoldgit/IRremoteESP8266/blob/master/src/ir_Gree.h
/// - https://github.com/crankyoldgit/IRremoteESP8266/blob/master/src/ir_Gree.cpp
/// - Community notes: Funiki / Casper VN remotes decode as Gree on IR dumpers
///
/// Timing (µs): hdr 9000/4500, bit mark 620, one 1600, zero 540,
/// mid-frame gap ~19000, footer mark. Carrier 38000 Hz.
class GreeIrEncoder implements AcIrEncoder {
  GreeIrEncoder({
    required this.brandId,
    required this.labelVi,
    this.modelIdNibble = 0x0,
  });

  @override
  final String brandId;

  @override
  final String labelVi;

  /// Distinguishes OEM skins (Casper vs Funiki) inside the Gree block.
  final int modelIdNibble;

  @override
  String get protocolId => 'gree';

  static const int carrierHz = 38000;
  static const int hdrMark = 9000;
  static const int hdrSpace = 4500;
  static const int bitMark = 620;
  static const int oneSpace = 1600;
  static const int zeroSpace = 540;
  static const int midGap = 19000;

  @override
  IrFrame encode(AcState state) {
    final data = List<int>.filled(8, 0);
    // Byte 0: mode (low nibble) + power bit + model nibble high.
    data[0] = _modePowerByte(state) | ((modelIdNibble & 0x0F) << 4);
    // Byte 1: temperature (Celsius, Gree uses temp-16 in low 4 bits often).
    final temp = state.temperature.clamp(AcState.minTemp, AcState.maxTemp);
    data[1] = (temp - 16) & 0x0F;
    // Byte 2: fan + timer flags.
    data[2] = _fanByte(state.fan) | (state.timerOn ? 0x40 : 0x00);
    // Byte 3: timer hours (coarse) — minutes/15 for compact encoding.
    data[3] = state.timerOn ? ((state.timerMinutes ~/ 15) & 0xFF) : 0x00;
    // Bytes 4-5: fixed / swing defaults used by many Gree YAA remotes.
    data[4] = 0x00;
    data[5] = 0x20;
    // Byte 6: zeros / reserved.
    data[6] = 0x00;
    // Byte 7: checksum (sum of first 7 bytes & 0xFF) — Gree YAA style.
    data[7] = IrPulseBuilder.checksumSum(data.sublist(0, 7));

    final b = IrPulseBuilder();
    b.header(hdrMark, hdrSpace);
    // First 4 bytes, then mid-frame gap (Gree two-block send).
    b.bytes(
      data.sublist(0, 4),
      markUs: bitMark,
      oneSpaceUs: oneSpace,
      zeroSpaceUs: zeroSpace,
    );
    b.mark(bitMark);
    b.footerGap(midGap);
    b.bytes(
      data.sublist(4),
      markUs: bitMark,
      oneSpaceUs: oneSpace,
      zeroSpaceUs: zeroSpace,
    );
    b.mark(bitMark);

    return IrFrame(
      protocolId: protocolId,
      brandId: brandId,
      carrierHz: carrierHz,
      timingsUs: b.pulses,
      payloadHex: IrPulseBuilder.toHex(data),
    );
  }

  int _modePowerByte(AcState state) {
    final mode = switch (state.mode) {
      AcMode.auto => 0x0,
      AcMode.cool => 0x1,
      AcMode.dry => 0x2,
      AcMode.fan => 0x3,
      AcMode.heat => 0x4,
    };
    final power = state.power ? 0x08 : 0x00;
    return (mode & 0x07) | power;
  }

  int _fanByte(FanSpeed fan) {
    // Gree fan in bits 4..6 of byte 2 (simplified).
    final level = switch (fan) {
      FanSpeed.auto => 0x0,
      FanSpeed.low => 0x1,
      FanSpeed.medium => 0x2,
      FanSpeed.high => 0x3,
    };
    return (level & 0x07) << 4;
  }
}

/// Casper VN — Gree-family OEM.
class CasperIrEncoder extends GreeIrEncoder {
  CasperIrEncoder()
      : super(
          brandId: 'casper',
          labelVi: 'Casper (Gree-family)',
          modelIdNibble: 0x1,
        );
}

/// Funiki VN — Gree-family OEM (common in Việt Nam).
class FunikiIrEncoder extends GreeIrEncoder {
  FunikiIrEncoder()
      : super(
          brandId: 'funiki',
          labelVi: 'Funiki (Gree-family)',
          modelIdNibble: 0x2,
        );
}
