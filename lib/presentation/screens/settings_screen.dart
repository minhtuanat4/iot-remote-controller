import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/ac_model_registry.dart';
import '../app_state.dart';
import '../widgets/weather_settings_section.dart';

/// Settings: AC model selection + local notification toggles.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = app.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Cai dat')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _SectionHeader('Mau may lanh'),
          ...AcModelRegistry.models.map((m) {
            return RadioListTile<String>(
              title: Text('${m.brandName} - ${m.modelName}'),
              subtitle: Text(m.descriptionVi),
              value: m.id,
              groupValue: app.selectedModel.id,
              onChanged: (id) {
                if (id != null) app.selectModel(id);
              },
            );
          }),
          const Divider(),
          const _SectionHeader('Thong bao cuc bo'),
          SwitchListTile(
            title: const Text('May lanh bat qua lau'),
            subtitle: Text(
              'Canh bao sau ${s.acOnTooLongMinutes} phut (gio may)',
            ),
            value: s.acOnTooLongEnabled,
            onChanged: (v) => app.updateSettings(
              s.copyWith(acOnTooLongEnabled: v),
            ),
          ),
          if (s.acOnTooLongEnabled)
            _MinutesSlider(
              label: 'Nguong (phut)',
              value: s.acOnTooLongMinutes.toDouble(),
              min: 30,
              max: 480,
              divisions: 15,
              onChanged: (v) => app.updateSettings(
                s.copyWith(acOnTooLongMinutes: v.round()),
              ),
            ),
          SwitchListTile(
            title: const Text('Thoi tiet ngoai troi vs setpoint'),
            subtitle: const Text(
              'Open-Meteo + GPS - canh bao khi ngoai troi < setpoint',
            ),
            value: s.weatherVsSetpointEnabled,
            onChanged: (v) => app.updateSettings(
              s.copyWith(weatherVsSetpointEnabled: v),
            ),
          ),
          if (s.weatherVsSetpointEnabled) WeatherSettingsSection(app: app),
          SwitchListTile(
            title: const Text('Canh bao hen gio bat/tat'),
            subtitle: const Text('Thong bao khi bat hoac tat hen gio'),
            value: s.timerAlertsEnabled,
            onChanged: (v) => app.updateSettings(
              s.copyWith(timerAlertsEnabled: v),
            ),
          ),
          SwitchListTile(
            title: const Text('Nhiet do thap + quat manh qua lau'),
            subtitle: Text(
              '<=${s.lowTempThreshold}C + quat manh >=${s.lowTempHighFanMinutes} phut',
            ),
            value: s.lowTempHighFanEnabled,
            onChanged: (v) => app.updateSettings(
              s.copyWith(lowTempHighFanEnabled: v),
            ),
          ),
          if (s.lowTempHighFanEnabled) ...[
            _MinutesSlider(
              label: 'Nguong thoi gian (phut)',
              value: s.lowTempHighFanMinutes.toDouble(),
              min: 15,
              max: 180,
              divisions: 11,
              onChanged: (v) => app.updateSettings(
                s.copyWith(lowTempHighFanMinutes: v.round()),
              ),
            ),
            _MinutesSlider(
              label: 'Nguong nhiet do thap (C)',
              value: s.lowTempThreshold.toDouble(),
              min: 16,
              max: 24,
              divisions: 8,
              onChanged: (v) => app.updateSettings(
                s.copyWith(lowTempThreshold: v.round()),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Thoi gian dung theo dong ho thiet bi (local time). '
              'Giai doan 1: trang thai may lanh duoc mo phong. '
              'Thoi tiet: Open-Meteo + GPS.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _MinutesSlider extends StatelessWidget {
  const _MinutesSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${value.round()}'),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
