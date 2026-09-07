import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/outdoor_weather.dart';

/// Fetches current outdoor weather from Open-Meteo (no API key).
///
/// Docs: https://open-meteo.com/en/docs
class WeatherService {
  WeatherService({http.Client? client, this.baseUrl = defaultBaseUrl})
      : _client = client ?? http.Client();

  static const defaultBaseUrl = 'https://api.open-meteo.com';

  final http.Client _client;
  final String baseUrl;

  /// Simulated outdoor temperature used when GPS/network is unavailable.
  static const double simulatedOutdoorTempC = 34.0;

  /// Builds the forecast URL for [latitude]/[longitude].
  Uri buildForecastUri({
    required double latitude,
    required double longitude,
  }) {
    return Uri.parse('$baseUrl/v1/forecast').replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m',
      'timezone': 'auto',
    });
  }

  /// Parses an Open-Meteo forecast JSON body into [OutdoorWeather].
  /// Exposed for unit tests with mocked HTTP payloads.
  OutdoorWeather parseForecastResponse(
    String body, {
    required double latitude,
    required double longitude,
    DateTime? fetchedAt,
  }) {
    final json = jsonDecode(body) as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>?;
    if (current == null) {
      throw const FormatException('Missing current weather block');
    }

    final temp = current['temperature_2m'];
    if (temp is! num) {
      throw const FormatException('Missing temperature_2m');
    }

    final humidityRaw = current['relative_humidity_2m'];
    final humidity = humidityRaw is num ? humidityRaw.toDouble() : null;

    return OutdoorWeather(
      temperatureC: temp.toDouble(),
      humidityPercent: humidity,
      latitude: latitude,
      longitude: longitude,
      fetchedAt: fetchedAt ?? DateTime.now(),
      isSimulated: false,
    );
  }

  /// Fetches current outdoor temperature (and humidity when available).
  Future<OutdoorWeather> fetchCurrent({
    required double latitude,
    required double longitude,
  }) async {
    final uri = buildForecastUri(latitude: latitude, longitude: longitude);
    final response = await _client.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WeatherFetchException(
        'Open-Meteo HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    return parseForecastResponse(
      response.body,
      latitude: latitude,
      longitude: longitude,
    );
  }

  OutdoorWeather simulatedFallback({
    double latitude = 0,
    double longitude = 0,
  }) {
    return OutdoorWeather(
      temperatureC: simulatedOutdoorTempC,
      humidityPercent: null,
      latitude: latitude,
      longitude: longitude,
      fetchedAt: DateTime.now(),
      isSimulated: true,
    );
  }

  void dispose() {
    _client.close();
  }
}

class WeatherFetchException implements Exception {
  WeatherFetchException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'WeatherFetchException: $message';
}
