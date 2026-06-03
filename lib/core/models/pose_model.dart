import 'package:flutter/material.dart';

class PoseModel {
  final String id;
  final String name;
  final String difficulty;
  final String description;
  final int durationMinutes;
  final int calories;
  final List<String> benefits;
  final List<Map<String, String>> steps;
  final IconData icon;

  const PoseModel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.description,
    required this.durationMinutes,
    required this.calories,
    required this.benefits,
    required this.steps,
    required this.icon,
  });
}
