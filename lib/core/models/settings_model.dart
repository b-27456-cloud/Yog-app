class SettingsModel {
  final AccessibilitySettings? accessibility;
  final AppSettings? settings;
  final PrivacySettings? privacy;

  SettingsModel({
    this.accessibility,
    this.settings,
    this.privacy,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      accessibility: json['accessibility'] != null
          ? AccessibilitySettings.fromJson(json['accessibility'])
          : null,
      settings: json['settings'] != null
          ? AppSettings.fromJson(json['settings'])
          : null,
      privacy: json['privacy'] != null
          ? PrivacySettings.fromJson(json['privacy'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (accessibility != null) 'accessibility': accessibility!.toJson(),
      if (settings != null) 'settings': settings!.toJson(),
      if (privacy != null) 'privacy': privacy!.toJson(),
    };
  }
}

class AccessibilitySettings {
  final String? profile;
  final String? fontSize;
  final String? theme;
  final bool? voiceGuidance;
  final bool? hapticFeedback;

  AccessibilitySettings({
    this.profile,
    this.fontSize,
    this.theme,
    this.voiceGuidance,
    this.hapticFeedback,
  });

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      profile: json['profile'],
      fontSize: json['font_size'],
      theme: json['theme'],
      voiceGuidance: json['voice_guidance'],
      hapticFeedback: json['haptic_feedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile': profile,
      'font_size': fontSize,
      'theme': theme,
      'voice_guidance': voiceGuidance,
      'haptic_feedback': hapticFeedback,
    };
  }
}

class AppSettings {
  final String? language;
  final bool? notifications;

  AppSettings({
    this.language,
    this.notifications,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      language: json['language'],
      notifications: json['notifications'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'notifications': notifications,
    };
  }
}

class PrivacySettings {
  final bool? showOnLeaderboard;

  PrivacySettings({
    this.showOnLeaderboard,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      showOnLeaderboard: json['show_on_leaderboard'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show_on_leaderboard': showOnLeaderboard,
    };
  }
}
