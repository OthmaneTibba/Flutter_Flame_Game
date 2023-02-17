import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:simple_game/config/game_config.dart';

enum WallDir {
  LEFT,
  RIGHT,
}

class Wall extends PositionComponent {
  WallDir wallDir;
  Vector2 pos;

  Wall({required this.wallDir, required this.pos}) : super(position: pos);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(10, GameConfig.screenHeight);

    add(RectangleHitbox());
    debugMode = true;
  }
}
