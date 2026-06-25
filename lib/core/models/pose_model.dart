import 'package:flutter/material.dart';

class PoseModel {
  final String id;      // MongoDB _id
  final String slug;    // URL-friendly slug (e.g. "warrior-ii")
  final String name;
  final String difficulty;
  final String description;
  final int durationMinutes;
  final int calories;
  final List<String> benefits;
  final List<Map<String, String>> steps;
  final String? imageUrl;
  final String? videoUrl;
  final List<String> targetAreas;
  final List<String> contraindications;
  final IconData icon;

  const PoseModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.difficulty,
    required this.description,
    required this.durationMinutes,
    required this.calories,
    required this.benefits,
    required this.steps,
    required this.targetAreas,
    required this.contraindications,
    this.imageUrl,
    this.videoUrl,
    required this.icon,
  });

  /// Maps the backend `difficulty` string to an icon
  static IconData _iconForDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'advanced':
        return Icons.whatshot;
      case 'intermediate':
        return Icons.fitness_center;
      default:
        return Icons.self_improvement;
    }
  }

  /// Parses the real backend response.
  /// Both the list API (uses "poses" key) and detail API (uses "data" key)
  /// return pose objects in the same shape, so this factory handles both.
  factory PoseModel.fromJson(Map<String, dynamic> json) {
    // ID: backend uses "_id" (MongoDB ObjectId)
    final String id = (json['_id'] ?? json['pose_id'] ?? json['id'] ?? '').toString();

    // Slug for URL navigation (e.g. "warrior-ii")
    final String slug = (json['slug'] ?? '').toString();

    // Instructions come as a List<String>
    final List<Map<String, String>> steps =
        (json['instructions'] as List<dynamic>?)
            ?.asMap()
            .entries
            .map((e) => {
                  'title': 'Step ${e.key + 1}',
                  'desc': e.value.toString(),
                })
            .toList() ??
        [];

    // Video URL nested under "video.full_url"
    final videoMap = json['video'] as Map<String, dynamic>?;
    final String? videoUrl = videoMap?['full_url'] as String?;

    return PoseModel(
      id: id,
      slug: slug,
      name: (json['name'] ?? 'Unknown Pose').toString(),
      difficulty: (json['difficulty'] ?? 'beginner').toString(),
      description: (json['description'] ?? '').toString(),
      durationMinutes: (((json['duration_seconds'] as num?) ?? 0) / 60).round(),
      calories: ((json['expected_calories'] as num?) ?? (json['calories'] as num?) ?? 0).toInt(),
      benefits: List<String>.from(json['benefits'] ?? []),
      steps: steps,
      targetAreas: List<String>.from(json['target_areas'] ?? []),
      contraindications: List<String>.from(json['contraindications'] ?? []),
      imageUrl: json['image_url'] as String?,
      videoUrl: videoUrl,
      icon: _iconForDifficulty((json['difficulty'] ?? '').toString()),
    );
  }
}
