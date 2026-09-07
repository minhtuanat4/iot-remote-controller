/// Helpers to assemble mark/space IR pulse trains (microseconds).
///
/// Timing conventions follow IRremoteESP8266 / Arduino-IRremote style:
/// header + data bits (MSB or LSB) + optional footer/gap.
class IrPulseBuilder {
  IrPulseBuilder();

  final List<int> _pulses = <int>[];

  List<int> get pulses => List<int>.unmodifiable(_pulses);

  void clear() => _pulses.clear();

  void mark(int us) => _pulses.add(us);

  void space(int us) => _pulses.add(us);

  void header(int markUs, int spaceUs) {
    mark(markUs);
    space(spaceUs);
  }

  void footerGap(int gapUs) => space(gapUs);

  /// Append one bit using mark + one/zero space (NEC-style / most AC protocols).
  void bit({
    required bool one,
    required int markUs,
    required int oneSpaceUs,
    required int zeroSpaceUs,
  }) {
    mark(markUs);
    space(one ? oneSpaceUs : zeroSpaceUs);
  }

  /// Encode [byte] bit-by-bit. [msbFirst] matches Daikin/Panasonic/Gree;
  /// LG AC commonly uses MSB-first as well in IRremoteESP8266.
  void byteBits(
    int byte, {
    required int markUs,
    required int oneSpaceUs,
    required int zeroSpaceUs,
    bool msbFirst = true,
  }) {
    final value = byte & 0xFF;
    if (msbFirst) {
      for (var i = 7; i >= 0; i--) {
        bit(
          one: ((value >> i) & 1) == 1,
          markUs: markUs,
          oneSpaceUs: oneSpaceUs,
          zeroSpaceUs: zeroSpaceUs,
        );
      }
    } else {
      for (var i = 0; i < 8; i++) {
        bit(
          one: ((value >> i) & 1) == 1,
          markUs: markUs,
          oneSpaceUs: oneSpaceUs,
          zeroSpaceUs: zeroSpaceUs,
        );
      }
    }
  }

  void bytes(
    List<int> data, {
    required int markUs,
    required int oneSpaceUs,
    required int zeroSpaceUs,
    bool msbFirst = true,
  }) {
    for (final b in data) {
      byteBits(
        b,
        markUs: markUs,
        oneSpaceUs: oneSpaceUs,
        zeroSpaceUs: zeroSpaceUs,
        msbFirst: msbFirst,
      );
    }
  }

  static String toHex(List<int> bytes) {
    final buf = StringBuffer();
    for (final b in bytes) {
      buf.write((b & 0xFF).toRadixString(16).padLeft(2, '0'));
    }
    return buf.toString();
  }

  static int checksumSum(List<int> bytes) {
    var sum = 0;
    for (final b in bytes) {
      sum = (sum + (b & 0xFF)) & 0xFF;
    }
    return sum;
  }
}
