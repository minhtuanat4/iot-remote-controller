import '../../../domain/models/ac_mode.dart';
import '../../../domain/models/ac_state.dart';
import '../../../domain/models/fan_speed.dart';
import '../../../domain/models/ir_frame.dart';
import '../../../domain/services/ac_ir_encoder.dart';
import '../ir_pulse_builder.dart';

/// Panasonic AC encoder (IRremoteESP8266 `IRPanasonicAc`, 216-bit / 27 bytes).
///
/// Sources:
/// - https://github.com/crankyoldgit/IRremoteESP8266/blob/master/src/ir_Panasonic.h
/// - https://github.com/crankyoldgit/IRremoteESP8266/blob/master/src/ir_Panasonic.cpp
///
/// Timing (µs): hdr 3450/1700, bit mark 435, one 1300, zero 435, gap ~10000.
/// Carrier often 36700 Hz on Panasonic remotes.
class PanasonicIrEncoder implements AcIrEncoder {
  PanasonicIrEncoder({this.brandId = 'panasonic'});

  @override
  final String brandId;

  @override
  String get protocolId => 'panasonic_ac';

  @override
  String get labelVi => 'Panasonic (PanasonicAc)';

  static const int carrierHz = 36700;
  static const int hdrMark = 3450;
  static const int hdrSpace = 1700;
  static const int bitMark = 435;
  static const int oneSpace = 1300;
  static const int zeroSpace = 435;
  static const int sectionGap = 10000;

  @override
  IrFrame encode(AcState state) {
    // 27-byte state; first 8 bytes are a static Panasonic header section.
    final data = List<int>.filled(27, 0);
    data[0] = 0x02;
    data[1] = 0x20;
    data[2] = 0xE0;
    data[3] = 0x04;
    data[4] = 0x00;
    data[5] = 0x00;
    data[6] = 0x00;
    data[7] = 0x06;
    // Second section static prefix.
    data[8] = 0x02;
    data[9] = 0x20;
    data[10] = 0xE0;
    data[11] = 0x04;
    data[12] = 0x00;
    data[13] = _powerModeByte(state);
    data[14] = state.temperature.clamp(AcState.minTemp, AcState.maxTemp) & 0x1F;
    data[15] = 0x80; // vertical swing auto-ish default
    data[16] = _fanByte(state.fan);
    data[17] = 0x0E;
    data[18] = state.timerOn ? 0x10 : 0x00;
    data[19] = (state.timerMinutes ~/ 10) & 0xFF;
    data[20] = 0x00;
    data[21] = 0x00;
    data[22] = 0x00;
    data[23] = 0x80;
    data[24] = 0x00;
    data[25] = 0x00;
    data[26] = IrPulseBuilder.checksumSum(data.sublist(0, 26));

    final b = IrPulseBuilder();
    // Panasonic often sends a short header section then the main section.
    b.header(hdrMark, hdrSpace);
    b.bytes(
      data.sublist(0, 8),
      markUs: bitMark,
      oneSpaceUs: oneSpace,
      zeroSpaceUs: zeroSpace,
    );
    b.mark(bitMark);
    b.footerGap(sectionGap);
    b.header(hdrMark, hdrSpace);
    b.bytes(
      data.sublist(8),
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

  int _powerModeByte(AcState state) {
    final mode = switch (state.mode) {
      AcMode.auto => 0x0,
      AcMode.dry => 0x2,
      AcMode.cool => 0x3,
      AcMode.heat => 0x4,
      AcMode.fan => 0x6,
    };
    final power = state.power ? 0x01 : 0x00;
    return (mode << 4) | power;
  }

  int _fanByte(FanSpeed fan) {
    return switch (fan) {
      FanSpeed.auto => 0xA0,
      FanSpeed.low => 0x30,
      FanSpeed.medium => 0x50,
      FanSpeed.high => 0x70,
    };
  }
}
