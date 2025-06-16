import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _isPlaying = false;

  Future<void> playBGM() async {
    if (!_isPlaying) {
      await _bgmPlayer.play(AssetSource('audio/bgm.mp3'));
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      _isPlaying = true;
    }
  }

  Future<void> stopBGM() async {
    if (_isPlaying) {
      await _bgmPlayer.stop();
      _isPlaying = false;
    }
  }

  Future<void> dispose() async {
    await _bgmPlayer.dispose();
  }
}
