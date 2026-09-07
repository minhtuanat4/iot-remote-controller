import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iot_remote_controller/data/services/weather_service.dart';

void main() {
  group('WeatherService', () {
    test('parseForecastResponse reads temperature and humidity', () {
      const body = '''
{
  "latitude": 10.82,
  "longitude": 106.63,
  "current": {
    "time": "2026-09-07T14:00",
    "interval": 900,
    "temperature_2m": 31.4,
    "relative_humidity_2m": 72
  }
}
''';
      final service = WeatherService(client: http.Client());
      final weather = service.parseForecastResponse(
        body,
        latitude: 10.82,
        longitude: 106.63,
        fetchedAt: DateTime.utc(2026, 9, 7, 7),
      );

      expect(weather.temperatureC, 31.4);
      expect(weather.humidityPercent, 72);
      expect(weather.latitude, 10.82);
      expect(weather.longitude, 106.63);
      expect(weather.isSimulated, isFalse);
    });

    test('parseForecastResponse throws when current block missing', () {
      final service = WeatherService(client: http.Client());
      expect(
        () => service.parseForecastResponse(
          '{"latitude":1.0,"longitude":2.0}',
          latitude: 1,
          longitude: 2,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('fetchCurrent uses mocked HTTP response', () async {
      final mock = MockClient((request) async {
        expect(request.url.host, 'api.open-meteo.com');
        expect(request.url.queryParameters['latitude'], '10.8');
        expect(request.url.queryParameters['longitude'], '106.6');
        expect(
          request.url.queryParameters['current'],
          'temperature_2m,relative_humidity_2m',
        );
        return http.Response(
          '''
{
  "current": {
    "temperature_2m": 29.5,
    "relative_humidity_2m": 80
  }
}
''',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = WeatherService(client: mock);
      final weather = await service.fetchCurrent(
        latitude: 10.8,
        longitude: 106.6,
      );

      expect(weather.temperatureC, 29.5);
      expect(weather.humidityPercent, 80);
      expect(weather.isSimulated, isFalse);
    });

    test('fetchCurrent throws WeatherFetchException on non-2xx', () async {
      final mock = MockClient(
        (_) async => http.Response('fail', 503),
      );
      final service = WeatherService(client: mock);
      expect(
        () => service.fetchCurrent(latitude: 1, longitude: 2),
        throwsA(isA<WeatherFetchException>()),
      );
    });

    test('simulatedFallback marks isSimulated', () {
      final service = WeatherService(client: http.Client());
      final weather = service.simulatedFallback();
      expect(weather.isSimulated, isTrue);
      expect(weather.temperatureC, WeatherService.simulatedOutdoorTempC);
    });
  });
}
