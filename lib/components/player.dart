import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:simple_game/components/knife.dart';
import 'package:simple_game/components/wall.dart';
import 'package:simple_game/config/game_config.dart';
import 'package:simple_game/main.dart';
import 'package:simple_game/overlays/game_over.dart';

class Player extends SpriteAnimationComponent
    with HasGameRef<MyGame>, CollisionCallbacks {
  late SpriteAnimation idleAnimation;
  late SpriteAnimation walkAnimation;
  List<Sprite> walkFrames = [];
  List<Sprite> idleFrames = [];
  Vector2 velocity = Vector2.zero();
  double moveSpeed = 200;
  bool isCollidingLeft = false;
  bool isCollidingRight = false;

  @override
  Future<void> onLoad() async {
    await loadIdleAnimationFrames();
    await loadWalkAnimationFrames();
    idleAnimation = SpriteAnimation.spriteList(idleFrames, stepTime: 0.05);
    walkAnimation = SpriteAnimation.spriteList(walkFrames, stepTime: 0.05);
    animation = idleAnimation;
    position =
        Vector2(GameConfig.screenWidth / 2, GameConfig.screenHeight - 200);
    size = Vector2(80, 80);
    add(RectangleHitbox());
    await super.onLoad();
  }

  Future<void> loadWalkAnimationFrames() async {
    for (int i = 1; i <= 6; i++) {
      walkFrames.add(
        await gameRef.loadSprite(
          'player/w$i.png',
          srcSize: Vector2(560, 600),
        ),
      );
    }
  }

  Future<void> loadIdleAnimationFrames() async {
    for (int i = 1; i <= 6; i++) {
      idleFrames.add(
        await gameRef.loadSprite(
          'player/s$i.png',
          srcSize: Vector2(560, 600),
        ),
      );
    }
  }

  @override
  void update(double dt) {
    position += velocity * dt;
    position.x.clamp(80, GameConfig.screenWidth - 100);
    _handlePlayerAnimations();
    super.update(dt);
  }

  void _handlePlayerAnimations() {
    if (velocity.x > 0) {
      if (isFlippedHorizontally) {
        flipHorizontallyAroundCenter();
      }
      animation = walkAnimation;
    }
    if (velocity.x < 0) {
      if (!isFlippedHorizontally) {
        flipHorizontallyAroundCenter();
      }
      animation = walkAnimation;
    }

    if (velocity.x == 0) {
      animation = idleAnimation;
    }
  }

  void moveLeft() {
    if (!isCollidingLeft) {
      velocity.x = -moveSpeed;
    }
    if (isCollidingRight) {
      isCollidingRight = false;
    }
  }

  void moveRight() {
    if (!isCollidingRight) {
      velocity.x = moveSpeed;
    }
    if (isCollidingLeft) {
      isCollidingLeft = false;
    }
  }

  void stopMoving() {
    velocity = Vector2.zero();
  }

  void _handlCollision(WallDir? wallDir) {
    switch (wallDir) {
      case WallDir.LEFT:
        isCollidingLeft = true;
        velocity.x = 0;
        break;
      case WallDir.RIGHT:
        isCollidingRight = true;
        velocity.x = 0;
        break;
      default:
        isCollidingRight = false;
        isCollidingLeft = false;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Wall) {
      _handlCollision(other.wallDir);
    }

    if (other is Knife) {
      if (other.absoluteCenter.y < absolutePosition.y) {
        gameRef.pauseEngine();
        FlameAudio.bgm.stop();
        // show game over
        gameRef.overlays.add(GameOver.gameOverId);
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Wall) {
      _handlCollision(other.wallDir);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    _handlCollision(null);
    super.onCollisionEnd(other);
  }
}
