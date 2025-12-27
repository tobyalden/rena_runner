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

    private var jumpTimer:Alarm;
    private var shootTimer:Alarm;

    public function new(startX:Float, startY:Float) {
        super(startX, startY);
        mask = new Hitbox(30, 40);
        graphic = new Image("graphics/hammerbro.png");
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
            if(isOnGround()) {
                if(centerX < HXP.scene.camera.x + GameScene.GAME_WIDTH / 2.5) {
                    velocity.x = 100 + Player.AUTORUN_SPEED;
                }
                if(centerX > HXP.scene.camera.x + GameScene.GAME_WIDTH - 60) {
                    velocity.x = -100 + Player.AUTORUN_SPEED;
                }
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
