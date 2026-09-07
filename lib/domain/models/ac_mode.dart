/// Operating modes for an air conditioner.
enum AcMode {
  cool,
  heat,
  dry,
  fan,
  auto;

  String get labelVi {
    switch (this) {
      case AcMode.cool:
        return 'Làm lạnh';
      case AcMode.heat:
        return 'Sưởi';
      case AcMode.dry:
        return 'Hút ẩm';
      case AcMode.fan:
        return 'Quạt';
      case AcMode.auto:
        return 'Tự động';
    }
  }

  String get shortLabelVi {
    switch (this) {
      case AcMode.cool:
        return 'Lạnh';
      case AcMode.heat:
        return 'Nóng';
      case AcMode.dry:
        return 'Ẩm';
      case AcMode.fan:
        return 'Quạt';
      case AcMode.auto:
        return 'Auto';
    }
  }
}
