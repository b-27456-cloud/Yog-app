import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/models/pose_model.dart';
import 'pose_service.dart';

class PoseProvider extends ChangeNotifier {
  final PoseService _poseService = PoseService();
  
  // Data
  List<PoseModel> _allPoses = [];
  List<PoseModel> get allPoses => _allPoses;
  
  List<PoseModel> _filteredPoses = [];
  List<PoseModel> get filteredPoses => _filteredPoses;
  
  // State
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  bool _hasLoadedPoses = false;
  bool get hasLoadedPoses => _hasLoadedPoses;
  
  // Filters
  String _searchQuery = '';
  String _selectedDifficulty = 'All';
  String _selectedArea = 'All';
  
  // Initialize and fetch poses (call once on app startup)
  Future<void> initializePoses() async {
    if (_hasLoadedPoses) return; // Already loaded, don't fetch again
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Try to fetch from API
      final response = await _poseService.getPoses();
      final poses = _parsePosesFromResponse(response);
      
      _allPoses = poses;
      _filteredPoses = poses;
      _hasLoadedPoses = true;
      
      // Cache to SharedPreferences for offline support
      await _cachePosesToPreferences(poses);
      
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      // Try to load from cache if API fails
      await _loadPosesFromCache();
      
      if (_allPoses.isEmpty) {
        _errorMessage = 'Failed to load poses. Please try again.';
      }
      
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Apply search and filters
  void applyFilters({
    String? searchQuery,
    String? difficulty,
    String? area,
  }) {
    if (searchQuery != null) _searchQuery = searchQuery.toLowerCase();
    if (difficulty != null) _selectedDifficulty = difficulty;
    if (area != null) _selectedArea = area;
    
    _updateFilteredPoses();
  }
  
  // Update filtered list based on current filters
  void _updateFilteredPoses() {
    _filteredPoses = _allPoses.where((pose) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          pose.name.toLowerCase().contains(_searchQuery) ||
          pose.description.toLowerCase().contains(_searchQuery);
      
      // Difficulty filter
      final matchesDifficulty = _selectedDifficulty == 'All' ||
          pose.difficulty.toLowerCase() == _selectedDifficulty.toLowerCase();
      
      // Area filter
      final matchesArea = _selectedArea == 'All' ||
          pose.targetAreas.any((area) =>
              area.toLowerCase().contains(_selectedArea.toLowerCase()));
      
      return matchesSearch && matchesDifficulty && matchesArea;
    }).toList();
    
    notifyListeners();
  }
  
  // Get featured pose (first one)
  PoseModel? getFeaturedPose() {
    if (_allPoses.isEmpty) return null;
    return _allPoses.first;
  }
  
  // Get pose by ID (for details page)
  PoseModel? getPoseById(String id) {
    try {
      return _allPoses.firstWhere((pose) => pose.id == id || pose.slug == id);
    } catch (e) {
      return null;
    }
  }
  
  // Parse poses from API response
  List<PoseModel> _parsePosesFromResponse(Map<String, dynamic> response) {
    final List posesJson = response['data'] ?? response['poses'] ?? [];
    return posesJson
        .map((json) => PoseModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
  
  // Save poses to SharedPreferences
  Future<void> _cachePosesToPreferences(List<PoseModel> poses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final posesJson = jsonEncode(
        poses.map((p) => {
          '_id': p.id,
          'slug': p.slug,
          'name': p.name,
          'difficulty': p.difficulty,
          'description': p.description,
          'duration_seconds': p.durationMinutes * 60,
          'expected_calories': p.calories,
          'benefits': p.benefits,
          'target_areas': p.targetAreas,
          'contraindications': p.contraindications,
          'image_url': p.imageUrl,
          'video': p.videoUrl != null ? {'full_url': p.videoUrl} : null,
        }).toList(),
      );
      
      await prefs.setString('cached_poses', posesJson);
      await prefs.setInt('cached_poses_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching poses: $e');
    }
  }
  
  // Load poses from SharedPreferences cache
  Future<void> _loadPosesFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_poses');
      
      if (cached != null) {
        final List decodedList = jsonDecode(cached);
        _allPoses = decodedList
            .map((json) => PoseModel.fromJson(json as Map<String, dynamic>))
            .toList();
        _filteredPoses = _allPoses;
        _hasLoadedPoses = true;
      }
    } catch (e) {
      print('Error loading cache: $e');
    }
  }
  
  // Retry loading poses
  Future<void> retry() async {
    _hasLoadedPoses = false;
    await initializePoses();
  }
}
