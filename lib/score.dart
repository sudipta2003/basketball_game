import 'package:basketball_game/basketball_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'audioplayer.dart';

class Score extends PositionComponent 
    with CollisionCallbacks, HasVisibility, HasGameRef<BasketballGame> {
  
  bool topHit = false; // Track if top was hit first
  double score = 0;
  
  Score({required Vector2 position})
      : super(position: position, size: Vector2.all(25)); // Default size

  late TextComponent scoreText;
  late final AudioManager audioPlayer;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(collisionType: CollisionType.passive)); // 🔹 Add collision hitbox

    scoreText = TextComponent(
      text: 'SCORE: $score',
      anchor: Anchor.center,
      size: Vector2(gameRef.size.x * 0.1, gameRef.size.y * 0.05),
      position: Vector2(0, 0), // Adjust position if needed
    );
    scoreText.textRenderer = TextPaint(
      style: TextStyle(
        color: const Color.fromARGB(255, 2, 0, 0),
        fontSize: 24.0,
      ),
    );
    
    add(scoreText);
    audioPlayer = AudioManager();
  }

  @override
Future<void> onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) async {
  super.onCollisionStart(intersectionPoints, other);

  if (other is SpriteComponent) {
    // 🔹 Find the earliest contact point
    Vector2 firstContact = intersectionPoints.reduce((a, b) => a.y < b.y ? a : b);

    // 🔹 Define edges of the rectangle
    double topEdge = position.y;
    double bottomEdge = position.y + size.y;

    // 🔹 Small margin to account for floating point inaccuracies
    double margin = 1.0;

    if ((firstContact.y - topEdge).abs() < margin) {
      topHit = true; // Activate top hit tracking
      score += 1;
      
      // Call scoreEffect first
      scoreEffect();

      // Then play the sound after the effect complete
      await audioPlayer.loadSound('assets/audio/goal2.wav','netsound');
      audioPlayer.playSound('netsound');
    } else if ((firstContact.y - bottomEdge).abs() < margin && topHit) {
      topHit = false; // Reset for next score
    }
  }
}

  Future<void> scoreEffect() async {
  // Update score text
  scoreText.text = 'SCORE: $score';

  // 🔹 Add an animation effect (scaling)
  await scoreText.add(
    ScaleEffect.to(
      Vector2.all(1.5), // Scale up
      EffectController(duration: 0.2, reverseDuration: 0.2),
      // Smooth animation
    ),
  );

  // Play audio asynchronously without blocking the UI thread
}


}
