package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.motion.*;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Coward extends Enemy
{
    public static inline var ACTIVATION_DISTANCE = GameScene.GAME_WIDTH;
    public static inline var HORIZONTAL_SPEED = 100;
    public static inline var CLIMB_SPEED = 75;
    public static inline var LEDGE_HOP_POWER = 150;
    public static inline var JUMP_POWER = 250;
    public static inline var SHOOT_INTERVAL = 2;

    private var isClimbing:Bool;
    private var awakenOffset:Float;
    private var horizontalSpeedMod:NumTween;
    private var shootTimer:Alarm;

    public function new(startX:Float, startY:Float) {
        super(startX, startY);
        mask = new Hitbox(30, 40);
        graphic = new Image("graphics/coward.png");
        isClimbing = false;
        awakenOffset = GameScene.GAME_WIDTH / 4 * 3 * Random.random;
        horizontalSpeedMod = new NumTween(TweenType.PingPong);
        addTween(horizontalSpeedMod, true);
        horizontalSpeedMod.tween(-50, 50, 1, Ease.sineInOut);
        shootTimer = new Alarm(SHOOT_INTERVAL, TweenType.Looping);
        shootTimer.onComplete.bind(function() {
            shoot();
        });
        addTween(shootTimer);
    }

    private function shoot() {
        var heading = new Vector2(-1, 0);
        var ball = new Cannonball(x, y, heading);
        scene.add(ball);
    }

    override public function update() {
        if(!isAwake) {
            if(centerX < HXP.scene.camera.x + GameScene.GAME_WIDTH / 4 + awakenOffset) {
                shootTimer.start();
                isAwake = true;
            }
        }
        if(isAwake) {
            horizontalSpeedMod.active = !isClimbing && isOnGround();
            if(isClimbing) {
                velocity.x = 0;
                velocity.y = -CLIMB_SPEED;
            }
            else {
                //velocity.x = GameScene.SCROLL_SPEED + horizontalSpeedMod.value;
                velocity.x = GameScene.SCROLL_SPEED;
                if(isOnGround()) {
                    velocity.y = 0;
                    if(HXP.scene.collidePoint("walls", right, bottom) == null) {
                        velocity.y = -JUMP_POWER;
                    }
                }
                else {
                    velocity.y += Player.GRAVITY * HXP.elapsed;
                    velocity.y = Math.min(velocity.y, Player.MAX_FALL_SPEED);
                }
            }
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["walls"]);
            if(isClimbing && collide("walls", x + 1, y) == null) {
                velocity.y = -LEDGE_HOP_POWER;
                isClimbing = false;
            }
        }
        super.update();
    }

    override public function moveCollideX(_:Entity) {
        isClimbing = true;
        return true;
    }

    override public function moveCollideY(_:Entity) {
        if(velocity.y < 0) {
            velocity.y = 0;
        }
        return true;
    }
}

