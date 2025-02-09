import 'package:just_audio/just_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  final Map<String, AudioPlayer> _players = {};  // Stores multiple AudioPlayers

  AudioManager._internal();

  // Load multiple audio assets
  Future<void> loadSound(String assetPath, String soundName) async {
    final player = AudioPlayer();
    await player.setAsset(assetPath);
    _players[soundName] = player;
  }

  // Play a specific sound by name
  void playSound(String soundName) {
    final player = _players[soundName];
    player?.play();
  }

  // Dispose of all audio players
  void dispose() {
    for (var player in _players.values) {
      player.dispose();
    }
  }
}
