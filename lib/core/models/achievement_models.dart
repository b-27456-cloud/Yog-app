class Achievement {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String category;
  final String conditionType;
  final int conditionValue;
  final int pointsReward;
  final String? iconUrl;

  Achievement({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.category,
    required this.conditionType,
    required this.conditionValue,
    required this.pointsReward,
    this.iconUrl,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    final condition = json['condition'] as Map<String, dynamic>? ?? {};
    return Achievement(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      conditionType: (condition['type'] ?? '').toString(),
      conditionValue: (condition['value'] as num? ?? 0).toInt(),
      pointsReward: (json['points_reward'] as num? ?? 0).toInt(),
      iconUrl: json['icon_url'] as String?,
    );
  }
}

class UserAchievement {
  final String id;
  final String userId;
  final Achievement achievement;
  final int pointsEarned;
  final DateTime? earnedAt;

  UserAchievement({
    required this.id,
    required this.userId,
    required this.achievement,
    required this.pointsEarned,
    this.earnedAt,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: (json['_id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      achievement: Achievement.fromJson(
        json['achievement_id'] as Map<String, dynamic>? ?? {},
      ),
      pointsEarned: (json['points_earned'] as num? ?? 0).toInt(),
      earnedAt: json['earned_at'] != null
          ? DateTime.tryParse(json['earned_at'].toString())
          : null,
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool read;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      type: (json['type'] ?? 'system').toString(),
      read: (json['read'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
