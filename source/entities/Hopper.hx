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

class Hopper extends Enemy
{
    public static inline var ACTIVATION_DISTANCE = GameScene.GAME_WIDTH;
    public static inline var BIG_JUMP_HORIZONTAL_SPEED = 100;
    public static inline var SMALL_JUMP_HORIZONTAL_SPEED = 80;
    public static inline var SMALL_JUMP_POWER = 150;
    public static inline var BIG_JUMP_POWER = 350;
    public static inline var JUMP_INTERVAL = 1;

    private var jumpTimer:Alarm;
    private var willBigJump:Bool;

    public function new(startX:Float, startY:Float) {
        super(startX, startY);
        mask = new Hitbox(30, 30);
        graphic = new Image("graphics/hopper.png");
        jumpTimer = new Alarm(JUMP_INTERVAL);
        jumpTimer.onComplete.bind(function() {
            jump();
        });
        addTween(jumpTimer);
        willBigJump = false;
    }

    override public function update() {
        if(!isAwake) {
            if(x < HXP.scene.camera.x + GameScene.GAME_WIDTH) {
                isAwake = true;
                jumpTimer.start();
            }
        }
        if(isAwake) {
            if(isOnGround()) {
                velocity.x = 0;
                velocity.y = 0;
                if(!jumpTimer.active) {
                    if(willBigJump) {
                        jump();
                    }
                    else {
                        jumpTimer.start();
                    }
                }
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
        velocity.x = (
            willBigJump
            ? -BIG_JUMP_HORIZONTAL_SPEED
            : -SMALL_JUMP_HORIZONTAL_SPEED
        );
        velocity.y = willBigJump ? -BIG_JUMP_POWER : -SMALL_JUMP_POWER;
        willBigJump = !willBigJump;
    }

    override public function moveCollideX(_:Entity) {
        velocity.x = -velocity.x;
        return true;
    }

    override public function moveCollideY(_:Entity) {
        if(velocity.y < 0) {
            velocity.y = 0;
        }
        return true;
    }
}

