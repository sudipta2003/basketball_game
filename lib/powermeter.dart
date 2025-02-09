import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'basketball_game.dart';

class PowerMeter extends PositionComponent with HasGameRef<BasketballGame> {
  double _power = 0.0; // Power level (0 to 1)
  PowerMeter() : super(size: Vector2(50, 100));
  final double width = 200;
  final double height = 20;
  late Rect powerBar;
  late Rect lever;
  bool istap = false;
  double speed = 0.005; // Adjust speed of animation
  int direction = 1; // 1: increasing, -1: decreasing

  @override
  Future<void> onLoad() async {
    position = Vector2(gameRef.size.x - width - 20, gameRef.size.y - height - 20);
    powerBar = Rect.fromLTWH(0, 0, width, height);
    lever = Rect.fromLTWH(width * _power - 5, 0, 10, height);
  }

  double setPower() {
    istap = true;
    _power = _power.clamp(0.0, 1.0);
    lever = Rect.fromLTWH(width * _power - 5, 0, 10, height);
    return _power;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!istap) {
      _power += speed * direction;

      // Reverse direction when reaching the limits
      if (_power >= 1.0) {
        _power = 1.0;
        direction = -1; // Start decreasing
      } else if (_power <= 0.0) {
        _power = 0.0;
        direction = 1; // Start increasing
      }

      lever = Rect.fromLTWH(width * _power - 5, 0, 10, height);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paintBackground = Paint()..color = Colors.white;
    final Color interpolatedColor = Color.lerp(Colors.white, Colors.red, _power)!;
    final paintPower = Paint()..color = interpolatedColor;
    final paintLever = Paint()..color = Colors.black;

    canvas.drawRect(powerBar, paintBackground);
    canvas.drawRect(Rect.fromLTWH(0, 0, width * _power, height), paintPower);
    canvas.drawRect(lever, paintLever);
  }
}
