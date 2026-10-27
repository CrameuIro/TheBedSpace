import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models.dart';

/// ---------------------------------------------------------------------------
/// Thin wrapper around just_audio used by the bedroom TV. Handles built-in
/// asset loops, user-uploaded files and a simple sleep timer.
/// ---------------------------------------------------------------------------
class AudioService extends ChangeNotifier {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();

  SoundTrack? current;
  bool isPlaying = false;
  String? error;
  int? timerMinutes;
  Timer? _timer;

  /// Total length of the loaded track (null while unknown).
  Duration? duration;

  AudioService() {
    _player.playerStateStream.listen((s) {
      isPlaying = s.playing && s.processingState != ProcessingState.completed;
      notifyListeners();
    });
    _player.durationStream.listen((d) {
      duration = d;
      notifyListeners();
    });
  }

  Future<void> play(SoundTrack track) async {
    error = null;
    try {
      if (current?.id != track.id) {
        current = track;
        // Publish the selection before loading the asset.  Loading can take a
        // moment on a first play, and the screen should show "Now playing"
        // immediately instead of requiring a second tap.
        notifyListeners();
        await _player.setLoopMode(LoopMode.one);
        if (track.isUserUploaded) {
          await _player.setFilePath(track.filePath!);
        } else {
          await _player.setAsset(track.assetPath!);
        }
      }
      await _player.play();
      notifyListeners();
    } catch (e) {
      error = e.toString();
      current = track;
      isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    current = null;
    isPlaying = false;
    _cancelTimer();
    notifyListeners();
  }

  /// Sets a sleep timer in minutes; playback stops when it elapses.
  void setTimer(int? minutes) {
    _cancelTimer();
    timerMinutes = minutes;
    if (minutes != null && minutes > 0) {
      _timer = Timer(Duration(minutes: minutes), () async {
        timerMinutes = null;
        await stop();
      });
    }
    notifyListeners();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
    timerMinutes = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    _player.dispose();
    super.dispose();
  }
}
