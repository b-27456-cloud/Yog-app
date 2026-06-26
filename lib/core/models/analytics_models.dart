class UserStats {
  final int streak;
  final int longestStreak;
  final int totalMinutes;
  final int totalSessions;
  final FavoritePose? favoritePose;

  UserStats({
    required this.streak,
    required this.longestStreak,
    required this.totalMinutes,
    required this.totalSessions,
    this.favoritePose,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      streak: json['streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      totalMinutes: json['total_minutes'] ?? 0,
      totalSessions: json['total_sessions'] ?? 0,
      favoritePose: json['favorite_pose'] != null
          ? FavoritePose.fromJson(json['favorite_pose'])
          : null,
    );
  }
}

class FavoritePose {
  final String poseName;
  final int count;

  FavoritePose({
    required this.poseName,
    required this.count,
  });

  factory FavoritePose.fromJson(Map<String, dynamic> json) {
    return FavoritePose(
      poseName: json['pose_name'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class UserStreak {
  final String streakId;
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastSessionDate;
  final DateTime? streakStartDate;
  final int totalDaysPracticed;
  final int totalMinutesPracticed;
  final int availableFreezes;
  final DateTime? createdAt;

  UserStreak({
    required this.streakId,
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastSessionDate,
    this.streakStartDate,
    required this.totalDaysPracticed,
    required this.totalMinutesPracticed,
    required this.availableFreezes,
    this.createdAt,
  });

  factory UserStreak.fromJson(Map<String, dynamic> json) {
    return UserStreak(
      streakId: json['streak_id'] ?? '',
      userId: json['user_id'] ?? '',
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastSessionDate: json['last_session_date'] != null
          ? DateTime.tryParse(json['last_session_date'])
          : null,
      streakStartDate: json['streak_start_date'] != null
          ? DateTime.tryParse(json['streak_start_date'])
          : null,
      totalDaysPracticed: json['total_days_practiced'] ?? 0,
      totalMinutesPracticed: json['total_minutes_practiced'] ?? 0,
      availableFreezes: json['available_freezes'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}

class SessionRecord {
  final String sessionId;
  final SessionPose pose;
  final DateTime? startTime;
  final int durationSeconds;
  final int accuracyAverage;
  final bool completed;

  SessionRecord({
    required this.sessionId,
    required this.pose,
    this.startTime,
    required this.durationSeconds,
    required this.accuracyAverage,
    required this.completed,
  });

  factory SessionRecord.fromJson(Map<String, dynamic> json) {
    return SessionRecord(
      sessionId: json['session_id'] ?? '',
      pose: SessionPose.fromJson(json['pose_id'] ?? {}),
      startTime: json['start_time'] != null
          ? DateTime.tryParse(json['start_time'])
          : null,
      durationSeconds: json['duration_seconds'] ?? 0,
      accuracyAverage: json['accuracy_average'] ?? 0,
      completed: json['completed'] ?? false,
    );
  }
}

class SessionPose {
  final String name;
  final String slug;
  final int level;

  SessionPose({
    required this.name,
    required this.slug,
    required this.level,
  });

  factory SessionPose.fromJson(Map<String, dynamic> json) {
    return SessionPose(
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      level: json['level'] ?? 1,
    );
  }
}

class SessionMeta {
  final int total;
  final int page;
  final int limit;
  final int pages;

  SessionMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory SessionMeta.fromJson(Map<String, dynamic> json) {
    return SessionMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 1,
    );
  }
}

class SessionResponse {
  final List<SessionRecord> sessions;
  final SessionMeta? meta;

  SessionResponse({
    required this.sessions,
    this.meta,
  });

  factory SessionResponse.fromJson(Map<String, dynamic> json) {
    var list = json['sessions'] as List? ?? [];
    return SessionResponse(
      sessions: list.map((i) => SessionRecord.fromJson(i)).toList(),
      meta: json['meta'] != null ? SessionMeta.fromJson(json['meta']) : null,
    );
  }
}
