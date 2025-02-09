import 'dart:async';
import 'package:basketball_game/audioplayer.dart';
import 'package:basketball_game/basketball_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/painting.dart';

class MyObject extends PositionComponent with CollisionCallbacks, HasVisibility,HasGameRef<BasketballGame> {
  MyObject({required Vector2 position})
      : super(position: position, size: Vector2.all(16)); // Set default size

  late var basketball = gameRef.basketball;
  late var velocity = gameRef.velocity;
  late var wallBounceFactor = gameRef.wallBounceFactor;
  late Vector2 n;
  late double tengent;
  late double nature = 5;
  late final AudioManager audioManager;
  
  @override
  Future<void> onLoad() async {
    add(CircleHitbox(collisionType: CollisionType.passive)); // 🔹 Add collision hitbox
    audioManager = AudioManager();
    
  }


  @override
  void render(Canvas canvas) {
    final paint = BasicPalette.green.paint();
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 5, paint); // Fixed center
  }

  @override
  Future<void> onCollision(Set<Vector2> intersectionPoints, PositionComponent other) async {
  super.onCollision(intersectionPoints, other);
  if (other is SpriteComponent) {
    Vector2 n = ((basketball.position) - (position)).normalized();

    // Apply a slight energy loss after collision
    gameRef.velocity.y -= 50;
    
    // Reflect the velocity based on the collision normal
    gameRef.velocity = gameRef.velocity.reflected(n) * 0.85; // Slight energy loss
    gameRef.velocity.x *= 0.9;

    double penetrationDepth = (basketball.position - position).length;
    
    if (penetrationDepth <= 50) { // If the ball is too close to the object
      // Move the ball outside the object to avoid it going inside
      basketball.position += n * (50 - penetrationDepth);
      basketball.position.y -= nature;
      nature+=0.001;

    } 


  }
  super.onCollision(intersectionPoints, other);
}
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is SpriteComponent) {
      // Get the normal of the collision surface

      Future.delayed(Duration.zero, () async {
          await audioManager.loadSound('assets/audio/net.wav','netsound');
          audioManager.playSound('netsound');
      });
    }
  }

}