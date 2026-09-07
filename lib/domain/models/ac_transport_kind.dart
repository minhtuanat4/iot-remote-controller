/// How AC commands leave the app.
enum AcTransportKind {
  /// Local UI/state only — no IR frames.
  simulated,

  /// Encode brand IR frames and hand them to an [IrTransmitter].
  irBlaster;

  String get labelVi {
    switch (this) {
      case AcTransportKind.simulated:
        return 'Mo phong (khong IR)';
      case AcTransportKind.irBlaster:
        return 'IR Blaster';
    }
  }

  String get descriptionVi {
    switch (this) {
      case AcTransportKind.simulated:
        return 'Chi cap nhat giao dien - dung de thu remote';
      case AcTransportKind.irBlaster:
        return 'Ma hoa lenh theo hang va gui qua bo phat IR '
            '(hien tai: IR gia lap / log)';
    }
  }

  static AcTransportKind fromId(String? id) {
    return AcTransportKind.values.firstWhere(
      (k) => k.name == id,
      orElse: () => AcTransportKind.simulated,
    );
  }
}
