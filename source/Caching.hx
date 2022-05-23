#if sys
import flixel.graphics.FlxGraphic;
#if cpp
import Sys;
import sys.FileSystem;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxSprite;

using StringTools;

class Caching extends MusicBeatState
{
	var text:FlxText;

	var logo:FlxSprite;

	override function create() 
	{

		FlxG.save.bind('funkin', 'ninjamuffin99');

		PlayerSettings.init();

		Data.initSave();

		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0,0);

		text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 300,0,"Loading...");
		text.size = 34;
		text.alignment = FlxTextAlign.CENTER;
		
		text.x -= 170;

		logo = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.image('MidFightLogo'));
		logo.x -= logo.width / 2;
		logo.y -= logo.height / 2 + 100;
		logo.setGraphicSize(Std.int(logo.width * 0.6));

		text.y -= logo.height / 2 - 125;
		
		if(FlxG.save.data.antialiasing != null)
			logo.antialiasing = FlxG.save.data.antialiasing;
		else
			logo.antialiasing = true;

		add(text);
		add(logo);

		#if cpp
		sys.thread.Thread.create(() -> {
			preload();
		});
		#else
		LoadingState.loadAndSwitchState(new TitleState());
		#end
	}

	public function preload()
	{
		FlxGraphic.defaultPersist = true;

		for(file in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
		{
			if(Std.isOfType(file, FlxGraphic)){
			 trace('caching: ${file}');
			 FlxG.bitmap.add(Paths.image(file, 'shared'));
			}
		}

		LoadingState.loadAndSwitchState(new TitleState());
	}
}
#end

/*#if sys
package;

import lime.app.Application;
#if windows
import Discord.DiscordClient;
#end
import openfl.display.BitmapData;
import openfl.utils.Assets;
import flixel.ui.FlxBar;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;

using StringTools;

class Caching extends MusicBeatState
{
	var toBeDone = 0;
	var done = 0;

	var loaded = false;

	var text:FlxText;
	var logo:FlxSprite;

	public static var bitmapData:Map<String,FlxGraphic>;

	var images = [];
	var music = [];
	var charts = [];


	override function create()
	{

		FlxG.save.bind('funkin', 'ninjamuffin99');

		PlayerSettings.init();

		KadeEngineData.initSave();

		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0,0);

		bitmapData = new Map<String,FlxGraphic>();

		text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 300,0,"Loading...");
		text.size = 34;
		text.alignment = FlxTextAlign.CENTER;
		text.alpha = 0;

		logo = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.image('MidFightLogo'));
		logo.x -= logo.width / 2;
		logo.y -= logo.height / 2 + 100;
		text.y -= logo.height / 2 - 125;
		text.x -= 170;
		logo.setGraphicSize(Std.int(logo.width * 0.6));
		if(FlxG.save.data.antialiasing != null)
			logo.antialiasing = FlxG.save.data.antialiasing;
		else
			logo.antialiasing = true;
		
		logo.alpha = 0;

		FlxGraphic.defaultPersist = FlxG.save.data.cacheImages;

		#if cpp
		if (FlxG.save.data.cacheImages)
		{
			trace("caching images...");

			var w = 0;
			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
			{
				if (!i.endsWith(".png"))
					continue;
				FlxG.bitmap.add(Paths.image(i, 'shared'));
				w++;
			}
		}

		trace("caching music...");

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
		{
			//FlxG.bitmap.add(Paths.image(i, 'songs'));
		}
		#end

		toBeDone = Lambda.count(images) + Lambda.count(music);

		//var bar = new FlxBar(10,FlxG.height - 50,FlxBarFillDirection.LEFT_TO_RIGHT,FlxG.width,40,null,"done",0,toBeDone);
		//bar.color = FlxColor.PURPLE;

		//add(bar);

		add(logo);
		add(text);

		trace('starting caching..');
		
		#if cpp
		// update thread

		sys.thread.Thread.create(() -> {
			while(!loaded)
			{
				if (toBeDone != 0 && done != toBeDone)
					{
						var alpha = HelperFunctions.truncateFloat(done / toBeDone * 100,2) / 100;
						logo.alpha = alpha;
						text.alpha = alpha;
						text.text = "Loading... (" + done + "/" + toBeDone + ")";
					}
			}
		
		});

		// cache thread

		sys.thread.Thread.create(() -> {
			cache();
		});
		#end

		super.create();
	}

	var calledDone = false;

	override function update(elapsed) 
	{
		super.update(elapsed);
	}


	function cache()
	{
		trace("LOADING: " + toBeDone + " OBJECTS.");

		for (image in images)
		{
			var replaced = image.replace(".png","");
			var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + image);
			trace('id ' + replaced + ' file - assets/shared/images/characters/' + image + ' ${data.width}');
			var graph = FlxGraphic.fromBitmapData(data);
			graph.persist = true;
			graph.destroyOnNoUse = false;
			bitmapData.set(replaced,graph);
			done++;
		}

		for (file in music)
		{
			FlxG.sound.cache(Paths.inst(file));
			FlxG.sound.cache(Paths.voices(file));
			trace("cached " + file);
			done++;
		}


		trace("Finished caching...");

		loaded = true;

		trace(Assets.cache.hasBitmapData('GF_assets'));

		FlxG.switchState(new TitleState());
	}

}
#end*/