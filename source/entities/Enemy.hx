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

    public function die() {
        explode(4, false);
        HXP.scene.remove(this);
    }
}
