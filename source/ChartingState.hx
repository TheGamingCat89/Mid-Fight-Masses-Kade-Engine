package;

import Options;
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import Song.SongMeta;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import HealthIcon;
#if cpp
import Discord.DiscordClient;
#end

using StringTools;

class ChartingState extends MusicBeatState
{
	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	
	//Array of notes showing when each section STARTS in STEPS
	//Usually rounded up??

	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;
	var noteStyle:Int = 0;
	var types:Array<String> = ['normal', 'holy', 'unholy'];

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;
	var useHitSounds = false;
	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<Note>;

	private var songRate:Float = 1;

	var gridBG:FlxSprite;
	var quantization:Int = 16;
	var quantIdx = 0;
	var quantizations:Array<Int> = [
		16,
		8,
		6, // because echo needs 1/6 lmao
		4,
	];

	public static var _song:SwagSong;

	var typingShit:FlxInputText;
	
	//WILL BE THE CURRENT / LAST PLACED NOTE
	
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;

	var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	public static var latestChartVersion = "2";

	override function create()
	{
		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBG);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<Note>();

		if (PlayState.SONG != null){
			_song = PlayState.SONG;
		}else
		{
			_song = {
				chartVersion: latestChartVersion,
				songId: 'test',
				songName: 'Test',
				notes: [],
				eventObjects: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',				
				gfVersion: 'gf',
				noteStyle: 'normal',
				stage: 'stage',			
				speed: 1,
				validScore: false
			};
		}

		FlxG.mouse.visible = true;
		FlxG.save.bind('funkin', 'ninjamuffin99');

		tempBpm = _song.bpm;

