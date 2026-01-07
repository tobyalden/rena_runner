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

class HammerBro extends Enemy
{
    public static inline var JUMP_POWER = 350;
    public static inline var JUMP_INTERVAL = 2;
    public static inline var SHOOT_INTERVAL = 1.5;
    public static inline var MAX_RUN_SPEED = 100;
    public static inline var RUN_ACCEL = 200;

    private var moveLeft:Bool;
    private var jumpTimer:Alarm;
    private var shootTimer:Alarm;

    public function new(startX:Float, startY:Float) {
        super(startX, startY);
        mask = new Hitbox(30, 40);
        graphic = new Image("graphics/hammerbro.png");
        moveLeft = true;
        jumpTimer = new Alarm(JUMP_INTERVAL, TweenType.Looping);
        jumpTimer.onComplete.bind(function() {
            jump();
        });
        addTween(jumpTimer);
        shootTimer = new Alarm(SHOOT_INTERVAL, TweenType.Looping);
        shootTimer.onComplete.bind(function() {
            shoot();
        });
        addTween(shootTimer);
    }

    override public function update() {
        if(!isAwake) {
            if(x < HXP.scene.camera.x + GameScene.GAME_WIDTH) {
                isAwake = true;
                jumpTimer.start();
                shootTimer.start();
            }
        }
        if(isAwake) {
            if(centerX < HXP.scene.camera.x + 150) {
                moveLeft = false;
            }
            if(centerX > HXP.scene.camera.x + GameScene.GAME_WIDTH - 100) {
                moveLeft = true;
            }
            var maxLeftSpeed = -MAX_RUN_SPEED + Player.AUTORUN_SPEED;
            var maxRightSpeed = MAX_RUN_SPEED + Player.AUTORUN_SPEED;
            if(moveLeft) {
                velocity.x -= RUN_ACCEL * HXP.elapsed;
            }
            else {
                velocity.x += RUN_ACCEL * HXP.elapsed;
            }
            velocity.x = MathUtil.clamp(
                velocity.x, maxLeftSpeed, maxRightSpeed
            );
            if(isOnGround()) {
                velocity.y = 0;
            }
            else {
                velocity.y += Player.GRAVITY * HXP.elapsed;
                velocity.y = Math.min(velocity.y, Player.MAX_FALL_SPEED);
            }
            moveBy(
                velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["walls"]
            );
        }
        super.update();
    }

    private function jump() {
        y -= 1;
        velocity.y = -JUMP_POWER;
    }

    private function shoot() {
        var heading = new Vector2(-0.25, -1);
        var ball = new Hammer(x, y, heading);
        scene.add(ball);
    }
}
