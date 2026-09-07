/// Current outdoor conditions from a weather API (Open-Meteo).
class OutdoorWeather {
  const OutdoorWeather({
    required this.temperatureC,
    this.humidityPercent,
    required this.latitude,
    required this.longitude,
    required this.fetchedAt,
    this.isSimulated = false,
  });

  final double temperatureC;
  final double? humidityPercent;
  final double latitude;
  final double longitude;
  final DateTime fetchedAt;

  /// True when using the simulated fallback value (no GPS / network).
  final bool isSimulated;

  OutdoorWeather copyWith({
    double? temperatureC,
    double? humidityPercent,
    double? latitude,
    double? longitude,
    DateTime? fetchedAt,
    bool? isSimulated,
  }) {
    return OutdoorWeather(
      temperatureC: temperatureC ?? this.temperatureC,
      humidityPercent: humidityPercent ?? this.humidityPercent,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isSimulated: isSimulated ?? this.isSimulated,
    );
  }
}

/// UI / app-level status for outdoor weather loading.
enum WeatherStatus {
  idle,
  loading,
  ready,
  permissionDenied,
  networkError,
  unavailable,
}
