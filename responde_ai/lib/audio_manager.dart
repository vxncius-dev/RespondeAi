import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  static AudioPlayer? _backgroundPlayer;
  bool _isBackgroundMusicOn = true;
  bool _isInitialized = false;

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal() {
    _ensureInitialized();
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _backgroundPlayer ??= AudioPlayer();
      try {
        await _backgroundPlayer!
            .setSource(AssetSource('sounds/background.wav'));
        await _backgroundPlayer!.setReleaseMode(ReleaseMode.loop);
        _isInitialized = true;
        debugPrint('AudioManager inicializado');
        if (_isBackgroundMusicOn &&
            _backgroundPlayer!.state != PlayerState.playing) {
          await _backgroundPlayer!.play(AssetSource('sounds/background.wav'));
          debugPrint('Música iniciada na inicialização');
        }
      } catch (e) {
        debugPrint('Erro ao inicializar o AudioManager: $e');
      }
    }
  }

  Future<void> playBackgroundMusic() async {
    await _ensureInitialized();
    if (_isBackgroundMusicOn && _backgroundPlayer != null) {
      try {
        if (_backgroundPlayer!.state != PlayerState.playing) {
          if (_backgroundPlayer!.state == PlayerState.stopped ||
              _backgroundPlayer!.state == PlayerState.completed) {
            await _backgroundPlayer!.play(AssetSource('sounds/background.wav'));
          } else {
            await _backgroundPlayer!.resume();
          }
          debugPrint('Música de fundo iniciada ou retomada');
        } else {
          debugPrint('Música já está tocando, ignorando play');
        }
      } catch (e) {
        debugPrint('Erro ao tocar música de fundo: $e');
      }
    }
  }

  Future<void> pauseBackgroundMusic() async {
    if (_backgroundPlayer != null) {
      try {
        await _backgroundPlayer!.pause();
        debugPrint('Música de fundo pausada');
      } catch (e) {
        debugPrint('Erro ao pausar música de fundo: $e');
      }
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (_backgroundPlayer != null) {
      try {
        await _backgroundPlayer!.stop();
        debugPrint('Música de fundo parada');
      } catch (e) {
        debugPrint('Erro ao parar música de fundo: $e');
      }
    }
  }

  void setBackgroundMusicOn(bool value) {
    _isBackgroundMusicOn = value;
    if (value) {
      playBackgroundMusic();
    } else {
      pauseBackgroundMusic();
    }
  }

  bool get isBackgroundMusicOn => _isBackgroundMusicOn;

  void dispose() {
    if (_backgroundPlayer != null) {
      _backgroundPlayer!.dispose();
      _backgroundPlayer = null;
      _isInitialized = false;
      debugPrint('AudioManager descartado');
    }
  }
}
