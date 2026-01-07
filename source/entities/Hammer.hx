package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Hammer extends MiniEntity
{
    // TODO: Use enemy class, but add "jumpable" and "shootable" params
    public static inline var SPEED = 300;

    private var velocity:Vector2;

    public function new(x:Float, y:Float, heading:Vector2) {
        super(x, y);
        type = "hazard";
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
        var bullet = collide("playerbullet", x, y);
        if(bullet != null) {
            die();
            HXP.scene.remove(bullet);
        }
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

    public function die() {
        explode(4, false);
        HXP.scene.remove(this);
    }
}

