import 'package:flutter/material.dart';

import '../../domain/models/outdoor_weather.dart';
import '../app_state.dart';

/// Weather toggle extras: status + refresh/test actions (Vietnamese labels).
class WeatherSettingsSection extends StatelessWidget {
  const WeatherSettingsSection({super.key, required this.app});

  final AppState app;

  @override
  Widget build(BuildContext context) {
    final w = app.outdoorWeather;
    final status = app.weatherStatus;
    final message = app.weatherMessageVi;

    String title;
    String? subtitle = message;
    IconData icon;

    switch (status) {
      case WeatherStatus.loading:
        title = 'Đang tải thời tiết…';
        icon = Icons.cloud_sync;
      case WeatherStatus.ready:
        final hum = w?.humidityPercent != null
            ? ', độ ẩm ${w!.humidityPercent!.round()}%'
            : '';
        title =
            'Ngoài trời: ${w?.temperatureC.toStringAsFixed(1) ?? '—'}°C$hum';
        subtitle ??= 'Nguồn: Open-Meteo';
        icon = Icons.wb_sunny_outlined;
      case WeatherStatus.permissionDenied:
      case WeatherStatus.networkError:
      case WeatherStatus.unavailable:
        title =
            'Ngoài trời (giả lập): ${w?.temperatureC.toStringAsFixed(0) ?? '34'}°C';
        icon = status == WeatherStatus.permissionDenied
            ? Icons.location_off
            : (status == WeatherStatus.networkError
                ? Icons.wifi_off
                : Icons.cloud_off);
      case WeatherStatus.idle:
        title = 'Chưa tải thời tiết';
        icon = Icons.cloud_outlined;
    }

    return Column(
      children: [
        ListTile(
          leading: status == WeatherStatus.loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: status == WeatherStatus.loading
                      ? null
                      : () => app.refreshOutdoorWeather(
                            requestPermission: true,
                          ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Làm mới thời tiết'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    app.monitor.triggerWeatherAlert(app.acState.temperature);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã gửi thông báo thời tiết'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.cloud),
                  label: const Text('Thử cảnh báo'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
