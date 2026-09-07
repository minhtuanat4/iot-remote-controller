import '../models/ac_state.dart';
import '../models/ir_frame.dart';

/// Encodes an [AcState] into a brand-specific [IrFrame].
abstract class AcIrEncoder {
  String get protocolId;
  String get brandId;
  String get labelVi;

  IrFrame encode(AcState state);
}
