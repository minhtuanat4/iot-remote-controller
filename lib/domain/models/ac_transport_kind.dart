/// How AC commands leave the app.
enum AcTransportKind {
  /// Local UI/state only — no IR frames.
  simulated,

  /// Encode brand IR frames and hand them to an [IrTransmitter].
  irBlaster;

  String get labelVi {
    switch (this) {
      case AcTransportKind.simulated:
        return 'Mô phỏng (không IR)';
      case AcTransportKind.irBlaster:
        return 'IR Blaster';
    }
  }

  String get descriptionVi {
    switch (this) {
      case AcTransportKind.simulated:
        return 'Chỉ cập nhật giao diện — dùng để thử remote';
      case AcTransportKind.irBlaster:
        return 'Mã hóa lệnh theo hãng và gửi qua bộ phát IR '
            '(hiện tại: IR giả lập / log)';
    }
  }

  static AcTransportKind fromId(String? id) {
    return AcTransportKind.values.firstWhere(
      (k) => k.name == id,
      orElse: () => AcTransportKind.simulated,
    );
  }
}
