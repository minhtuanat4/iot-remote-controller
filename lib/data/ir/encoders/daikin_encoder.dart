import '../../../domain/models/ac_mode.dart';
import '../../../domain/models/ac_state.dart';
import '../../../domain/models/fan_speed.dart';
import '../../../domain/models/ir_frame.dart';
import '../../../domain/services/ac_ir_encoder.dart';
import '../ir_pulse_builder.dart';

/// Daikin 216-bit AC encoder (IRremoteESP8266 `IRDaikin216` / `kDaikin216Bits`).
///
/// Sources:
/// - https://github.com/crankyoldgit/IRremoteESP8266/blob/master/src/ir_Daikin.h
/// - https://github.com/crankyoldgit/IRremoteESP8266/blob/master/src/ir_Daikin.cpp
///
/// Timing (µs): hdr 3400/1750, bit mark 430, one 1300, zero 420, gap ~35000.
/// Frame: 8-byte section + gap + 19-byte section (27 bytes total / 216 bits).
class DaikinIrEncoder implements AcIrEncoder {
  DaikinIrEncoder({this.brandId = 'daikin'});

  @override
  final String brandId;

  @override
  String get protocolId => 'daikin216';

  @override
  String get labelVi => 'Daikin (Daikin216)';

  static const int carrierHz = 38000;
  static const int hdrMark = 3400;
  static const int hdrSpace = 1750;
  static const int bitMark = 430;
  static const int oneSpace = 1300;
  static const int zeroSpace = 420;
  static const int sectionGap = 35000;

  @override
  IrFrame encode(AcState state) {
    final section1 = List<int>.filled(8, 0);
    // Fixed header bytes used by Daikin216 remotes.
    section1[0] = 0x11;
    section1[1] = 0xDA;
    section1[2] = 0x27;
    section1[3] = 0x00;
    section1[4] = 0xC5;
    section1[5] = 0x00;
    section1[6] = 0x00;
    section1[7] = IrPulseBuilder.checksumSum(section1.sublist(0, 7));

    final section2 = List<int>.filled(19, 0);
    section2[0] = 0x11;
    section2[1] = 0xDA;
    section2[2] = 0x27;
    section2[3] = 0x00;
    section2[4] = 0x00;
    // Power + mode nibble (common Daikin layout).
    section2[5] = _modeByte(state);
    // Temperature encoded as degrees Celsius * 2 in low bits (Daikin style).
    section2[6] = (state.temperature.clamp(AcState.minTemp, AcState.maxTemp) * 2) & 0xFE;
    section2[7] = 0x00;
    section2[8] = _fanByte(state.fan);
    // Swing / unused bytes kept at safe defaults.
    section2[9] = 0x00;
    section2[10] = 0x00;
    section2[11] = 0x00;
    section2[12] = 0x00;
    section2[13] = state.timerOn ? 0x01 : 0x00;
    section2[14] = (state.timerMinutes ~/ 60) & 0xFF;
    section2[15] = (state.timerMinutes % 60) & 0xFF;
    section2[16] = 0x00;
    section2[17] = 0x00;
    section2[18] = IrPulseBuilder.checksumSum(section2.sublist(0, 18));

    final payload = [...section1, ...section2];
    final b = IrPulseBuilder();
    b.header(hdrMark, hdrSpace);
    b.bytes(
      section1,
      markUs: bitMark,
      oneSpaceUs: oneSpace,
      zeroSpaceUs: zeroSpace,
    );
    b.mark(bitMark);
    b.footerGap(sectionGap);
    b.header(hdrMark, hdrSpace);
    b.bytes(
      section2,
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
      payloadHex: IrPulseBuilder.toHex(payload),
    );
  }

  int _modeByte(AcState state) {
    // Bit0 = power; bits 4..7 = mode (Daikin216 simplified mapping).
    final powerBit = state.power ? 0x01 : 0x00;
    final modeNibble = switch (state.mode) {
      AcMode.auto => 0x0,
      AcMode.dry => 0x2,
      AcMode.cool => 0x3,
      AcMode.heat => 0x4,
      AcMode.fan => 0x6,
    };
    return powerBit | (modeNibble << 4);
  }

  int _fanByte(FanSpeed fan) {
    // Daikin fan nibble in high nibble of byte 8 (community mapping).
    final nibble = switch (fan) {
      FanSpeed.auto => 0xA,
      FanSpeed.low => 0x3,
      FanSpeed.medium => 0x5,
      FanSpeed.high => 0x7,
    };
    return (nibble << 4) & 0xF0;
  }
}
