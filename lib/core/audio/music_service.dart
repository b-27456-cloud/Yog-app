import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Singleton that owns the background music AudioPlayer.
/// Call [start] once after login; [stop] on logout or app exit.
class MusicService {
  MusicService._();
  static final MusicService instance = MusicService._();

  final AudioPlayer _player = AudioPlayer();
  bool _running = false;
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;
  bool get isRunning => _running;

  Future<void> start() async {
    if (_running) return;
    _running = true;

    try {
      await _player.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            // GAIN_TRANSIENT_MAY_DUCK lets the beep player duck this track
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
        ),
      );

      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(_isEnabled ? 0.35 : 0.0); // low enough for beep to cut through
      await _player.play(AssetSource('audio/background_music.mp3'));
    } catch (e) {
      debugPrint('[MusicService] Failed to start background music: $e');
      _running = false;
    }
  }

  Future<void> stop() async {
    _running = false;
    await _player.stop();
  }

  Future<void> pause() async => _player.pause();

  Future<void> resume() async {
    if (_running) await _player.resume();
  }

  /// Enables or disables background music by adjusting volume.
  /// When disabled, music is silenced (volume 0) but not stopped.
  Future<void> setMusicEnabled(bool enabled) async {
    _isEnabled = enabled;
    if (_running) {
      await _player.setVolume(enabled ? 0.35 : 0.0);
    }
    debugPrint('[MusicService] Music ${enabled ? 'enabled' : 'disabled'}');
  }

  void dispose() {
    _player.dispose();
  }
}
