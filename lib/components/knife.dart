import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:simple_game/config/game_config.dart';
import 'package:simple_game/main.dart';

class Knife extends SpriteComponent with HasGameRef<MyGame> {
  final Vector2 pos;
  final double _speed = 250;
  Knife({required this.pos}) : super(position: pos);
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite(
      'obstacle/Knife.png',
      srcSize: Vector2(74, 238),
    );
    size = Vector2(30, 80);

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    position.y += _speed * dt;
    if (position.y > GameConfig.screenHeight + height) {
      removeFromParent();
    }
    super.update(dt);
  }
}
