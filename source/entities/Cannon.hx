package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Cannon extends Enemy
{
    public static inline var SHOOT_INTERVAL = 2;

    private var sprite:Image;
    private var shootTimer:Alarm;
    private var shootLeft:Bool;

    public function new(x:Float, y:Float, shootLeft:Bool) {
        super(x, y);
        type = "enemy";
        this.shootLeft = shootLeft;
        graphic = new Image("graphics/cannon.png");
        velocity = new Vector2();
        mask = new Hitbox(30, 30);
        shootTimer = new Alarm(SHOOT_INTERVAL, TweenType.Looping);
        shootTimer.onComplete.bind(function() {
            shoot();
        });
        addTween(shootTimer);
    }

    private function shoot() {
        var heading = new Vector2(shootLeft ? -1 : 1, 0);
        var ball = new Cannonball(x, y, heading);
        scene.add(ball);
    }

    override public function update() {
        if(!isAwake) {
            if(HXP.scene.camera.x + HXP.width > x) {
                //shoot();
                shootTimer.start();
                isAwake = true;
            }
        }
        super.update();
    }
}

