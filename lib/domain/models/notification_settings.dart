/// User preferences for local notification alerts.
class NotificationSettings {
  const NotificationSettings({
    this.acOnTooLongEnabled = true,
    this.acOnTooLongMinutes = 180,
    this.weatherVsSetpointEnabled = false,
    this.timerAlertsEnabled = true,
    this.lowTempHighFanEnabled = true,
    this.lowTempHighFanMinutes = 60,
    this.lowTempThreshold = 20,
  });

  /// Alert when AC has been on longer than [acOnTooLongMinutes].
  final bool acOnTooLongEnabled;
  final int acOnTooLongMinutes;

  /// Alert when outdoor temp (Open-Meteo/GPS) is below AC setpoint.
  final bool weatherVsSetpointEnabled;

  /// Alert when timer turns on/off.
  final bool timerAlertsEnabled;

  /// Alert when low temp + high fan lasts too long.
  final bool lowTempHighFanEnabled;
  final int lowTempHighFanMinutes;
  final int lowTempThreshold;

  NotificationSettings copyWith({
    bool? acOnTooLongEnabled,
    int? acOnTooLongMinutes,
    bool? weatherVsSetpointEnabled,
    bool? timerAlertsEnabled,
    bool? lowTempHighFanEnabled,
    int? lowTempHighFanMinutes,
    int? lowTempThreshold,
  }) {
    return NotificationSettings(
      acOnTooLongEnabled: acOnTooLongEnabled ?? this.acOnTooLongEnabled,
      acOnTooLongMinutes: acOnTooLongMinutes ?? this.acOnTooLongMinutes,
      weatherVsSetpointEnabled:
          weatherVsSetpointEnabled ?? this.weatherVsSetpointEnabled,
      timerAlertsEnabled: timerAlertsEnabled ?? this.timerAlertsEnabled,
      lowTempHighFanEnabled:
          lowTempHighFanEnabled ?? this.lowTempHighFanEnabled,
      lowTempHighFanMinutes:
          lowTempHighFanMinutes ?? this.lowTempHighFanMinutes,
      lowTempThreshold: lowTempThreshold ?? this.lowTempThreshold,
    );
  }

  Map<String, dynamic> toJson() => {
        'acOnTooLongEnabled': acOnTooLongEnabled,
        'acOnTooLongMinutes': acOnTooLongMinutes,
        'weatherVsSetpointEnabled': weatherVsSetpointEnabled,
        'timerAlertsEnabled': timerAlertsEnabled,
        'lowTempHighFanEnabled': lowTempHighFanEnabled,
        'lowTempHighFanMinutes': lowTempHighFanMinutes,
        'lowTempThreshold': lowTempThreshold,
      };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      acOnTooLongEnabled: json['acOnTooLongEnabled'] as bool? ?? true,
      acOnTooLongMinutes: json['acOnTooLongMinutes'] as int? ?? 180,
      weatherVsSetpointEnabled:
          json['weatherVsSetpointEnabled'] as bool? ?? false,
      timerAlertsEnabled: json['timerAlertsEnabled'] as bool? ?? true,
      lowTempHighFanEnabled: json['lowTempHighFanEnabled'] as bool? ?? true,
      lowTempHighFanMinutes: json['lowTempHighFanMinutes'] as int? ?? 60,
      lowTempThreshold: json['lowTempThreshold'] as int? ?? 20,
    );
  }
}
