import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/outdoor_weather.dart';
import '../app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ac_display.dart';
import '../widgets/raised_remote_button.dart';
import 'settings_screen.dart';

/// Physical-style vertical AC remote controller UI.
class RemoteScreen extends StatelessWidget {
  const RemoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final state = app.acState;
    final ctrl = app.controller;
    final weatherEnabled = app.settings.weatherVsSetpointEnabled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Điều khiển máy lạnh'),
        actions: [
          if (weatherEnabled)
            IconButton(
              tooltip: 'Làm mới thời tiết',
              icon: app.weatherStatus == WeatherStatus.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_sync),
              onPressed: app.weatherStatus == WeatherStatus.loading
                  ? null
                  : () => app.refreshOutdoorWeather(requestPermission: true),
            ),
          IconButton(
            tooltip: 'Cài đặt',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (weatherEnabled) {
            await app.refreshOutdoorWeather(requestPermission: true);
          }
        },
        child: Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16),
          child: Container(
            width: 300,
            padding: const EdgeInsets.only(top: 8, bottom: 28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.remoteBodyLight,
                  AppTheme.remoteBody,
                  Color(0xFF1E2128),
                ],
              ),
              border: Border.all(color: Colors.white10, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              children: [
                // Brand label
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    app.selectedModel.brandName.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 11,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AcDisplay(
                  state: state,
                  outdoorWeather: app.outdoorWeather,
                  weatherStatus: app.weatherStatus,
                  showOutdoor: weatherEnabled,
                ),
                const SizedBox(height: 8),
                // Power
                RaisedRemoteButton(
                  onPressed: () => ctrl.togglePower(),
                  icon: Icons.power_settings_new,
                  label: 'Nguồn',
                  color: AppTheme.powerRed.withValues(alpha: 0.85),
                  size: 64,
                ),
                const SizedBox(height: 22),
                // Temp up / down
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedRemoteButton(
                      onPressed: () => ctrl.temperatureDown(),
                      icon: Icons.remove,
                      label: 'Giảm °C',
                      enabled: state.power,
                    ),
                    RaisedRemoteButton(
                      onPressed: () => ctrl.temperatureUp(),
                      icon: Icons.add,
                      label: 'Tăng °C',
                      enabled: state.power,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                // Mode / Fan / Timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedRemoteButton(
                      onPressed: () => ctrl.cycleMode(),
                      icon: Icons.tune,
                      label: 'Chế độ',
                      enabled: state.power,
                      size: 52,
                    ),
                    RaisedRemoteButton(
                      onPressed: () => ctrl.cycleFan(),
                      icon: Icons.air,
                      label: 'Quạt',
                      enabled: state.power,
                      size: 52,
                    ),
                    RaisedRemoteButton(
                      onPressed: () => ctrl.cycleTimer(),
                      icon: Icons.timer,
                      label: 'Hẹn giờ',
                      enabled: state.power,
                      size: 52,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${app.transportStatusVi} · ${app.selectedModel.pickerLabelVi}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
