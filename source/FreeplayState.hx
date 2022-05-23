package;

import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.utils.Future;
import openfl.media.Sound;
import flixel.system.FlxSound;
#if sys
import smTools.SMFile;
import sys.FileSystem;
import sys.io.File;
#end
import Song.SwagSong;
import flixel.input.gamepad.FlxGamepad;
import Character;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxCamera;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	//public static var songs:Array<FreeplaySongMetadata> = [];
	public static var weeks:Array<WeekMetadata> = null;

	var selector:FlxText;
	public static var curWeekSelected:Int = 0;
	public static var curSongSelected:Int = 0;
	public static var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var diffCalcText:FlxText;
	var previewtext:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';
	var bg:FlxSprite;
	var scoreBG:FlxSprite;
	var text:FlxText;

	#if PRELOAD_ALL
	var leText:String = "Press SPACE to listen to this song";
	var size:Int = 16;
	#end

	//color tweening shit
	var coolColor:FlxColor = 0xFFAAAAAA;
	var tweenlol:FlxTween;
	var iconColor:String = "FFAAAAAA";
	var actualColor:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;
	private var grpIcons:FlxTypedGroup<HealthIcon>;

	public static var curWeek:Int = 0;
	public static var openedPreview = false;
	public static var songData:Map<String,Array<SwagSong>> = [];
	
	public static var isWeek:Bool = true;
	public static var songPlaying:Bool = false;

	public static function loadDiff(diff:Int, format:String, name:String, array:Array<SwagSong>)
	{
		try {
			array.push(Song.loadFromJson(Highscore.formatSong(format, diff), name));
		} catch(ex) {
			trace(ex);
		}
	}

	override function create()
	{
		clean();
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));
		//var weekList = CoolUtil.coolTextFile(Paths.txt('data/freeplayWeeklist'));

		songData = [];

		weeks = [];
		
		//loading data
		for (list in initSonglist) // each week
		{
			var weekData:Array<String> = list.split('/')[0].split(":");
			var songsData:Array<String> = list.split('/')[1].split(":");
	
			var weekSongsShit:Array<FreeplaySongMetadata> = [];
	
			for (pre in songsData) // each song per week
			{
				var data = pre.split("=");
				var meta = new FreeplaySongMetadata(data[0], data[1]);
	
				var format = StringTools.replace(meta.songName, " ", "-");
				switch (format) {
					case 'Dad-Battle': format = 'Dadbattle';
					case 'Philly-Nice': format = 'Philly';
				}
				
				var diffs = [];
				var diffsThatExist = [];
				
				
				#if sys
				if (FileSystem.exists('assets/data/${format}/${format}-hard.json'))
					diffsThatExist.push("Hard");
				if (FileSystem.exists('assets/data/${format}/${format}-easy.json'))
					diffsThatExist.push("Easy");
				if (FileSystem.exists('assets/data/${format}/${format}.json'))
					diffsThatExist.push("Normal");
				if (FileSystem.exists('assets/data/${format}/${format}-alt.json'))
					diffsThatExist.push("Alt");
			
				if (diffsThatExist.length == 0)
				{
					Application.current.window.alert("No difficulties found for chart, skipping.",meta.songName + " Chart");
					continue;
				}
				#else
				diffsThatExist = ["Easy","Normal","Hard","Alt"];
				#end
				if (diffsThatExist.contains("Easy"))
					FreeplayState.loadDiff(0,format,meta.songName,diffs);
				if (diffsThatExist.contains("Normal"))
					FreeplayState.loadDiff(1,format,meta.songName,diffs);
				if (diffsThatExist.contains("Hard"))
					FreeplayState.loadDiff(2,format,meta.songName,diffs);
				if (diffsThatExist.contains("Alt"))
					FreeplayState.loadDiff(3,format,meta.songName,diffs);
			
				meta.diffs = diffsThatExist;
	
				if (diffsThatExist.length != 4)
					trace("I ONLY FOUND " + diffsThatExist);
			
				FreeplayState.songData.set(meta.songName,diffs);
				trace('loaded diffs for ' + meta.songName);
	
				weekSongsShit.push(meta);
			}
			
			weeks.push(new WeekMetadata(weekData[0], Std.parseInt(weekData[1]), songsData[0].split("=")[1], weekSongsShit));
		}
		
		//stepmania is rarely even used so ill remove it

		//trace("\n" + diffList);

		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		 #if windows
		 // Updating Discord Rich Presence
		 DiscordClient.changePresence("In the Freeplay Menu", null);
		 #end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		persistentUpdate = true;

		// LOAD MUSIC

		// LOAD CHARACTERS

		if(!FlxG.save.data.flashing)
			bg = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'))
		else
			bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

        grpSongs = new FlxTypedGroup<Alphabet>();
        add(grpSongs);    

		grpIcons = new FlxTypedGroup<HealthIcon>();
		add(grpIcons);

		for (i => week in weeks)
		{
			var weekText:Alphabet = new Alphabet(100, (70 * i) + 30, week.weekName, true, false, true);
			weekText.isMenuItem = true;
			weekText.targetY = i;
			grpSongs.add(weekText);
		
			var icon:HealthIcon = new HealthIcon(week.weekCharacter);
			icon.sprTracker = weekText;
			grpIcons.add(icon);
			//add(icon);
	
			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}	

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		bg.color = coolColor;
		actualColor = bg.color;

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 105, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		diffCalcText = new FlxText(scoreText.x, scoreText.y + 66, 0, "", 24);
		diffCalcText.font = scoreText.font;
		add(diffCalcText);

		previewtext = new FlxText(scoreText.x, scoreText.y + 94, 0, "" + (KeyBinds.gamepad ? "X" : "SPACE") + " to preview", 24);
		previewtext.font = scoreText.font;
		//add(previewtext);

		comboText = new FlxText(diffText.x + 100, diffText.y, 0, "", 24);
		comboText.font = diffText.font;
		add(comboText);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		add(selector);

		#if PRELOAD_ALL
		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		text = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		text.scrollFactor.set();
		add(text);

		FlxTween.tween(text, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(textBG, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});
		#end

		super.create();
	}

	public function addWeek(weekName:String, songs:Array<FreeplaySongMetadata>, weekNum:Int)
	{
		weeks.push(new FreeplayState.WeekMetadata(weekName, weekNum, songs[0].songCharacter, songs));
	}
		

	var instPlaying:String = '';
	public static var curPlayingTxt:String = "N/A";
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		comboText.text = combo + '\n';

		grpIcons.members[(isWeek ? curWeekSelected : curSongSelected)].setGraphicSize(Std.int(FlxMath.lerp(grpIcons.members[(isWeek ? curWeekSelected : curSongSelected)].width, 150, 0.09/(openfl.Lib.current.stage.frameRate/60))));

		grpIcons.members[(isWeek ? curWeekSelected : curSongSelected)].updateHitbox();

		switch(combo)
		{
			case 'MFC':
				scoreBG.color = FlxColor.CYAN;
			case 'GFC':
				scoreBG.color = FlxColor.GREEN;
			case 'FC':
				scoreBG.color = FlxColor.YELLOW;
			case 'SDCB':
				scoreBG.color = FlxColor.RED;
			case 'CLEAR':
				scoreBG.color = FlxColor.fromRGB(89,0,0);
			case '':
				scoreBG.color = 0xFF000000;
		}

		if (FlxG.sound.music.volume > 0.8)
		{
			FlxG.sound.music.volume -= 0.5 * FlxG.elapsed;
		}

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
		var accepted = FlxG.keys.justPressed.ENTER;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{

			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(1);
			}
			if (gamepad.justPressed.DPAD_LEFT)
			{
				changeDiff(-1);
			}
			if (gamepad.justPressed.DPAD_RIGHT)
			{
				changeDiff(1);
			}

			//if (gamepad.justPressed.X && !openedPreview)
				//openSubState(new DiffOverview());
		}

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		//if (FlxG.keys.justPressed.SPACE && !openedPreview)
			//openSubState(new DiffOverview());

		if (FlxG.keys.justPressed.LEFT)
			changeDiff(-1);
		if (FlxG.keys.justPressed.RIGHT)
			changeDiff(1);

		if (controls.BACK)
		{
			if(tweenlol != null) {
				tweenlol.cancel();
			}
			if(!isWeek)
			{			
				isWeek = true;
				grpSongs.clear();
				grpIcons.clear();
				for (i => week in weeks)
				{
					var weekText:Alphabet = new Alphabet(100, (70 * i) + 30, week.weekName, true, false, true);
					weekText.isMenuItem = true;
					weekText.targetY = i;
					grpSongs.add(weekText);
				
					var icon:HealthIcon = new HealthIcon(week.weekCharacter);
					icon.sprTracker = weekText;
					grpIcons.add(icon);
				}
				curSongSelected = 0;
				changeSelection();
			}
			else
				FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			if (isWeek)
			{
				//this should work?
				isWeek = false;
				grpSongs.clear();
				grpIcons.clear();
				for (i => song in weeks[curWeekSelected].songs)
				{
					var songLabel:Alphabet = new Alphabet(100, (70 * i) + 30,song.songName, true, false);
					songLabel.isMenuItem = true;
					songLabel.targetY = i;
					grpSongs.add(songLabel);

					var icon:HealthIcon = new HealthIcon(song.songCharacter);
					icon.sprTracker = songLabel;
					grpIcons.add(icon);
					//add(icon);
				}
				curSongSelected = 0;
				changeSelection(curSongSelected);
			}
			else
			{
				// adjusting the song name to be compatible
				var songFormat = StringTools.replace(weeks[curWeekSelected].songs[curSongSelected].songName, " ", "-");
				switch (songFormat) {
					case 'Dad-Battle': songFormat = 'Dadbattle';
					case 'Philly-Nice': songFormat = 'Philly';
				}
				var hmm;
				try
				{
					hmm = songData.get(weeks[curWeekSelected].songs[curSongSelected].songName)[curDifficulty];
					if (hmm == null)
						return;
				}
				catch(ex)
				{
					return;
				}
			
				var poop:String = Highscore.formatSong(weeks[curWeekSelected].songs[curSongSelected].songName.toLowerCase(), curDifficulty);
			
				PlayState.SONG = Song.conversionChecks(hmm);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
				PlayState.storyWeek = weeks[curWeekSelected].week;
				trace('CUR WEEK' + PlayState.storyWeek);
				if(tweenlol != null) {
					tweenlol.cancel();
				}
				#if sys
				if (weeks[curWeekSelected].songs[curSongSelected].songCharacter == "sm")
					{
						PlayState.isSM = true;
						PlayState.sm = weeks[curWeekSelected].songs[curSongSelected].sm;
						PlayState.pathToSm = weeks[curWeekSelected].songs[curSongSelected].path;
					}
				else
					PlayState.isSM = false;
				#else
				PlayState.isSM = false;
				#end
				LoadingState.loadAndSwitchState(new PlayState());
				clean();    
			}
		}

		if(FlxG.keys.justPressed.SPACE)
		{
			#if PRELOAD_ALL
			if(instPlaying != weeks[curWeekSelected].songs[curSongSelected].songName.toLowerCase() && !isWeek)
			{
				FlxG.sound.music.volume = 0;
	
				var poop:String = Highscore.formatSong(weeks[curWeekSelected].songs[curSongSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, weeks[curWeekSelected].songs[curSongSelected].songName.toLowerCase());

				curPlayingTxt = weeks[curWeekSelected].songs[curSongSelected].songName.toLowerCase();

				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
	
				instPlaying = weeks[curWeekSelected].songs[curSongSelected].songName.toLowerCase();
				songPlaying = true;
	
				trace('playing ' + poop);
	
				text.text = 'Playing ' + weeks[curWeekSelected].songs[curSongSelected].songName + '!';
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					text.text = leText;
				});
	
				var song;
				try
				{
					song = songData.get(weeks[curWeekSelected].songs[curSongSelected].songName)[curDifficulty];
					if (song != null)
						Conductor.changeBPM(song.bpm);
				} catch(ex) { trace(ex); }

			} else if (isWeek)
				trace("this is a week, it doesnt have a song to load")
			else
			{
				text.text = 'This song is already playing!';
				new FlxTimer().start(0.6, function(tmr:FlxTimer)
				{
					text.text = leText;
				});
			}
			#end
		}
	}

	/**
    * Load into a song in free play, by name.
    * This is a static function, so you can call it anywhere.
    * @param songName The name of the song to load. Use the human readable name, with spaces.
    * @param isCharting If true, load into the Chart Editor instead.
    */
    public static function loadSongInFreePlay(songName:String, difficulty:Int, isCharting:Bool, reloadSong:Bool = false)
    {
    	var currentSongData;
    	try
    	{
    		if (songData.get(songName) == null)
    			return;
    		currentSongData = songData.get(songName)[difficulty];
    		if (songData.get(songName)[difficulty] == null)
    			return;
    	}
    	catch (ex)
    	{
    		return;
    	}

    	PlayState.SONG = currentSongData;
    	PlayState.isStoryMode = false;
    	PlayState.storyDifficulty = difficulty;
    	PlayState.storyWeek = weeks[curWeekSelected].week;

    	if (isCharting)
    		LoadingState.loadAndSwitchState(new ChartingState(/*reloadSong*/));
    	else
    		LoadingState.loadAndSwitchState(new PlayState());
    }

	var hardSongs = ['gospel', 'casanova', 'ruvel'];
    
	function changeDiff(change:Int = 0)
	{
		if (isWeek) return;

		if (!weeks[curWeekSelected].songs[curSongSelected].diffs.contains(CoolUtil.difficultyFromInt(curDifficulty + change)))
			return;

		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 3;
		if (curDifficulty > 3)
			curDifficulty = 0;

		#if !debug
		if(hardSongs.contains(weeks[curWeekSelected].songs[curSongSelected].songName.toLowerCase()) && curDifficulty < 2)
			curDifficulty = 2;
		#end
		
		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(weeks[curWeekSelected].songs[curSongSelected].songName, " ", "-");
		switch (songHighscore) {
			case 'Dad-Battle': songHighscore = 'Dadbattle';
			case 'Philly-Nice': songHighscore = 'Philly';
		}
		
		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end
		diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(weeks[curWeekSelected].songs[curSongSelected].songName)[curDifficulty])}';
		diffText.text = CoolUtil.difficultyFromInt(curDifficulty).toUpperCase();
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (isWeek)
		{
			curWeekSelected += change;

			if (curWeekSelected < 0)
				curWeekSelected = weeks.length - 1;
			if (curWeekSelected >= weeks.length)
				curWeekSelected = 0;
		}			
		else 
		{
			curSongSelected += change;

			if (curSongSelected < 0)
				curSongSelected = weeks[curWeekSelected].songs.length - 1;
			if (curSongSelected >= weeks[curWeekSelected].songs.length)
				curSongSelected = 0;
		}		

		if (weeks[curWeekSelected].songs[curSongSelected].diffs.length != 3)
		{
			switch(weeks[curWeekSelected].songs[curSongSelected].diffs[0])
			{
				case "Easy":
					curDifficulty = 0;
				case "Normal":
					curDifficulty = 1;
				case "Hard":
					curDifficulty = 2;
				case "Alt":
					curDifficulty = 3;
			}
		}

		if (isWeek)
		{
			scoreBG.visible = false;
			scoreText.visible = false;
			diffCalcText.visible = false;
			diffText.visible = false;
			comboText.visible = false;
		}
		else
		{
			scoreBG.visible = true;
			scoreText.visible = true;
			diffCalcText.visible = true;
			diffText.visible = true;
			comboText.visible = true;
		}
		// selector.y = (70 * curSelected) + 30;
		
		// adjusting the highscore song name to be compatible (changeSelection)
		// would read original scores if we didn't change packages
		var songHighscore = StringTools.replace(weeks[curWeekSelected].songs[curSongSelected].songName, " ", "-");
		switch (songHighscore) {
			case 'Dad-Battle': songHighscore = 'Dadbattle';
			case 'Philly-Nice': songHighscore = 'Philly';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		// lerpScore = 0;
		#end

		diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(weeks[curWeekSelected].songs[curSongSelected].songName)[curDifficulty])}';
		diffText.text = CoolUtil.difficultyFromInt(curDifficulty).toUpperCase();

		if (openedPreview)
		{
			closeSubState();
			openSubState(new DiffOverview());
		}

		var bullShit:Int = 0;

		for (i in 0...grpIcons.members.length)
		{
			grpIcons.members[i].alpha = 0.6;
		}

		grpIcons.members[(isWeek ? curWeekSelected : curSongSelected)].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - (isWeek ? curWeekSelected : curSongSelected);
			bullShit++;
    
			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));
    
			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		
		if(FlxG.save.data.flashing){
			//uh??
			var colorSheet:Array<String> = CoolUtil.coolTextFile(Paths.txt('images/characters/iconColor', 'shared'));		
			for (data in colorSheet)
			{
				var colorData:Array<String> = data.split(':');
    			if(colorData[0] == weeks[curWeekSelected].songs[curSongSelected].songCharacter)
					iconColor = colorData[1];
			}

			coolColor = FlxColor.fromString('#' + iconColor);

			if(coolColor != actualColor){
				if(tweenlol != null)
					tweenlol.cancel();

				actualColor = coolColor;
			    FlxTween.color(bg, 1, bg.color, actualColor, {
			    	onComplete: function(twn:FlxTween) {
			    		tweenlol = null;
			    	}
			    });		    
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		grpIcons.members[(isWeek ? curWeekSelected : curSongSelected)].setGraphicSize(Std.int(grpIcons.members[(isWeek ? curWeekSelected : curSongSelected)].width + 30));

		grpIcons.members[(isWeek ? curWeekSelected : curSongSelected)].updateHitbox();

		var zoomShit:Float = 1.02;

		//add your song here if you want them to have extra zoom on beat
		switch(weeks[curWeekSelected].songs[curSongSelected].songName.toLowerCase()){
			case 'zavodila' | 'milf':
				zoomShit = 0.08;
			default:
				zoomShit = 0.04;
		}

		bg.scale.x += zoomShit;
		bg.scale.y += zoomShit;
		FlxTween.tween(bg, {"scale.x": 1, "scale.y": 1}, 0.1);

		if (weeks[curWeekSelected].songs[curSongSelected].songCharacter.toLowerCase() == 'ruv')
			FlxG.camera.shake(0.01, 0.1);
		else
			FlxG.camera.shake(0.0025, 0.1);
	}
}

class WeekMetadata
{
	public var weekName:String = "";
	public var week:Int = 0;
	public var weekCharacter:String = "";
	public var songs:Array<FreeplaySongMetadata> = [];

	public function new(weekName:String, week:Int, weekCharacter:String, songs:Array<FreeplaySongMetadata>)
    {
		this.weekName = weekName;
		this.week = week;
		this.weekCharacter = weekCharacter;
		this.songs = songs;
	}
}

class FreeplaySongMetadata
{
	public var songName:String = "";
	#if sys
	public var sm:SMFile;
	public var path:String;
	#end
	public var songCharacter:String = "";

	public var diffs = [];

	#if sys
	public function new(song:String, songCharacter:String, ?sm:SMFile = null, ?path:String = "")
	{
		this.songName = song;
		this.songCharacter = songCharacter;
		this.sm = sm;
		this.path = path;
	}
	#else
	public function new(song:String, songCharacter:String)
	{
		this.songName = song;
		this.songCharacter = songCharacter;
	}
	#end
}
