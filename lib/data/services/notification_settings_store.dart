import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/ac_transport_kind.dart';
import '../../domain/models/notification_settings.dart';

/// Persists notification toggles/thresholds and transport selection locally.
class NotificationSettingsStore {
  static const _key = 'notification_settings';
  static const _modelKey = 'selected_ac_model';
  static const _transportKey = 'selected_ac_transport';

  Future<NotificationSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const NotificationSettings();
    try {
      return NotificationSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const NotificationSettings();
    }
  }

  Future<void> save(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
  }

  Future<String> loadSelectedModelId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_modelKey) ?? 'generic';
  }

  Future<void> saveSelectedModelId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modelKey, id);
  }

  Future<AcTransportKind> loadTransportKind() async {
    final prefs = await SharedPreferences.getInstance();
    return AcTransportKind.fromId(prefs.getString(_transportKey));
  }

  Future<void> saveTransportKind(AcTransportKind kind) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_transportKey, kind.name);
  }
}
