/// Metadata for a pluggable AC brand/model adapter.
class AcModelInfo {
  const AcModelInfo({
    required this.id,
    required this.brandName,
    required this.modelName,
    required this.descriptionVi,
  });

  final String id;
  final String brandName;
  final String modelName;
  final String descriptionVi;
}
