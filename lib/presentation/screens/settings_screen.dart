import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/ac_model_registry.dart';
import '../../domain/models/ac_transport_kind.dart';
import '../app_state.dart';
import '../widgets/weather_settings_section.dart';

/// Settings: transport + AC brand/protocol + local notification toggles.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = app.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _SectionHeader('Kênh gửi lệnh'),
          RadioGroup<AcTransportKind>(
            groupValue: app.transport,
            onChanged: (v) {
              if (v != null) app.selectTransport(v);
            },
            child: Column(
              children: [
                for (final k in AcTransportKind.values)
                  RadioListTile<AcTransportKind>(
                    title: Text(k.labelVi),
                    subtitle: Text(k.descriptionVi),
                    value: k,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              app.transport == AcTransportKind.irBlaster
                  ? 'Bộ phát hiện tại: ${app.irTransmitter.labelVi}'
                      '${app.irTransmitter.isHardware ? '' : ' — chưa gắn phần cứng'}'
                  : 'Không phát IR; chỉ cập nhật giao diện.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (app.transport == AcTransportKind.irBlaster &&
              app.lastIrFrame != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'Khung IR gần nhất: ${app.lastIrFrame!.protocolId} · '
                '${app.lastIrFrame!.timingsUs.length} xung · '
                'payload ${app.lastIrFrame!.payloadHex.length ~/ 2} byte',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ),
          const Divider(),
          const _SectionHeader('Hãng / giao thức IR'),
          RadioGroup<String>(
            groupValue: app.selectedModel.id,
            onChanged: (id) {
              if (id != null) app.selectModel(id);
            },
            child: Column(
              children: [
                for (final m in AcModelRegistry.models)
                  RadioListTile<String>(
                    title: Text(m.pickerLabelVi),
                    subtitle: Text(
                      '${m.descriptionVi}\n'
                      '${m.supportsIr ? 'IR: ${m.protocolId}' : 'Chỉ mô phỏng'}',
                    ),
                    isThreeLine: true,
                    value: m.id,
                  ),
              ],
            ),
          ),
          const Divider(),
          const _SectionHeader('Thông báo cục bộ'),
          SwitchListTile(
            title: const Text('Máy lạnh bật quá lâu'),
            subtitle: Text(
              'Cảnh báo sau ${s.acOnTooLongMinutes} phút (giờ máy)',
            ),
            value: s.acOnTooLongEnabled,
            onChanged: (v) => app.updateSettings(
              s.copyWith(acOnTooLongEnabled: v),
            ),
          ),
          if (s.acOnTooLongEnabled)
            _MinutesSlider(
              label: 'Ngưỡng (phút)',
              value: s.acOnTooLongMinutes.toDouble(),
              min: 30,
              max: 480,
              divisions: 15,
              onChanged: (v) => app.updateSettings(
                s.copyWith(acOnTooLongMinutes: v.round()),
              ),
            ),
          SwitchListTile(
            title: const Text('Thời tiết ngoài trời vs setpoint'),
            subtitle: const Text(
              'Open-Meteo + GPS — cảnh báo khi ngoài trời < setpoint',
            ),
            value: s.weatherVsSetpointEnabled,
            onChanged: (v) => app.updateSettings(
              s.copyWith(weatherVsSetpointEnabled: v),
            ),
          ),
          if (s.weatherVsSetpointEnabled) WeatherSettingsSection(app: app),
          SwitchListTile(
            title: const Text('Cảnh báo hẹn giờ bật/tắt'),
            subtitle: const Text('Thông báo khi bật hoặc tắt hẹn giờ'),
            value: s.timerAlertsEnabled,
            onChanged: (v) => app.updateSettings(
              s.copyWith(timerAlertsEnabled: v),
            ),
          ),
          SwitchListTile(
            title: const Text('Nhiệt độ thấp + quạt mạnh quá lâu'),
            subtitle: Text(
              '≤${s.lowTempThreshold}°C + quạt mạnh ≥${s.lowTempHighFanMinutes} phút',
            ),
            value: s.lowTempHighFanEnabled,
            onChanged: (v) => app.updateSettings(
              s.copyWith(lowTempHighFanEnabled: v),
            ),
          ),
          if (s.lowTempHighFanEnabled) ...[
            _MinutesSlider(
              label: 'Ngưỡng thời gian (phút)',
              value: s.lowTempHighFanMinutes.toDouble(),
              min: 15,
              max: 180,
              divisions: 11,
              onChanged: (v) => app.updateSettings(
                s.copyWith(lowTempHighFanMinutes: v.round()),
              ),
            ),
            _MinutesSlider(
              label: 'Ngưỡng nhiệt độ thấp (°C)',
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
              'Thời gian dùng theo đồng hồ thiết bị (local time). '
              'IR Blaster hiện ghi log khung xung; bước tiếp: Broadlink / ESP.',
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
