import 'package:flutter/material.dart';
import 'basketball_game.dart';
import 'package:flame/game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GameWidget(game: BasketballGame()));
}
