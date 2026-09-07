import '../../domain/models/ac_model_info.dart';
import '../../domain/services/ac_controller.dart';
import '../repositories/simulated_ac_controller.dart';

/// Pluggable registry of AC brand/model stubs.
/// Phase 1: Generic + Daikin + Panasonic simulated adapters.
class AcModelRegistry {
  AcModelRegistry._();

  static final List<AcModelInfo> models = [
    const AcModelInfo(
      id: 'generic',
      brandName: 'Generic',
      modelName: 'Universal',
      descriptionVi: 'Điều khiển mô phỏng chung cho mọi máy lạnh',
    ),
    const AcModelInfo(
      id: 'daikin',
      brandName: 'Daikin',
      modelName: 'Stub',
      descriptionVi: 'Bộ điều hợp Daikin (giả lập — chưa gửi IR/API)',
    ),
    const AcModelInfo(
      id: 'panasonic',
      brandName: 'Panasonic',
      modelName: 'Stub',
      descriptionVi: 'Bộ điều hợp Panasonic (giả lập — chưa gửi IR/API)',
    ),
  ];

  static AcModelInfo getById(String id) {
    return models.firstWhere(
      (m) => m.id == id,
      orElse: () => models.first,
    );
  }

  /// Creates a simulated controller for the given model id.
  static AcController createController(String modelId) {
    // Phase 1: all brands share the same simulated controller.
    // Future phases will map to IR codes / cloud APIs per brand.
    return SimulatedAcController(modelId: modelId);
  }
}
