import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'angle.dart';
import 'powermeter.dart';
import 'basketobj.dart';
import 'score.dart';
import 'package:just_audio/just_audio.dart';


class BasketballGame extends Forge2DGame with HasCollisionDetection, CollisionCallbacks, DragCallbacks, TapCallbacks {
  late SpriteComponent basketball;
  late SpriteComponent hoop;
  late ArrowComponent arrow;
  late SpriteComponent aright;
  late SpriteComponent aleft;
  late PowerMeter powermeter;
  late MyObject dot1;
  late MyObject dot2;
  late Score score;
  final player = AudioPlayer();
  final player2 = AudioPlayer();

  Vector2 velocity = Vector2(200, -300);
  double gravity = 100;
  bool isMoving = false;
  @override
  bool isLoaded = false;
  late Vector2 screenSize;
  double rotation = 0.0;
  double rotationSpeed = 0.09;
  double power = 0;

  double groundBounceFactor = 0.5;
  double wallBounceFactor = 0.2;

  late final minVelocity = 10; // Gravity acceleration

  bool right = false;
  bool left = false;

  late var circlehit;
  late var st = score.scoreText;
  

  @override
  Future<void> onLoad() async {
    screenSize = size;

    basketball = SpriteComponent()
      ..sprite = await loadSprite('basketball-ball.png')
      ..size = Vector2(100.0, 100.0)
      ..position = Vector2((screenSize.x) / 2, screenSize.y - 150)
      ..anchor = Anchor.center;

    circlehit = CircleHitbox(radius: basketball.size.x / 2 , isSolid: true);
    basketball.add(circlehit);
    
    hoop = SpriteComponent()
      ..sprite = await loadSprite('basketball-hoop.png')
      ..size = Vector2(230.0, 210.0)
      ..position = Vector2((screenSize.x - 200) / 2, 100);

    aright = SpriteComponent()
      ..sprite = await loadSprite('next.png')
      ..size = Vector2(50.0, 50.0)
      ..position = Vector2((screenSize.x + 400) / 2, 650);
    
    aleft = SpriteComponent()
      ..sprite = await loadSprite('back.png')
      ..size = Vector2(50.0, 50.0)
      ..position = Vector2((screenSize.x - 500) / 2, 650);
    
    arrow = ArrowComponent();
    powermeter = PowerMeter();
    dot1 = MyObject(position: Vector2((screenSize.x - hoop.size.x) / 2 + 50, screenSize.y - 510));
    dot2 = MyObject(position: Vector2((screenSize.x - hoop.size.x) / 2 + 150, screenSize.y - 510));
    score = Score(position: Vector2((screenSize.x - hoop.size.x) / 2 + 100, screenSize.y - 440));
    
    add(hoop);
    add(basketball);
    add(arrow);
    add(aright);
    add(aleft);
    add(powermeter);
    add(dot1);
    add(dot2);
    add(score);
    add(st);
    isLoaded = true;
    updatePositions();
    await player.setAsset('assets/audio/goal.wav');
    player.play();
  }

  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    screenSize = newSize;
    if (isLoaded) {
      updatePositions();
    }
  }

  void updatePositions() {
    if (!isLoaded) return;

    hoop.position = Vector2((screenSize.x - hoop.size.x) / 2, screenSize.y - 620);
    basketball.position = Vector2((screenSize.x - basketball.size.x) / 2, screenSize.y - 150);
    arrow.position =  Vector2((screenSize.x - basketball.size.x) / 2, screenSize.y - 100);
    aright.position = Vector2((screenSize.x + 400) / 2, screenSize.y - 70);
    aleft.position = Vector2((screenSize.x - 500) / 2, screenSize.y - 70);
    powermeter.position = Vector2((screenSize.x - 200) / 2, screenSize.y - 50);
    dot1.position = Vector2((screenSize.x - hoop.size.x) / 2 + 43, screenSize.y - 515);
    dot2.position = Vector2((screenSize.x - hoop.size.x) / 2 + 168, screenSize.y - 515);
    score.position =  Vector2((screenSize.x - hoop.size.x) / 2 + 100, screenSize.y - 440);
    score.scoreText.position = Vector2(60, 20);
  }

  @override
  Future<void> update(double dt) async {
    super.update(dt);

    if (isMoving) {
      velocity.y += gravity * dt; // Apply gravity to the vertical velocity
      basketball.position.x += velocity.x * dt;
      basketball.position.y += velocity.y * dt;

      // Apply gravity
      velocity.y += gravity * dt;

      // Update position
      basketball.position.x += velocity.x * dt;
      basketball.position.y += velocity.y * dt;

      // Update rotation
      rotation = (rotation - velocity.x * rotationSpeed * dt) % (2 * pi);
      basketball.angle = rotation;

      // Bounce off left/right walls
      if (basketball.position.x <= 50 || basketball.position.x  >= screenSize.x - 50) {
        player2.setAsset('assets/audio/ball.wav');
        player2.play();
        velocity.x = -velocity.x * wallBounceFactor;
        rotation = (rotation - velocity.x * rotationSpeed * dt) % (2 * pi);
        basketball.position.x = basketball.position.x.clamp(50, screenSize.x - 50);
      }

      
      // Bounce off the top wall
      if (basketball.position.y <= 50) {
        player2.setAsset('assets/audio/ball.wav');
        player2.play();
        velocity.y = -velocity.y * wallBounceFactor;
        rotation = (rotation - velocity.x * rotationSpeed * dt) % (2 * pi);
        basketball.position.y = 50;
        
      }

      // Bounce off the ground
      if (basketball.position.y + basketball.size.y >= screenSize.y) {
        player2.setAsset('assets/audio/ball.wav');
        player2.play();
        basketball.position.y = screenSize.y - basketball.size.y;
        velocity.y = -velocity.y * groundBounceFactor;
        rotationSpeed *= 0.5;
        

        if (velocity.y.abs() < minVelocity) {
          resetGame();
        }
    }

      gravity += 0.2;
    } 
    else {
      basketball.position.y = screenSize.y - basketball.size.y;
      velocity.y = -velocity.y * groundBounceFactor;
    }
  }

  @override
    void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    // Check if the drag event is within the bounds of the basketball
    if (basketball.containsPoint(event.localPosition)) {
      // Limit the basketball's position to the screen size on the x-axis
      double newX = event.localStartPosition.x;
      newX = newX.clamp(50.0, screenSize.x - 50); // Ensure it stays within the screen width

      basketball.position = Vector2(newX, basketball.position.y);
      arrow.position = Vector2(basketball.position.x, screenSize.y - 100); // Update basketball's position while dragging
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    powermeter.istap = false;
  }

  void shootBall(double angleInRadians) {
  isMoving = true;
  arrow.isVisible = false;
  double speed = powermeter.setPower()*500; // You can adjust this to control the ball speed
  velocity = Vector2(
    speed * cos(angleInRadians), // x component based on the angle
    -speed * sin(angleInRadians), // y component based on the angle
  );
}

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    if (basketball.containsPoint(event.localPosition) && !isMoving) {
      shootBall(angle()); // Rotate when tapped
    }

    if (aright.containsPoint(event.localPosition) && !isMoving) {
      arrow.rotateArrowright(); // Rotate when tapped
    }

    if (aleft.containsPoint(event.localPosition) && !isMoving) {
      arrow.rotateArrowleft(); // Rotate when tapped
    }
  }

  double angle() {
    double radians = arrow.angle;
    double adjustedAngle = 1.5707963268 - radians;
    return adjustedAngle;
}
 
  void resetGame() {
    isMoving = false;
    powermeter.istap = false;
    basketball.position = Vector2((screenSize.x - basketball.size.x) / 2, screenSize.y - 150);
    arrow.position =  Vector2((screenSize.x - basketball.size.x) / 2, screenSize.y - 100);
    velocity = Vector2(200, -300); // Reset velocity
    gravity = 100; // Reset gravity
    rotationSpeed = 0.09; // Reset rotation speed
    arrow.isVisible = true;
  }

  @override
  Color backgroundColor() => const Color.fromARGB(255, 157, 245, 245); // Set the background color
}
