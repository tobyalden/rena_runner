package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Cannonball extends Enemy
{
    public static inline var SPEED = 150;

    public function new(x:Float, y:Float, heading:Vector2) {
        super(x, y);
        graphic = new Image("graphics/cannonball.png");
        velocity = heading;
        velocity.normalize(SPEED);
        mask = new Hitbox(30, 30);
    }

    override public function update() {
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
