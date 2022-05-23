package;

import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;
#if windows
import llua.Lua;
#end
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	public static var goToOptions:Bool = false;
	public static var goBack:Bool = false;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Options', 'Exit to menu'];
	var difficulties:Array<String> = ['Easy', 'Normal', 'Hard', 'Alt'];
	var curSelected:Int = 0;

	public static var playingPause:Bool = false;

	var pauseMusic:FlxSound;
	var perSongOffset:FlxText;
	
	var offsetChanged:Bool = false;
	var difficultyMenu:Bool = false;

	var confirmButtonEnabled = true;

	public function new(x:Float, y:Float)
	{
		super();

		if(FlxG.gamepads.lastActive != null) {
			confirmButtonEnabled = false;

			new FlxTimer().start(0.5, (timer:FlxTimer) -> {
				confirmButtonEnabled = true;
			});
		}

		if (PlayState.instance.useVideo)
		{
			menuItems.remove("Resume");
			if (GlobalVideo.get().playing)
				GlobalVideo.get().pause();
		}

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toUpperCase();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		perSongOffset = new FlxText(5, FlxG.height - 18, 0, "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.', 12);
		perSongOffset.scrollFactor.set();
		perSongOffset.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
		#if cpp
			add(perSongOffset);
		#end

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		if (PlayState.instance.useVideo)
			menuItems.remove('Resume');

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var upPcontroller:Bool = false;
		var downPcontroller:Bool = false;
		var leftPcontroller:Bool = false;
		var rightPcontroller:Bool = false;
		var oldOffset:Float = 0;

		if (gamepad != null && KeyBinds.gamepad)
		{
			upPcontroller = gamepad.justPressed.DPAD_UP;
			downPcontroller = gamepad.justPressed.DPAD_DOWN;
			leftPcontroller = gamepad.justPressed.DPAD_LEFT;
			rightPcontroller = gamepad.justPressed.DPAD_RIGHT;
		}

		// pre lowercasing the song name (update)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase) {
			case 'dad-battle': songLowercase = 'dadbattle';
			case 'philly-nice': songLowercase = 'philly';
		}
		var songPath = 'assets/data/' + songLowercase + '/';

		#if sys
		if (PlayState.isSM && !PlayState.isStoryMode)
			songPath = PlayState.pathToSm;
		#end

		if (controls.UP_P || upPcontroller)
		{
			changeSelection(-1);
   
		}
		else if (controls.DOWN_P || downPcontroller)
		{
			changeSelection(1);
		}
		
		#if cpp
			else if (controls.LEFT_P || leftPcontroller)
			{
				oldOffset = PlayState.songOffset;
				PlayState.songOffset -= 1;
				sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
				perSongOffset.text = "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.';

				// Prevent loop from happening every single time the offset changes
				if(!offsetChanged)
				{
					grpMenuShit.clear();

					menuItems = ['Restart Song', 'Exit to menu'];

					for (i in 0...menuItems.length)
					{
						var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
						songText.isMenuItem = true;
						songText.targetY = i;
						grpMenuShit.add(songText);
					}

					changeSelection();

					cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
					offsetChanged = true;
				}
			} 
			else if (controls.RIGHT_P || rightPcontroller)
			{
				oldOffset = PlayState.songOffset;
				PlayState.songOffset += 1;
				sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
				perSongOffset.text = "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.';
				if(!offsetChanged)
				{
					grpMenuShit.clear();

					menuItems = ['Restart Song', 'Exit to menu'];

					for (i in 0...menuItems.length)
					{
						var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
						songText.isMenuItem = true;
						songText.targetY = i;
						grpMenuShit.add(songText);
					}

					changeSelection();

					cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
					offsetChanged = true;
				}
			}
		#end

		if (controls.ACCEPT && !FlxG.keys.pressed.ALT && confirmButtonEnabled)
		{
			if (difficultyMenu)
				{
					if (PlayState.SONG.song == "Gospel" || PlayState.SONG.song == "Casanova")
					{
						PlayState.SONG = Song.loadFromJson(Highscore.formatSong(StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase(), 3), PlayState.SONG.song);
						PlayState.storyDifficulty = curSelected;
					}
					else
					{
						PlayState.SONG = Song.loadFromJson(Highscore.formatSong(StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase(), curSelected), PlayState.SONG.song);
						PlayState.storyDifficulty = curSelected;
					}
					FlxG.resetState();
				}
			else
				{		
			    switch (menuItems[curSelected])
			    {
			    	case "Resume":
			    		close();
						pauseMusic.stop();
			    	case "Restart Song":
			    		PlayState.startTime = 0;
			    		if (PlayState.instance.useVideo)
			    		{
			    			GlobalVideo.get().stop();
			    			PlayState.instance.remove(PlayState.instance.videoSprite);
			    			PlayState.instance.removedVideo = true;
			    		}
			    		PlayState.instance.clean();
			    		FlxG.resetState();
					case "Change Difficulty":
						switchMenu();
					case "Options":
						goToOptions = true;
						//close();	
						//idfk what they did here but it doesnt work????
						FlxG.switchState(new OptionsMenu());		
			    	case "Exit to menu":
			    		PlayState.startTime = 0;
			    		if (PlayState.instance.useVideo)
			    		{
			    			GlobalVideo.get().stop();
			    			PlayState.instance.remove(PlayState.instance.videoSprite);
			    			PlayState.instance.removedVideo = true;
			    		}
			    		if(PlayState.loadRep)
			    		{
			    			FlxG.save.data.botplay = false;
			    			FlxG.save.data.scrollSpeed = 1;
			    			FlxG.save.data.downscroll = false;
			    		}
			    		PlayState.loadRep = false;
			    		#if windows
			    		if (PlayState.luaModchart != null)
			    		{
			    			PlayState.luaModchart.die();
			    			PlayState.luaModchart = null;
			    		}
			    		#end
			    		if (FlxG.save.data.fpsCap > 290)
			    			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
			    		
			    		PlayState.instance.clean();
    
			    		if (PlayState.isStoryMode)
			    			FlxG.switchState(new StoryMenuState());
			    		else
			    			FlxG.switchState(new FreeplayState());
			    }
			}
		}

		if (controls.BACK)
			{
				// Go back to pause options
				if (difficultyMenu)
				{
					switchMenu();
				}
				// Resume the game
				else if (!offsetChanged)
				{
					close();
				}
			}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function destroy()
	{
		if (!goToOptions)
			{
				pauseMusic.destroy();
				playingPause = false;
			}

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;
		
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function switchMenu()
		{
			// Bring it back to the first in the index and toggle the flag
			curSelected = 0;
			difficultyMenu = !difficultyMenu;
	
			// Rename the settings
			if (difficultyMenu)
			{
				if (PlayState.SONG.song == "Gospel" || PlayState.SONG.song == "Casanova")
					menuItems = ['Hard', 'Alt'];
				else
					menuItems = ['Easy', 'Normal', 'Hard', 'Alt'];
			}
			else
			{
				if (offsetChanged)
				{
					menuItems = ['Restart Song', 'Change Difficulty', 'Exit to menu'];
				}
				else
				{
					menuItems = ['Resume', 'Restart Song', 'Change Difficulty', 'Exit to menu'];
				}
			}
	
			// Clear and recreate the objects
			grpMenuShit.clear();
			for (i in 0...menuItems.length)
			{
				var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
				songText.isMenuItem = true;
				songText.targetY = i;
				grpMenuShit.add(songText);
			}
	
			// Update positions
			changeSelection();
		}
}