		leftIcon = new HealthIcon(_song.player1, false);
		rightIcon = new HealthIcon(_song.player2, true);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		addSection();
		// sections = _song.notes;

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		dummyArrow.setGraphicSize(GRID_SIZE,GRID_SIZE);
		dummyArrow.updateHitbox();
		dummyArrow.alpha=.5;
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2;
		UI_box.y = 20;
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);

		add(curRenderedNotes);
		add(curRenderedSustains);
		curSection = 0;
		updateSectionUI();

		super.create();
	}

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var check_mute_inst = new FlxUICheckBox(10, 350, null, null, "Mute Instrumental", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			if(FlxG.sound.music != null)
			{
				var vol:Float = 1;
				if (check_mute_inst.checked)
					vol = 0;
				FlxG.sound.music.volume = vol;
			}
		};

		var check_mute_vocals =  new FlxUICheckBox(10, 300, null, null, "Mute Vocals", 100);
		check_mute_vocals.checked = false;
		check_mute_vocals.callback = function()
		{
			if(vocals!=null)
			{
				trace('vocals arent null');
				var vol:Float = 1;
				if (check_mute_vocals.checked)
					vol = 0;
				vocals.volume = vol;
			}	
			trace('function callback');	
		}

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		var restart = new FlxButton(saveButton.x, reloadSongJson.y, "Reset Chart", function()
        {
            for (ii in 0..._song.notes.length)
            {
                for (i in 0..._song.notes[ii].sectionNotes.length)
                    {
                        _song.notes[ii].sectionNotes = [];
                    }
            }
            resetSection(true);
        });


		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);

		var rate:FlxUINumericStepper = new FlxUINumericStepper(100, 80, 0.1, 1, 0.5, 3, 1);
		rate.value = songRate;
		rate.name = 'song_rate';

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 1, 1, 1, 339, 0);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/characterList'));
		var gfVersions:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/gfVersionList'));
		var stages:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/stageList'));
		var noteStyles:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/noteStyleList'));



		var player1DropDown = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
		});
		player1DropDown.selectedLabel = _song.player1;

		var player2DropDown = new FlxUIDropDownMenu(140, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
		});

		player2DropDown.selectedLabel = _song.player2;

		var gfVersionDropDown = new FlxUIDropDownMenu(10, 200, FlxUIDropDownMenu.makeStrIdLabelArray(gfVersions, true), function(gfVersion:String)
			{
				_song.gfVersion = gfVersions[Std.parseInt(gfVersion)];
			});
		gfVersionDropDown.selectedLabel = _song.gfVersion;

		var stageDropDown = new FlxUIDropDownMenu(140, 200, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String)
			{
				_song.stage = stages[Std.parseInt(stage)];
			});
		stageDropDown.selectedLabel = _song.stage;

		var noteStyleDropDown = new FlxUIDropDownMenu(10, 300, FlxUIDropDownMenu.makeStrIdLabelArray(noteStyles, true), function(noteStyle:String)
			{
				_song.noteStyle = noteStyles[Std.parseInt(noteStyle)];
			});
		noteStyleDropDown.selectedLabel = _song.noteStyle;

		var check_use_hit = new FlxUICheckBox(135, 350, null, null, "Use hit sounds (in editor)", 100);
		check_use_hit.checked = false;
		check_use_hit.callback = function()
		{
			useHitSounds=check_use_hit.checked;
		};

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(check_mute_vocals);
		tab_group_song.add(check_use_hit);
		tab_group_song.add(saveButton);
		tab_group_song.add(restart);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(rate);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(player2DropDown);
		tab_group_song.add(noteStyleDropDown);
		tab_group_song.add(gfVersionDropDown);
		tab_group_song.add(stageDropDown);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;
	var check_crossFade:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		check_crossFade = new FlxUICheckBox(200, 350, null, null, "CrossFade", 100);
		check_crossFade.name = 'check_crossFade';

		check_altAnim = new FlxUICheckBox(10, 350, null, null, "Alt Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(check_crossFade);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;


	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';


		var applyLength:FlxButton = new FlxButton(100, 10, 'Apply');

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(applyLength);

		UI_box.addGroup(tab_group_note);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		FlxG.sound.playMusic(Paths.inst(daSong), 0.6);

		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));
		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);

		/*
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;

					updateHeads();

				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case 'CrossFade':
					_song.notes[curSection].crossFade = check.checked;
				case "Alt Animation":
					_song.notes[curSection].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = Std.int(nums.value);
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(Std.int(nums.value));
			}
			else if (wname == 'note_susLength')
			{
				curSelectedNote[2] = nums.value;
				updateGrid();
			}
			else if (wname == 'section_bpm')
			{
				_song.notes[curSection].bpm = Std.int(nums.value);
				updateGrid();
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function sectionStartTime():Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}
	function sectionEndTime():Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection+1)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		if(FlxG.keys.justPressed.ALT){
			quantIdx+=1;
			if(quantIdx>quantizations.length-1)
				quantIdx = 0;

			quantization = quantizations[quantIdx];
		}

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed || FlxG.mouse.justPressedRight)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						trace(note.strumTime,note.rawNoteData);
						if (FlxG.keys.pressed.CONTROL)
						{
							trace("tryin to select note...");
							selectNote(note);
						}
						else
						{
							trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added note');
					addNote(FlxG.mouse.justPressedRight);
				}
			}
		}

		//if(FlxG.keys.justPressed.M){
			//addScrollChange();
		//}

		curRenderedNotes.forEach(function(note:Note){
			if(note.strumTime<=Conductor.songPosition && note.noteStyle==0){
				if(note.color!=0xAAAAAA){
					if(!note.wasGoodHit){
						note.wasGoodHit=true;
						if(useHitSounds){
							if(note.rawNoteData<=3)
								FlxG.sound.play(Paths.sound('SNAP'));
						}
					}

					note.color = 0xAAAAAA;
				}

			}else{
				note.wasGoodHit=false;
				note.color = 0xFFFFFF;
			}
		});

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			//dummyArrow.setDir(Math.floor(FlxG.mouse.x / GRID_SIZE)%4,false,false);
			dummyArrow.setGraphicSize(GRID_SIZE,GRID_SIZE);
			dummyArrow.updateHitbox();
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / (GRID_SIZE*quantization/16)) * (GRID_SIZE*quantization/16);
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			lastSection = curSection;

			PlayState.SONG = _song;
			//PlayState.SONG.sliderVelocities = velChanges;
			FlxG.sound.music.stop();
			vocals.stop();
			FlxG.mouse.visible = false;
			FlxG.switchState(new PlayState());
		}

		if(FlxG.keys.pressed.SHIFT){

		}else{
			if (FlxG.keys.justPressed.E)
			{
				changeNoteSustain(Conductor.stepCrochet);
			}
			if (FlxG.keys.justPressed.Q)
			{
				changeNoteSustain(-Conductor.stepCrochet);
			}
		}


		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (!typingShit.hasFocus)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					vocals.pause();
				}
				else
				{
					vocals.play();
					FlxG.sound.music.play();
					#if cpp
					@:privateAccess
					{
						if (FlxG.sound.music.playing)
							lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songRate);
						if(vocals.playing)
							lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songRate);
					}
					#end
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				vocals.time = FlxG.sound.music.time;
			}

			if (FlxG.keys.justPressed.N){
				this.noteStyle -= 1;
				if (noteStyle < 0)
					noteStyle = types.length - 1;
				trace("Changed to " +  types[noteStyle]);
			}
			if (FlxG.keys.justPressed.M){
				this.noteStyle += 1;
				if (noteStyle == types.length)
					noteStyle = 0;
				trace("Changed to " +  types[noteStyle]);
			}

			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
			else
			{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
		}

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */

	    var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;
		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
			changeSection(curSection + shiftThing);
		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
			changeSection(curSection - shiftThing);

		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection
			+ "\nStep: "
			+ curStep
			+ "\nBeat: "
			+ curBeat
			+ "\nSnap: 1/"
			+ quantization + "\n(Press ALT to switch)";

		#if windows
		var difficulty:String = '';

		switch (PlayState.storyDifficulty){
			case 0:
			    difficulty = 'Easy';
			case 1:
				difficulty = 'Normal';
			case 2:
				difficulty = 'Hard';
			case 3: 
				difficulty = 'Alt';
		}
		DiscordClient.changePresence("In charter: "
		+ Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
		+ " / "
		+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
		+ "|\nSection: "
		+ curSection 
		+ " " 
		+ PlayState.SONG.song 
		+ " (" 
		+ difficulty 
		+ ") "
		+ null,null,false,0);
		#end
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				//dont remove (reminder to self)
				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
			for(i in curRenderedNotes){
				i.wasGoodHit=false;
			}
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[4]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];
		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;		
		check_crossFade.checked = sec.crossFade;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void
	{
		if (check_mustHitSection.checked)
		{
			leftIcon.animation.play(_song.player1);
			rightIcon.animation.play(_song.player2);
		}
		else
		{
			leftIcon.animation.play(_song.player2);
			rightIcon.animation.play(_song.player1);
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	function updateGrid():Void
	{
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		 var oldNote:Note;
		 for (i in sectionInfo)
 		{
 			var daNoteInfo = i[1];
 			var daStrumTime = i[0];
 			var daSus = i[2];
			var daStyle = i[4];

 			var note:Note = new Note(daStrumTime, daNoteInfo % 4, null, false, true, true, daStyle);
			note.wasGoodHit = daStrumTime<Conductor.songPosition;
 			note.rawNoteData = daNoteInfo;
 			note.sustainLength = daSus;
 			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
 			note.updateHitbox();
 			oldNote=note;

 			note.x = Math.floor(daNoteInfo * GRID_SIZE);
 			note.y = getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

 			curRenderedNotes.add(note);

 			if (daSus > 0)
 			{
				//dont remove
 				/*var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
 					note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
 				curRenderedSustains.add(sustainVis);*/
 			    daSus = daSus/Conductor.stepCrochet;
 				var sus = [];
 				for (susNote in 0...Math.floor(daSus))
 				{
 					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteInfo % 4, oldNote, true,true,true, types[this.noteStyle]);
 					sustainNote.rawNoteData = daNoteInfo;
 					sustainNote.setGraphicSize(GRID_SIZE, GRID_SIZE);
 					sustainNote.updateHitbox();
 					sustainNote.x = Math.floor(daNoteInfo * GRID_SIZE);
 					sustainNote.y = oldNote.y + GRID_SIZE;
 					sustainNote.flipY = false;
 					sustainNote.scale.y = 1;
 					oldNote = sustainNote;
 					curRenderedSustains.add(sustainNote);
 				}
 				for(i in curRenderedSustains){
					switch(i.noteStyle){
						default:
		 					if(i.animation.curAnim.name.endsWith("end") ){
		 						if(PlayState.curStage.startsWith("school")){
		 							i.setGraphicSize(Std.int(GRID_SIZE*.35), Std.int(GRID_SIZE*.35));
		 							i.updateHitbox();
		 							i.offset.x = -17.25;
		 							i.offset.y = (GRID_SIZE*.35)/2-12;
		 						}else{
		 							i.setGraphicSize(Std.int(GRID_SIZE*.35), Std.int((GRID_SIZE)/2)+2);
		 							i.updateHitbox();
		 							i.offset.x = 5;
		 							i.offset.y = (GRID_SIZE)/2+2;
		 						}

		 						i.x = Math.floor(i.rawNoteData * GRID_SIZE);
		 					}else{
		 						i.setGraphicSize(Std.int(GRID_SIZE*.35), GRID_SIZE+1);
		 						i.updateHitbox();
		 						i.offset.x = 5;
		 						if(PlayState.curStage.startsWith("school")){
		 							i.offset.x = -17.25;
		 						}
		 						i.x = Math.floor(i.rawNoteData * GRID_SIZE);
		 					}
						}
					}
 				}
 			}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
        var daPos:Float = 0;

		var sec:SwagSection = {
			startTime: daPos,
			endTime: Math.POSITIVE_INFINITY,
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false,
			p1AltAnim: false,
			p2AltAnim: false,
			crossFade: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			trace(i[0],i[1],note.strumTime,note.rawNoteData);
			if (i[0] == note.strumTime && i[1] == note.rawNoteData)
			{
				curSelectedNote = i;
			}
		}

		updateGrid();
	}

	function deleteNote(note:Note):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] == note.rawNoteData)
			{
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.notes[curSection].sectionNotes.remove(i);
			}
		}
		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote(rightClick:Bool, ?n:Note):Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0; //GET OUT OF MY HEAD GET OUT OF MY HEAD GET OUT OF MY HEAD 
		var noteStyle = types[this.noteStyle];
		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, false, noteStyle]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if(FlxG.keys.pressed.CONTROL){
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData+4)%8, noteSus, noteStyle]);
		}

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}
    //donNT REMOVe
	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/

	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		FlxG.resetState();
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		LoadingState.loadAndSwitchState(new ChartingState());
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song,
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{										//easy  normal  hard    alt
		var difficultyArray:Array<String> = ["-easy", "", "-hard", "-alt"];
		var json = {
			"song": _song
		};
									// \t helps with organizing the chart :D
		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + difficultyArray[PlayState.storyDifficulty] + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	
	//Called when the save file dialog is cancelled.
	
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	
	//Called if there is an error while saving the gameplay recording.
	
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}
