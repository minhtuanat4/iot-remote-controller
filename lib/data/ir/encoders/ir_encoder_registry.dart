import '../../../domain/services/ac_ir_encoder.dart';
import 'daikin_encoder.dart';
import 'gree_encoder.dart';
import 'lg_encoder.dart';
import 'panasonic_encoder.dart';

/// Maps Vietnam-market brand ids to IR encoders.
class IrEncoderRegistry {
  IrEncoderRegistry._();

  static final Map<String, AcIrEncoder> _encoders = {
    'daikin': DaikinIrEncoder(),
    'panasonic': PanasonicIrEncoder(),
    'lg': LgIrEncoder(),
    'casper': CasperIrEncoder(),
    'funiki': FunikiIrEncoder(),
  };

  static AcIrEncoder? tryGet(String brandId) => _encoders[brandId];

  static AcIrEncoder get(String brandId) {
    final enc = _encoders[brandId];
    if (enc == null) {
      throw ArgumentError('No IR encoder for brand "$brandId"');
    }
    return enc;
  }

  static List<AcIrEncoder> get all =>
      List<AcIrEncoder>.unmodifiable(_encoders.values);

  static bool supports(String brandId) => _encoders.containsKey(brandId);
}
