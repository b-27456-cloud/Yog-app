import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  bool _soundEffects = true;
  bool _mirrorMode = false;
  String _cameraQuality = 'HD 1080p';
  String _detectionSpeed = 'Balanced';
  String _language = 'English';

  bool get soundEffects => _soundEffects;
  bool get mirrorMode => _mirrorMode;
  String get cameraQuality => _cameraQuality;
  String get detectionSpeed => _detectionSpeed;
  String get language => _language;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _soundEffects = _prefs?.getBool('soundEffects') ?? true;
    _mirrorMode = _prefs?.getBool('mirrorMode') ?? false;
    _cameraQuality = _prefs?.getString('cameraQuality') ?? 'HD 1080p';
    _detectionSpeed = _prefs?.getString('detectionSpeed') ?? 'Balanced';
    _language = _prefs?.getString('language') ?? 'English';
    notifyListeners();
  }

  Future<void> setSoundEffects(bool value) async {
    _soundEffects = value;
    await _prefs?.setBool('soundEffects', value);
    notifyListeners();
  }

  Future<void> setMirrorMode(bool value) async {
    _mirrorMode = value;
    await _prefs?.setBool('mirrorMode', value);
    notifyListeners();
  }

  Future<void> setCameraQuality(String value) async {
    _cameraQuality = value;
    await _prefs?.setString('cameraQuality', value);
    notifyListeners();
  }

  Future<void> setDetectionSpeed(String value) async {
    _detectionSpeed = value;
    await _prefs?.setString('detectionSpeed', value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    await _prefs?.setString('language', value);
    notifyListeners();
  }
}
