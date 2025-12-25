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

class Guy extends MiniEntity
{
    public static inline var ACTIVATION_DISTANCE = GameScene.GAME_WIDTH;
    public static inline var HORIZONTAL_SPEED = 100;
    public static inline var CLIMB_SPEED = 75;
    public static inline var LEDGE_HOP_POWER = 150;

    private var isAwake:Bool;
    private var isClimbing:Bool;
    private var velocity:Vector2;

    public function new(startX:Float, startY:Float) {
        super(startX, startY);
        type = "enemy";
        mask = new Hitbox(30, 40);
        graphic = new Image("graphics/guy.png");
        isAwake = false;
        isClimbing = false;
        velocity = new Vector2();
    }

    override public function update() {
        if(!isAwake) {
            if(x < HXP.scene.camera.x + GameScene.GAME_WIDTH) {
                isAwake = true;
            }
        }
        if(isAwake) {
            if(isClimbing) {
                velocity.x = 0;
                velocity.y = -CLIMB_SPEED;
            }
            else {
                velocity.x = -HORIZONTAL_SPEED;
                if(isOnGround()) {
                    velocity.y = 0;
                }
                else {
                    velocity.y += Player.GRAVITY * HXP.elapsed;
                    velocity.y = Math.min(velocity.y, Player.MAX_FALL_SPEED);
                }
            }
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["walls"]);
            if(isClimbing && collide("walls", x - 1, y) == null) {
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

    public function die() {
        explode(4, false);
        HXP.scene.remove(this);
    }
}

