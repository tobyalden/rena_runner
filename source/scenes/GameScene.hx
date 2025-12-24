package scenes;

import entities.*;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import openfl.Assets;

class GameScene extends Scene
{
    public static inline var SAVE_FILE_NAME = "runner";
    public static inline var GAME_WIDTH = 640;
    public static inline var GAME_HEIGHT = 360;
    public static inline var NUMBER_OF_CHUNK_TYPES = 2;

    public static inline var SCROLL_SPEED = Player.AUTORUN_SPEED;

    public static var totalTime:Float = 0;
    public static var deathCount:Float = 0;
    public static var sfx:Map<String, Sfx> = null;
    public static var bossCheckpoint:Vector2 = null;

    public var activeBosses(default, null):Array<Boss>;
    public var defeatedBossNames(default, null):Array<String>;

    public var curtain(default, null):Curtain;
    public var isRetrying(default, null):Bool;
    public var player(default, null):Player;
    private var level:Level;
    private var ui:UI;
    private var canRetry:Bool;
    private var chunks:Array<Level>;

    public function saveGame(checkpoint:Checkpoint) {
        GameScene.bossCheckpoint = null;
        Data.write("hasSaveData", true);
        Data.write("currentCheckpoint", new Vector2(checkpoint.x + 2, checkpoint.bottom - 24));
        Data.write("flipX", player.sprite.flipX);
        Data.write("totalTime", totalTime);
        Data.write("deathCount", deathCount);
        Data.write("defeatedBossNames", defeatedBossNames.join(','));
        Data.save(SAVE_FILE_NAME);
        camera.x = player.centerX - GAME_WIDTH / 2;
    }

    override public function begin() {
        Data.load(SAVE_FILE_NAME);

        activeBosses = [];
        defeatedBossNames = Data.read("defeatedBossNames", "").split(",");
        defeatedBossNames.remove("");

        curtain = add(new Curtain());
        curtain.fadeOut(1);

        activeBosses = [];

        ui = add(new UI());
        canRetry = false;
        isRetrying = false;

        var start = new Level("start");
        add(start);
        for(entity in start.entities) {
            if(Type.getClass(entity) == Player) {
                player = cast(entity, Player);
            }
            add(entity);
        }
        chunks = [start];

        if(sfx == null) {
            sfx = [
                "restart" => new Sfx("audio/restart.ogg"),
                "retryprompt" => new Sfx("audio/retryprompt.ogg"),
                "retry" => new Sfx("audio/retry.wav"),
                "backtosavepoint" => new Sfx("audio/backtosavepoint.ogg"),
                "ambience" => new Sfx("audio/ambience.wav")
            ];
        }
        if(!sfx["ambience"].playing) {
            sfx["ambience"].loop();
        }
    }

    public function defeatBoss(boss:Boss) {
        activeBosses.remove(boss);
        defeatedBossNames.push(boss.name);
    }

    public function isAnyBossActive() {
        return activeBosses.length > 0;
    }

    public function isBossDefeated(bossName:String) {
        return defeatedBossNames.indexOf(bossName) != -1;
    }

    public function triggerBoss(bossName:String, newBossCheckpoint:Vector2) {
        if(isBossDefeated(bossName)) {
            return;
        }
        var boss = cast(getInstance(bossName), Boss);
        boss.active = true;
        activeBosses.push(boss);
        GameScene.bossCheckpoint = newBossCheckpoint;
    }

    public function onDeath() {
        //Boss.sfx["klaxon"].stop();
        Data.load(SAVE_FILE_NAME);
        GameScene.deathCount++;
        HXP.alarm(1, function() {
            ui.showRetryPrompt();
            sfx["retryprompt"].play();
            canRetry = true;
        });
    }

    override public function update() {
        if(player.centerX + GAME_WIDTH > getTotalChunkWidth()) {
            addChunk();
        }
        if(canRetry && !isRetrying) {
            var retry = false;
            if(Input.pressed("jump")) {
                sfx["retry"].play(0.75);
                retry = true;
            }
            else if(GameScene.bossCheckpoint != null && Input.pressed("action")) {
                sfx["backtosavepoint"].play();
                GameScene.bossCheckpoint = null;
                retry = true;
            }
            if(retry) {
                isRetrying = true;
                curtain.fadeIn(0.2);
                var reset = new Alarm(0.2, function() {
                    HXP.scene = new GameScene();
                });
                addTween(reset, true);
            }
        }

        totalTime += HXP.elapsed;
        if(Input.pressed("restart")) {
            Data.clear(SAVE_FILE_NAME);
            HXP.scene = new GameScene();
            sfx["restart"].play();
        }
        if(Key.pressed(Key.P)) {
            trace(activeBosses);
        }
        super.update();
        //camera.x = player.centerX - GAME_WIDTH / 2;
        camera.x += SCROLL_SPEED * HXP.elapsed;
        //camera.setTo(
            //Math.floor(player.centerX / GAME_WIDTH) * GAME_WIDTH,
            //Math.floor(player.bottom / GAME_HEIGHT) * GAME_HEIGHT,
            //0, 0
        //);
    }

    private function getTotalChunkWidth() {
        var totalChunkWidth = 0;
        for(chunk in chunks) {
            totalChunkWidth += chunk.width;
        }
        return totalChunkWidth;
    }

    private function addChunk() {
        var chunk = new Level('${Random.randInt(NUMBER_OF_CHUNK_TYPES)}');
        chunk.x = getTotalChunkWidth();
        chunks.push(chunk);
        add(chunk);
        for(entity in chunk.entities) {
            entity.x += chunk.x;
            if(Type.getClass(entity) == MovingPlatform) {
                cast(entity, MovingPlatform).shiftPathPointsX(chunk.x);
            }
            add(entity);
        }
    }
}
