/// Fan speed levels for an air conditioner.
enum FanSpeed {
  auto,
  low,
  medium,
  high;

  String get labelVi {
    switch (this) {
      case FanSpeed.auto:
        return 'Tự động';
      case FanSpeed.low:
        return 'Nhẹ';
      case FanSpeed.medium:
        return 'Vừa';
      case FanSpeed.high:
        return 'Mạnh';
    }
  }

  String get shortLabelVi {
    switch (this) {
      case FanSpeed.auto:
        return 'Auto';
      case FanSpeed.low:
        return '1';
      case FanSpeed.medium:
        return '2';
      case FanSpeed.high:
        return '3';
    }
  }
}
