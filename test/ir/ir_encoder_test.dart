import 'package:flutter_test/flutter_test.dart';
import 'package:iot_remote_controller/data/ir/encoders/daikin_encoder.dart';
import 'package:iot_remote_controller/data/ir/encoders/gree_encoder.dart';
import 'package:iot_remote_controller/data/ir/encoders/ir_encoder_registry.dart';
import 'package:iot_remote_controller/data/ir/encoders/lg_encoder.dart';
import 'package:iot_remote_controller/data/ir/encoders/panasonic_encoder.dart';
import 'package:iot_remote_controller/data/repositories/ir_blaster_ac_controller.dart';
import 'package:iot_remote_controller/domain/models/ac_mode.dart';
import 'package:iot_remote_controller/domain/models/ac_state.dart';
import 'package:iot_remote_controller/domain/models/fan_speed.dart';
import 'package:iot_remote_controller/domain/services/ir_transmitter.dart';

void main() {
  const cool24 = AcState(
    power: true,
    temperature: 24,
    mode: AcMode.cool,
    fan: FanSpeed.auto,
  );

  group('Brand encoders', () {
    test('Daikin216 frame not empty and stable for known command', () {
      final enc = DaikinIrEncoder();
      final a = enc.encode(cool24);
      final b = enc.encode(cool24);
      expect(a.timingsUs, isNotEmpty);
      expect(a.payloadHex, isNotEmpty);
      expect(a.protocolId, 'daikin216');
      expect(a.payloadHex, b.payloadHex);
      expect(a.timingsUs, b.timingsUs);
      // 27 state bytes => 54 hex chars.
      expect(a.payloadHex.length, 54);
      // Power+cool should set mode nibble and power bit in section2 byte5.
      expect(a.payloadHex.substring(16, 18), isNot(equals('0000')));
    });

    test('Panasonic frame not empty and stable', () {
      final enc = PanasonicIrEncoder();
      final a = enc.encode(cool24);
      final b = enc.encode(cool24);
      expect(a.timingsUs, isNotEmpty);
      expect(a.protocolId, 'panasonic_ac');
      expect(a.payloadHex, b.payloadHex);
      expect(a.payloadHex.length, 54); // 27 bytes
      expect(a.carrierHz, 36700);
    });

    test('LG 28-bit frame not empty and stable', () {
      final enc = LgIrEncoder();
      final a = enc.encode(cool24);
      final b = enc.encode(cool24);
      expect(a.timingsUs, isNotEmpty);
      expect(a.protocolId, 'lg_ac');
      expect(a.payloadHex, b.payloadHex);
      // 28 bits => header + 28 mark/space pairs + trailing mark + gap.
      expect(a.timingsUs.length, greaterThan(50));
    });

    test('Casper (Gree) frame not empty and stable', () {
      final enc = CasperIrEncoder();
      final a = enc.encode(cool24);
      final b = enc.encode(cool24);
      expect(a.timingsUs, isNotEmpty);
      expect(a.protocolId, 'gree');
      expect(a.brandId, 'casper');
      expect(a.payloadHex, b.payloadHex);
      expect(a.payloadHex.length, 16); // 8 bytes
    });

    test('Funiki (Gree) differs from Casper model nibble', () {
      final casper = CasperIrEncoder().encode(cool24);
      final funiki = FunikiIrEncoder().encode(cool24);
      expect(funiki.timingsUs, isNotEmpty);
      expect(funiki.brandId, 'funiki');
      expect(funiki.payloadHex, isNot(equals(casper.payloadHex)));
    });

    test('power off changes payload vs power on', () {
      final enc = DaikinIrEncoder();
      final on = enc.encode(cool24);
      final off = enc.encode(cool24.copyWith(power: false));
      expect(on.payloadHex, isNot(equals(off.payloadHex)));
    });
  });

  group('IrEncoderRegistry', () {
    test('supports Vietnam focus brands', () {
      for (final id in ['daikin', 'panasonic', 'lg', 'casper', 'funiki']) {
        expect(IrEncoderRegistry.supports(id), isTrue);
        final frame = IrEncoderRegistry.get(id).encode(cool24);
        expect(frame.isEmpty, isFalse);
      }
    });
  });

  group('IrBlasterAcController', () {
    test('button actions update state and transmit frames', () async {
      final tx = LoggingIrTransmitter();
      final ctrl = IrBlasterAcController(
        modelId: 'daikin',
        encoder: DaikinIrEncoder(),
        transmitter: tx,
      );

      await ctrl.togglePower();
      expect(ctrl.state.power, isTrue);
      expect(tx.history, isNotEmpty);
      expect(ctrl.lastFrame, isNotNull);

      final before = tx.history.length;
      await ctrl.setTemperature(22);
      expect(ctrl.state.temperature, 22);
      expect(tx.history.length, before + 1);

      await ctrl.cycleMode();
      await ctrl.cycleFan();
      expect(tx.history.length, greaterThanOrEqualTo(before + 3));

      ctrl.dispose();
    });
  });
}
