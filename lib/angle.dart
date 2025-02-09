import 'package:flame/components.dart';
import 'basketball_game.dart';

class ArrowComponent extends SpriteComponent with HasGameRef<BasketballGame>, HasVisibility {
  double angleInDegrees = 90;  // Start at 90 degrees (upright position)
  ArrowComponent() : super(size: Vector2(50, 100));
  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('up-arrow.png');
    anchor = Anchor.bottomCenter;
    position = Vector2(gameRef.size.x , gameRef.size.y );
  }

  void rotateArrowright() {
    angle += 0.1;
    angleInDegrees = angle * (180 / 3.1415926535); // Convert radians to degrees

    // Reset angle if it exceeds 180 degrees (i.e., beyond horizontal left)
    if (angleInDegrees >= 90) {
      angleInDegrees = 90;
      angle = 1.5707963268;  // Set angle to pi (180 degrees)
    }
  }

  void rotateArrowleft() {
    angle -= 0.1;
    angleInDegrees = angle * (180 / 3.1415926535); // Convert radians to degrees

    // Reset angle if it goes below 0 degrees (i.e., beyond horizontal right)
    if (angleInDegrees <= -90) {
      angleInDegrees = -90;
      angle = -1.5707963268;   // Set angle to 0 (right horizontal)
    }
  }
}
