package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Medusa extends Enemy
{
    public static inline var HORIZONTAL_SPEED = 75;
    public static inline var SINE_WAVE_SPEED = 3;
    public static inline var SINE_WAVE_SIZE = 35 * 2;

    private var sprite:Image;
    private var age:Float;
    private var startY:Float;

    public function new(x:Float, y:Float, age:Float) {
        super(x, y);
        this.age = age;
        startY = y;
        sprite = new Image("graphics/medusa.png");
        graphic = sprite;
        mask = new Hitbox(30, 30);
    }

    override public function update() {
        age += HXP.elapsed;
        y = startY + Math.cos(age * SINE_WAVE_SPEED) * SINE_WAVE_SIZE;
        moveBy(-HORIZONTAL_SPEED * HXP.elapsed, 0);
        super.update();
    }
}



