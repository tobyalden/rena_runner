package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import scenes.*;

class Enemy extends MiniEntity
{
    private var velocity:Vector2;
    private var isAwake:Bool;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "enemy";
        isAwake = false;
        velocity = new Vector2();
    }

    override public function update() {
        if(right < HXP.scene.camera.x) {
            HXP.scene.remove(this);
        }
        var bullet = collide("playerbullet", x, y);
        if(bullet != null) {
            die();
            HXP.scene.remove(bullet);
        }
        super.update();
    }

    public function die() {
        explode(4, false);
        HXP.scene.remove(this);
    }
}
