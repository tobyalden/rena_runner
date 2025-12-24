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

class Bat extends MiniEntity
{
    public static inline var ACTIVATION_DISTANCE = 250;
    public static inline var HORIZONTAL_SPEED = 100;
    public static inline var MAX_VERTICAL_SPEED = 175;
    public static inline var RISE_ACCEL = 200;

    private var isAwake:Bool;
    private var velocity:Vector2;

    public function new(startX:Float, startY:Float) {
        super(startX, startY);
        type = "enemy";
        mask = new Hitbox(20, 20);
        graphic = new Image("graphics/bat.png");
        isAwake = false;
        velocity = new Vector2();
    }

    override public function update() {
        if(!isAwake) {
            if(
                centerX - getPlayer().centerX < ACTIVATION_DISTANCE
                && centerX < HXP.scene.camera.x + GameScene.GAME_WIDTH - 50
            ) {
                isAwake = true;
                velocity.x = -HORIZONTAL_SPEED;
                velocity.y = MAX_VERTICAL_SPEED;
            }
        }
        if(isAwake) {
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);
            velocity.y = Math.max(
                velocity.y - RISE_ACCEL * HXP.elapsed,
                -MAX_VERTICAL_SPEED
            );
        }
        super.update();
    }
}
