package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Hammer extends Enemy
{
    public static inline var SPEED = 300;

    public function new(x:Float, y:Float, heading:Vector2) {
        super(x, y);
        graphic = new Image("graphics/hammer.png");
        velocity = heading;
        //velocity.normalize(SPEED + HXP.choose(-100, -50, 0));
        velocity.normalize(280);
        mask = new Hitbox(30, 30);
    }

    override public function update() {
        velocity.y += Player.GRAVITY / 2 * HXP.elapsed;
        velocity.y = Math.min(velocity.y, Player.MAX_FALL_SPEED);
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["walls"]);
        super.update();
    }

    override public function moveCollideX(_:Entity) {
        onCollision();
        return true;
    }

    override public function moveCollideY(_:Entity) {
        onCollision();
        return true;
    }

    private function onCollision() {
        scene.remove(this);
    }

    override public function die() {
        return;
    }
}

