package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Player extends MiniEntity
{
    public static inline var ITEM_GUN = 0;
    public static inline var ITEM_STORED_JUMP = 1;
    public static inline var ITEM_HIGH_JUMP = 2;

    public static inline var RUN_ACCEL = 9999;
    public static inline var RUN_ACCEL_TURN_MULTIPLIER = 2;
    public static inline var RUN_DECEL = RUN_ACCEL * RUN_ACCEL_TURN_MULTIPLIER;
    public static inline var AIR_ACCEL = 9999;
    public static inline var AIR_DECEL = 9999;
    public static inline var MAX_RUN_SPEED = 210;
    public static inline var MAX_AIR_SPEED = 200;
    public static inline var GRAVITY = 800;
    public static inline var JUMP_POWER = 310;
    public static inline var HIGH_JUMP_POWER = 380;
    public static inline var LAUNCHER_JUMP_POWER = 500;
    public static inline var JUMP_CANCEL_POWER = 20;
    public static inline var MAX_FALL_SPEED = 370;

    public static inline var AUTORUN_SPEED = MAX_RUN_SPEED / 2;

    public static inline var SHOT_SPEED = 500;
    public static inline var SHOT_COOLDOWN = 0.2;
    public static inline var MAX_ONSCREEN_BULLETS = 2;

    public static inline var COYOTE_TIME = 1 / 60 * 5;

    public static var sfx:Map<String, Sfx> = null;

    public var sprite(default, null):Spritemap;
    public var isDead(default, null):Bool;
    private var velocity:Vector2;
    private var canMove:Bool;
    private var canJump:Bool;
    private var shotCooldown:Alarm;
    private var isCrouching:Bool;
    private var airTime:Float;
    private var inventory:Array<Int>;
    private var jumpedOffLauncher:Bool;
    private var crouchHitbox:Hitbox;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "player";
        type = "player";
        layer = -10;
        sprite = new Spritemap("graphics/player.png", 16, 24);
        sprite.add("idle", [0]);
        sprite.add("run", [1, 2, 3, 2], 8);
        sprite.add("jump", [4]);
        sprite.add("fall", [5]);
        sprite.add("crouch", [6]);
        sprite.add("idle_gun", [7]);
        sprite.add("run_gun", [8, 9, 10, 9], 8);
        sprite.add("jump_gun", [11]);
        sprite.add("fall_gun", [12]);
        sprite.add("crouch_gun", [13]);
        sprite.add("ride_gun", [14]);
        sprite.add("ride", [15]);
        sprite.play("idle");
        var hitbox = new Hitbox(12, 24);
        crouchHitbox = new Hitbox(12, 16, 0, 8);
        mask = new Masklist([hitbox, crouchHitbox]);
        sprite.x = -2;
        graphic = sprite;
        velocity = new Vector2();
        isDead = false;
        canMove = false;
        canJump = false;
        var allowMove = new Alarm(0.2, function() {
            canMove = true;
        });
        addTween(allowMove, true);
        shotCooldown = new Alarm(SHOT_COOLDOWN);
        addTween(shotCooldown);
        isCrouching = false;
        airTime = 0;
        inventory = [ITEM_GUN, ITEM_HIGH_JUMP];
        //inventory = [ITEM_GUN];
        //inventory = [];
        if(sfx == null) {
            sfx = [
                "jump" => new Sfx("audio/jump.ogg"),
                "superjump" => new Sfx("audio/superjump.wav"),
                "youwin" => new Sfx("audio/youwin.wav"),
                "run" => new Sfx("audio/run.wav"),
                "die" => new Sfx("audio/death.ogg"),
                "save" => new Sfx("audio/save.ogg"),
                "shoot" => new Sfx("audio/shoot.ogg")
            ];
        }
        jumpedOffLauncher = false;
    }

    public function hasItem(item:Int) {
        return inventory.indexOf(item) != -1;
    }

    override public function update() {
        if(!isDead) {
            if(canMove) {
                shooting();
                movement();
            }
            animation();
            if(canMove) {
                sound();
            }
            collisions();
        }
        if(x < HXP.scene.camera.x) {
            moveTo(HXP.scene.camera.x, y);
        }
        if(x + width > HXP.scene.camera.x + GameScene.GAME_WIDTH) {
            moveTo(HXP.scene.camera.x + GameScene.GAME_WIDTH - width, y);
        }
        super.update();
    }

    private function shooting() {
        //if(HXP.scene.typeCount("playerbullet") >= MAX_ONSCREEN_BULLETS) {
            //return;
        //}
        //if(Input.pressed("action") && !shotCooldown.active) {
        if(Input.pressed("action")) {
            var bullet = new Bullet(
                centerX, centerY + (isCrouching ? 5 : 0),
                {
                    width: 10,
                    height: 5,
                    angle: (sprite.flipX ? -1 : 1) * Math.PI / 2,
                    speed: SHOT_SPEED,
                    shotByPlayer: true,
                    collidesWithWalls: true
                }
            );
            scene.add(bullet);
            //sfx['playershot${HXP.choose(1, 2, 3)}'].play(HXP.choose(0.5, 0.7, 0.6));
            shotCooldown.start();
            sfx["shoot"].play();
        }
    }

    private function collisions() {
        var checkpoint = collide("checkpoint", x, y);
        if(Input.pressed("down") && checkpoint != null) {
            cast(checkpoint, Checkpoint).flash();
            sfx["save"].play();
        }
        var hazard = collide("hazard", x, y);
        if(hazard != null) {
            if(isCrouching) {
                if(crouchHitbox.collide(hazard.mask)) {
                    die();
                }
            }
            else {
                die();
            }
        }
        var boss = collide("boss", x, y);
        if(boss != null) {
            if(isCrouching) {
                if(crouchHitbox.collide(boss.mask)) {
                    die();
                }
            }
            else {
                die();
            }
        }
        if(collide("walls", x, y) != null) {
            die();
        }
        var enemy = collide("enemy", x, y);
        if(enemy != null) {
            if(bottom < enemy.centerY) {
                if(isOnGround()) {
                    moveBy(0, -1, ["walls"]);
                }
                if(Input.check("jump")) {
                    velocity.y = -HIGH_JUMP_POWER;
                }
                else {
                    velocity.y = -HIGH_JUMP_POWER / 1.5;
                }
                cast(enemy, Enemy).die();
            }
            else {
                die();
            }
        }
    }

    private function stopSounds() {
        sfx["run"].stop();
        sfx["shoot"].stop();
    }

    public function die() {
        visible = false;
        collidable = false;
        isDead = true;
        explode();
        stopSounds();
        sfx["die"].play(0.8);
        cast(HXP.scene, GameScene).onDeath();
    }

    private function movement() {
        var accel = isOnGround() ? RUN_ACCEL : AIR_ACCEL;
        if(
            isOnGround() && (
                Input.check("left") && velocity.x > 0
                || Input.check("right") && velocity.x < 0
            )
        ) {
            accel *= RUN_ACCEL_TURN_MULTIPLIER;
        }
        var decel = isOnGround() ? RUN_DECEL : AIR_DECEL;

        if(isOnGround() && Input.check("down") && collide("checkpoint", x, y) == null) {
            isCrouching = true;
        }
        else {
            isCrouching = false;
        }

        if(isCrouching) {
            velocity.x = 0;
        }
        else if(Input.check("left") && !isOnLeftWall()) {
            velocity.x -= accel * HXP.elapsed;
        }
        else if(Input.check("right") && !isOnRightWall()) {
            velocity.x += accel * HXP.elapsed;
        }
        else {
            velocity.x = MathUtil.approach(
                velocity.x, 0, decel * HXP.elapsed
            );
        }
        var maxSpeed = isOnGround() ? MAX_RUN_SPEED : MAX_AIR_SPEED;
        velocity.x += AUTORUN_SPEED;
        velocity.x = MathUtil.clamp(velocity.x, -maxSpeed, maxSpeed);

        if(isOnGround()) {
            canJump = true;
            velocity.y = 0;
            airTime = 0;
            jumpedOffLauncher = false;
        }
        else {
            airTime += HXP.elapsed;
            if(!hasItem(ITEM_STORED_JUMP) && airTime >= COYOTE_TIME) {
                canJump = false;
            }
            if(Input.released("jump") && !jumpedOffLauncher) {
                var jumpCancelPower = JUMP_CANCEL_POWER;
                velocity.y = Math.max(velocity.y, -jumpCancelPower);
            }
            velocity.y += GRAVITY * HXP.elapsed;
            velocity.y = Math.min(velocity.y, MAX_FALL_SPEED);
        }

        if(Input.pressed("jump") && canJump) {
            var jumpPower = hasItem(ITEM_HIGH_JUMP) ? HIGH_JUMP_POWER : JUMP_POWER;
            if(collide("launcher", x, y + 1) != null) {
                jumpPower = LAUNCHER_JUMP_POWER;
                jumpedOffLauncher = true;
                sfx["superjump"].play();
            }
            else {
                sfx["jump"].play();
            }
            velocity.y = -jumpPower;
            canJump = false;
            makeDustAtFeet();
        }

        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
    }

    private function makeDustAtFeet() {
        var dust = new Dust(centerX - 5, bottom - 4);
        scene.add(dust);
    }

    override public function moveCollideX(_:Entity) {
        velocity.x = 0;
        return true;
    }

    override public function moveCollideY(_:Entity) {
        if(velocity.y < 0) {
            velocity.y = -velocity.y / 2.5;
        }
        else {
            velocity.y = 0;
        }
        return true;
    }

    private function animation() {
        //if(!Input.check("action") || isCrouching || !hasItem(ITEM_GUN)) {
            //if(Input.check("left")) {
                //sprite.flipX = true;
            //}
            //else if(Input.check("right")) {
                //sprite.flipX = false;
            //}
        //}

        var animationSuffix = hasItem(ITEM_GUN) ? "_gun" : "";

        if(!canMove) {
            if(isOnGround()) {
                sprite.play("idle" + animationSuffix);
            }
            else {
                sprite.play("jump" + animationSuffix);
            }
        }
        else if(!isOnGround()) {
            if(velocity.y < -JUMP_CANCEL_POWER) {
                sprite.play("jump" + animationSuffix);
            }
            else {
                sprite.play("fall" + animationSuffix);
            }
        }
        else if(velocity.x != 0) {
            sprite.play("run" + animationSuffix);
        }
        else {
            if(isCrouching) {
                sprite.play("crouch" + animationSuffix);
            }
            else {
                sprite.play("idle" + animationSuffix);
            }
        }
    }

    private function sound() {
        if(isOnGround() && Math.abs(velocity.x) > 0) {
            if(!sfx["run"].playing) {
                sfx["run"].loop();
            }
        }
        else {
            sfx["run"].stop();
        }
    }
}
