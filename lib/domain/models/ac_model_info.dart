/// Metadata for a pluggable AC brand/model adapter.
class AcModelInfo {
  const AcModelInfo({
    required this.id,
    required this.brandName,
    required this.modelName,
    required this.descriptionVi,
    this.protocolId,
    this.supportsIr = false,
    this.labelVi,
  });

  final String id;
  final String brandName;
  final String modelName;
  final String descriptionVi;

  /// IR protocol key when [supportsIr] is true (e.g. daikin216, gree).
  final String? protocolId;

  /// Whether an IR encoder exists for this brand.
  final bool supportsIr;

  /// Optional full Vietnamese picker label.
  final String? labelVi;

  String get pickerLabelVi =>
      labelVi ?? '$brandName — $modelName';
}
