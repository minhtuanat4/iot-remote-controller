import '../../domain/models/ac_model_info.dart';
import '../../domain/models/ac_transport_kind.dart';
import '../../domain/services/ac_controller.dart';
import '../../domain/services/ir_transmitter.dart';
import '../ir/encoders/ir_encoder_registry.dart';
import '../repositories/ir_blaster_ac_controller.dart';
import '../repositories/simulated_ac_controller.dart';

/// Pluggable registry of AC brand/model adapters for the Vietnam market.
///
/// Simulated transport works for every entry. IR Blaster transport works
/// for brands with an encoder (Daikin, Panasonic, LG, Casper, Funiki).
class AcModelRegistry {
  AcModelRegistry._();

  static final List<AcModelInfo> models = [
    const AcModelInfo(
      id: 'generic',
      brandName: 'Generic',
      modelName: 'Universal',
      descriptionVi: 'Điều khiển mô phỏng chung (không mã IR hãng)',
      labelVi: 'Chung (mô phỏng)',
      supportsIr: false,
    ),
    const AcModelInfo(
      id: 'daikin',
      brandName: 'Daikin',
      modelName: 'Daikin216',
      protocolId: 'daikin216',
      descriptionVi: 'Daikin phổ biến tại VN — giao thức Daikin216',
      labelVi: 'Daikin',
      supportsIr: true,
    ),
    const AcModelInfo(
      id: 'panasonic',
      brandName: 'Panasonic',
      modelName: 'PanasonicAc',
      protocolId: 'panasonic_ac',
      descriptionVi: 'Panasonic — giao thức PanasonicAc 216-bit',
      labelVi: 'Panasonic',
      supportsIr: true,
    ),
    const AcModelInfo(
      id: 'lg',
      brandName: 'LG',
      modelName: 'LG AC',
      protocolId: 'lg_ac',
      descriptionVi: 'LG — giao thức LG AC 28-bit',
      labelVi: 'LG',
      supportsIr: true,
    ),
    const AcModelInfo(
      id: 'casper',
      brandName: 'Casper',
      modelName: 'Gree-family',
      protocolId: 'gree',
      descriptionVi: 'Casper (OEM Gree) — phổ biến tại Việt Nam',
      labelVi: 'Casper',
      supportsIr: true,
    ),
    const AcModelInfo(
      id: 'funiki',
      brandName: 'Funiki',
      modelName: 'Gree-family',
      protocolId: 'gree',
      descriptionVi: 'Funiki (OEM Gree) — phổ biến tại Việt Nam',
      labelVi: 'Funiki',
      supportsIr: true,
    ),
  ];

  static AcModelInfo getById(String id) {
    return models.firstWhere(
      (m) => m.id == id,
      orElse: () => models.first,
    );
  }

  static List<AcModelInfo> get irCapableModels =>
      models.where((m) => m.supportsIr).toList(growable: false);

  /// Creates a controller for the given model + transport.
  ///
  /// [transmitter] is required when [transport] is irBlaster; a shared
  /// logging transmitter is typical in development.
  static AcController createController(
    String modelId, {
    AcTransportKind transport = AcTransportKind.simulated,
    IrTransmitter? transmitter,
  }) {
    switch (transport) {
      case AcTransportKind.simulated:
        return SimulatedAcController(modelId: modelId);
      case AcTransportKind.irBlaster:
        final model = getById(modelId);
        final brandId = model.supportsIr ? model.id : 'daikin';
        final enc = IrEncoderRegistry.get(brandId);
        final tx = transmitter ?? LoggingIrTransmitter();
        return IrBlasterAcController(
          modelId: brandId,
          encoder: enc,
          transmitter: tx,
        );
    }
  }
}
