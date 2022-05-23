package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var sarvHappy:FlxSprite;
	var sarvSad:FlxSprite;
	var sarvUpset:FlxSprite;
	var sarvAngery:FlxSprite;
	var sarvSmile:FlxSprite;
	var sarvDevil:FlxSprite;
	var sarvSadDark:FlxSprite;

	var ruvNormal:FlxSprite;
	var ruvBruh:FlxSprite;
	var ruvAngery:FlxSprite;

	var bfPortEnter:FlxSprite;
	var bfPortHappy:FlxSprite;
	var bfPortSad:FlxSprite;

	var gfPortEnter:FlxSprite;
	var gfPortHappy:FlxSprite;
	
	var selHappy:FlxSprite;
	var selSmile:FlxSprite;
	var selUpset:FlxSprite;
	var selXD:FlxSprite;
	var selAngery:FlxSprite;

	var rasNormal:FlxSprite;
	var rasBruh:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);				
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(-20, 45);
		
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
			case 'roses':
				hasDialog = true;
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));

				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);

			case 'thorns':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);

				var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				face.setGraphicSize(Std.int(face.width * 6));
				add(face);
			case 'parish':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByIndices('normal', 'speech bubble normal', [4], "", 24);
				box.width = 200;
				box.height = 200;
				box.x = -100;
				box.y = 375;
	
			case 'worship':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByIndices('normal', 'speech bubble normal', [4], "", 24);
				box.width = 200;
				box.height = 200;
				box.x = -100;
				box.y = 375;
	
			case 'zavodila':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByIndices('normal', 'speech bubble normal', [4], "", 24);
				box.width = 200;
				box.height = 200;
				box.x = -100;
				box.y = 375;
	
			case 'gospel':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByIndices('normal', 'speech bubble normal', [4], "", 24);
				box.width = 200;
				box.height = 200;
				box.x = -100;
				box.y = 375;
	
			case 'casanova':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByIndices('normal', 'speech bubble normal', [4], "", 24);
				box.width = 200;
				box.height = 200;
				box.x = -100;
				box.y = 375; 
		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;
		
		portraitLeft = new FlxSprite(-20, 40);
		portraitLeft.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait');
		portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
		portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;

		portraitRight = new FlxSprite(0, 40);
		portraitRight.frames = Paths.getSparrowAtlas('weeb/bfPortrait');
		portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
		portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;

		if (PlayState.SONG.song.toLowerCase()=='parish' || PlayState.SONG.song.toLowerCase()=='worship' || PlayState.SONG.song.toLowerCase()=='zavodila' || PlayState.SONG.song.toLowerCase()=='gospel')
			{
			sarvHappy = new FlxSprite(1500, 10);
			sarvHappy.frames = Paths.getSparrowAtlas('portraits/SarvHappy');
			sarvHappy.animation.addByPrefix('enter', 'sarvHappy', 24, false);
			sarvHappy.setGraphicSize(Std.int(sarvHappy.width * PlayState.daPixelZoom * 0.175));
			sarvHappy.updateHitbox();
			sarvHappy.scrollFactor.set();
			add(sarvHappy);
			(sarvHappy).alpha = 0;
			sarvHappy.visible = false;
	
			sarvSad = new FlxSprite(1500, 10);
			sarvSad.frames = Paths.getSparrowAtlas('portraits/SarvSad');
			sarvSad.animation.addByPrefix('enter', 'sarvSad', 24, false);
			sarvSad.setGraphicSize(Std.int(sarvSad.width * PlayState.daPixelZoom * 0.175));
			sarvSad.updateHitbox();
			sarvSad.scrollFactor.set();
			add(sarvSad);
			sarvSad.visible = false;
	
			sarvUpset = new FlxSprite(1500, 10);
			sarvUpset.frames = Paths.getSparrowAtlas('portraits/SarvUpset');
			sarvUpset.animation.addByPrefix('enter', 'sarvUpset', 24, false);
			sarvUpset.setGraphicSize(Std.int(sarvUpset.width * PlayState.daPixelZoom * 0.175));
			sarvUpset.updateHitbox();
			sarvUpset.scrollFactor.set();
			add(sarvUpset);
			sarvUpset.visible = false;
	
			sarvAngery = new FlxSprite(1500, 10);
			sarvAngery.frames = Paths.getSparrowAtlas('portraits/SarvAngery');
			sarvAngery.animation.addByPrefix('enter', 'sarvAngery', 24, false);
			sarvAngery.setGraphicSize(Std.int(sarvAngery.width * PlayState.daPixelZoom * 0.175));
			sarvAngery.updateHitbox();
			sarvAngery.scrollFactor.set();
			add(sarvAngery);
			sarvAngery.visible = false;
	
			sarvSmile = new FlxSprite(1500, 10);
			sarvSmile.frames = Paths.getSparrowAtlas('portraits/SarvSmile');
			sarvSmile.animation.addByPrefix('enter', 'sarvSmile', 24, false);
			sarvSmile.setGraphicSize(Std.int(sarvSmile.width * PlayState.daPixelZoom * 0.175));
			sarvSmile.updateHitbox();
			sarvSmile.scrollFactor.set();
			add(sarvSmile);
			sarvSmile.visible = false;
	
			sarvDevil = new FlxSprite(1500, 10);
			sarvDevil.frames = Paths.getSparrowAtlas('portraits/SarvDevil');
			sarvDevil.animation.addByPrefix('enter', 'sarvDevil', 24, false);
			sarvDevil.setGraphicSize(Std.int(sarvDevil.width * PlayState.daPixelZoom * 0.175));
			sarvDevil.updateHitbox();
			sarvDevil.scrollFactor.set();
			add(sarvDevil);
			sarvDevil.visible = false;
	
			ruvNormal = new FlxSprite(1500, 10);
			ruvNormal.frames = Paths.getSparrowAtlas('portraits/RuvNormal');
			ruvNormal.animation.addByPrefix('enter', 'ruvNormal', 24, false);
			ruvNormal.setGraphicSize(Std.int(ruvNormal.width * PlayState.daPixelZoom * 0.175));
			ruvNormal.updateHitbox();
			ruvNormal.scrollFactor.set();
			add(ruvNormal);
			ruvNormal.visible = false;
	
			ruvBruh = new FlxSprite(1500, 10);
			ruvBruh.frames = Paths.getSparrowAtlas('portraits/RuvBruh');
			ruvBruh.animation.addByPrefix('enter', 'ruvBruh', 24, false);
			ruvBruh.setGraphicSize(Std.int(ruvBruh.width * PlayState.daPixelZoom * 0.175));
			ruvBruh.updateHitbox();
			ruvBruh.scrollFactor.set();
			add(ruvBruh);
			ruvBruh.visible = false;
	
			ruvAngery = new FlxSprite(1500, 10);
			ruvAngery.frames = Paths.getSparrowAtlas('portraits/RuvAngery');
			ruvAngery.animation.addByPrefix('enter', 'ruvAngery', 24, false);
			ruvAngery.setGraphicSize(Std.int(ruvAngery.width * PlayState.daPixelZoom * 0.175));
			ruvAngery.updateHitbox();
			ruvAngery.scrollFactor.set();
			add(ruvAngery);
			ruvAngery.visible = false;
	
			bfPortEnter = new FlxSprite(1500, 10);
			bfPortEnter.frames = Paths.getSparrowAtlas('portraits/bfPortEnter');
			bfPortEnter.animation.addByPrefix('enter', 'bfPortEnter', 24, false);
			bfPortEnter.setGraphicSize(Std.int(bfPortEnter.width * PlayState.daPixelZoom * 0.175));
			bfPortEnter.updateHitbox();
			bfPortEnter.scrollFactor.set();
			add(bfPortEnter);
			bfPortEnter.visible = false;
	
			bfPortHappy = new FlxSprite(1500, 10);
			bfPortHappy.frames = Paths.getSparrowAtlas('portraits/bfPortHappy');
			bfPortHappy.animation.addByPrefix('enter', 'bfPortHappy', 24, false);
			bfPortHappy.setGraphicSize(Std.int(bfPortHappy.width * PlayState.daPixelZoom * 0.175));
			bfPortHappy.updateHitbox();
			bfPortHappy.scrollFactor.set();
			add(bfPortHappy);
			bfPortHappy.visible = false;
	
			bfPortSad = new FlxSprite(1500, 10);
			bfPortSad.frames = Paths.getSparrowAtlas('portraits/bfPortSad');
			bfPortSad.animation.addByPrefix('enter', 'bfPortSad', 24, false);
			bfPortSad.setGraphicSize(Std.int(bfPortSad.width * PlayState.daPixelZoom * 0.175));
			bfPortSad.updateHitbox();
			bfPortSad.scrollFactor.set();
			add(bfPortSad);
			bfPortSad.visible = false;
	
			gfPortEnter = new FlxSprite(1500, 10);
			gfPortEnter.frames = Paths.getSparrowAtlas('portraits/gfPortEnter');
			gfPortEnter.animation.addByPrefix('enter', 'gfPortEnter', 24, false);
			gfPortEnter.setGraphicSize(Std.int(gfPortEnter.width * PlayState.daPixelZoom * 0.175));
			gfPortEnter.updateHitbox();
			gfPortEnter.scrollFactor.set();
			add(gfPortEnter);
			gfPortEnter.visible = false;
	
			gfPortHappy = new FlxSprite(1500, 10);
			gfPortHappy.frames = Paths.getSparrowAtlas('portraits/gfPortHappy');
			gfPortHappy.animation.addByPrefix('enter', 'gfPortHappy', 24, false);
			gfPortHappy.setGraphicSize(Std.int(gfPortHappy.width * PlayState.daPixelZoom * 0.175));
			gfPortHappy.updateHitbox();
			gfPortHappy.scrollFactor.set();
			add(gfPortHappy);
			gfPortHappy.visible = false;
			}
			
		if (PlayState.SONG.song.toLowerCase()=='casanova')
			{
			selHappy = new FlxSprite(0, 40);
			selHappy.frames = Paths.getSparrowAtlas('portraits/SelHappy');
			selHappy.animation.addByPrefix('enter', 'selHappy', 24, false);
			selHappy.setGraphicSize(Std.int(selHappy.width * PlayState.daPixelZoom * 0.9));
			selHappy.updateHitbox();
			selHappy.scrollFactor.set();
			add(selHappy);
			selHappy.visible = false;
	
			selSmile = new FlxSprite(0, 40);
			selSmile.frames = Paths.getSparrowAtlas('portraits/SelSmile');
			selSmile.animation.addByPrefix('enter', 'selSmile', 24, false);
			selSmile.setGraphicSize(Std.int(selSmile.width * PlayState.daPixelZoom * 0.9));
			selSmile.updateHitbox();
			selSmile.scrollFactor.set();
			add(selSmile);
			selSmile.visible = false;
	
			selUpset = new FlxSprite(0, 40);
			selUpset.frames = Paths.getSparrowAtlas('portraits/SelUpset');
			selUpset.animation.addByPrefix('enter', 'selUpset', 24, false);
			selUpset.setGraphicSize(Std.int(selUpset.width * PlayState.daPixelZoom * 0.9));
			selUpset.updateHitbox();
			selUpset.scrollFactor.set();
			add(selUpset);
			selUpset.visible = false;
	
			selXD = new FlxSprite(0, 40);
			selXD.frames = Paths.getSparrowAtlas('portraits/SelXD');
			selXD.animation.addByPrefix('enter', 'selXD', 24, false);
			selXD.setGraphicSize(Std.int(selXD.width * PlayState.daPixelZoom * 0.9));
			selXD.updateHitbox();
			selXD.scrollFactor.set();
			add(selXD);
			selXD.visible = false;
	
			selAngery = new FlxSprite(0, 40);
			selAngery.frames = Paths.getSparrowAtlas('portraits/SelAngery');
			selAngery.animation.addByPrefix('enter', 'selAngery', 24, false);
			selAngery.setGraphicSize(Std.int(selAngery.width * PlayState.daPixelZoom * 0.9));
			selAngery.updateHitbox();
			selAngery.scrollFactor.set();
			add(selAngery);
			selAngery.visible = false;
	
			rasNormal = new FlxSprite(0, 40);
			rasNormal.frames = Paths.getSparrowAtlas('portraits/RasNormal');
			rasNormal.animation.addByPrefix('enter', 'rasNormal', 24, false);
			rasNormal.setGraphicSize(Std.int(rasNormal.width * PlayState.daPixelZoom * 0.9));
			rasNormal.updateHitbox();
			rasNormal.scrollFactor.set();
			add(rasNormal);
			rasNormal.visible = false;
	
			rasBruh = new FlxSprite(0, 40);
			rasBruh.frames = Paths.getSparrowAtlas('portraits/RasBruh');
			rasBruh.animation.addByPrefix('enter', 'rasBruh', 24, false);
			rasBruh.setGraphicSize(Std.int(rasBruh.width * PlayState.daPixelZoom * 0.9));
			rasBruh.updateHitbox();
			rasBruh.scrollFactor.set();
			add(rasBruh);
			rasBruh.visible = false;
			}
		
		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		portraitLeft.screenCenter(X);

		handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox'));
		add(handSelect);


		if (!talkingRight)
		{
			// box.flipX = true;
		}

		if(PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'roses' || PlayState.SONG.song.toLowerCase() == 'thorns')
			{
		        dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		        dropText.font = 'Pixel Arial 11 Bold';
		        dropText.color = 0xFFD89494;
		        add(dropText);
        
		        swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		        swagDialogue.font = 'Pixel Arial 11 Bold';
		        swagDialogue.color = 0xFF3F2021;
		        swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		        add(swagDialogue);
			}
		else if (PlayState.SONG.song.toLowerCase() == 'parish' || PlayState.SONG.song.toLowerCase() == 'worship' || PlayState.SONG.song.toLowerCase() == 'zavodila' || PlayState.SONG.song.toLowerCase() == 'gospel' || PlayState.SONG.song.toLowerCase() == 'casanova')
			{
				dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
				dropText.font = 'Komika Display';
				dropText.color = 0xFFA9038C;
				add(dropText);
			
				swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
				swagDialogue.font = 'Komika Display';
				swagDialogue.color = FlxColor.BLACK;
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
				add(swagDialogue);
			   
				dialogue = new Alphabet(0, 80, "", false, true);
				// dialogue.x = 90;
				// add(dialogue);
			}

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.song.toLowerCase() == 'roses')
			portraitLeft.visible = false;
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			portraitLeft.visible = false;
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
		}

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		switch (curCharacter)
		{
			case 'bfPortEnter':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('bf_sound'), 1)];
			case 'bfPortHappy':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('bf_sound'), 0.6)];
			case 'gfPortEnter':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('gf_sound'), 0.6)];
			case 'gfPortHappy':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('gf_sound'), 0.6)];
			case 'sarvHappy':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('sarv_sound'), 12)];
			case 'sarvSad':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('sarv_sound'), 12)];
			case 'sarvSmile':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('sarv_sound'), 12)];
			case 'sarvAngry':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('sarv_sound'), 12)];
			case 'sarvUpset':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('sarv_sound'), 12)];
			case 'ruv':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('ruv_sound'), 12)];
			case 'ruvAngry':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('ruv_sound'), 12)];
			case 'ruvBruh':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('ruv_sound'), 12)];
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (PlayerSettings.player1.controls.ACCEPT && dialogueStarted == true)
		{
			remove(dialogue);
				
			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns')
						FlxG.sound.music.fadeOut(2.2, 0);

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		switch (curCharacter)
		{
			case 'dad':
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			case 'bf':
				portraitLeft.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			case 'sarvHappy':
				portraitRight.visible = false;
				portraitLeft.visible = false;
					if (!sarvHappy.visible)
					{
						sarvHappy.visible = true;
						sarvHappy.animation.play('enter');
					}
		    case 'sarvSad':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!sarvSad.visible)
		 			{
		 				sarvSad.visible = true;
		 				sarvSad.animation.play('enter');
		 			}
		    case 'sarvUpset':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!sarvUpset.visible)
		 			{
		 				sarvUpset.visible = true;
		 				sarvUpset.animation.play('enter');
		 			}
		    case 'sarvAngery':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!sarvAngery.visible)
		 			{
		 				sarvAngery.visible = true;
		 				sarvAngery.animation.play('enter');
		 			}
		    case 'sarvSmile':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!sarvSmile.visible)
		 			{
		 				sarvSmile.visible = true;
		 				sarvSmile.animation.play('enter');
		 			}
		    case 'sarvDevil':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!sarvDevil.visible)
		 			{
		 				sarvDevil.visible = true;
		 				sarvDevil.animation.play('enter');
		 			}
		    case 'ruvNormal':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!ruvNormal.visible)
		 			{
		 				ruvNormal.visible = true;
		 				ruvNormal.animation.play('enter');
		 			}
		    case 'ruvBruh':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!ruvBruh.visible)
		 			{
		 				ruvBruh.visible = true;
		 				ruvBruh.animation.play('enter');
		 			}
		    case 'ruvAngery':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!ruvAngery.visible)
		 			{
		 				ruvAngery.visible = true;
		 				ruvAngery.animation.play('enter');
		 			}
		    case 'bfPortEnter':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!bfPortEnter.visible)
		 			{
		 				bfPortEnter.visible = true;
		 				bfPortEnter.animation.play('enter');
		 			}
		    case 'bfPortHappy':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!bfPortHappy.visible)
		 			{
		 				bfPortHappy.visible = true;
		 				bfPortHappy.animation.play('enter');
		 			}
		    case 'bfPortSad':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!bfPortSad.visible)
		 			{
		 				bfPortSad.visible = true;
		 				bfPortSad.animation.play('enter');
		 			}
		    case 'gfPortEnter':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!gfPortEnter.visible)
		 			{
		 				gfPortEnter.visible = true;
		 				gfPortEnter.animation.play('enter');
		 			}
		    case 'gfPortHappy':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!gfPortHappy.visible)
		 			{
		 				gfPortHappy.visible = true;
		 				gfPortHappy.animation.play('enter');
		 			}
		    case 'selHappy':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!selHappy.visible)
		 			{
		 				selHappy.visible = true;
		 				selHappy.animation.play('enter');
		 			}
		    case 'selSmile':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!selSmile.visible)
		 			{
		 				selSmile.visible = true;
		 				selSmile.animation.play('enter');
		 			}
		    case 'selUpset':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!selUpset.visible)
		 			{
		 				selUpset.visible = true;
		 				selUpset.animation.play('enter');
		 			}
		    case 'selXD':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!selXD.visible)
		 			{
		 				selXD.visible = true;
		 				selXD.animation.play('enter');
		 			}
		    case 'selAngery':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!selAngery.visible)
		 			{
		 				selAngery.visible = true;
		 				selAngery.animation.play('enter');
		 			}
		    case 'rasNormal':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!rasNormal.visible)
		 			{
		 				rasNormal.visible = true;
		 				rasNormal.animation.play('enter');
		 			}
		    case 'rasBruh':
		 		portraitRight.visible = false;
		 		portraitLeft.visible = false;
		 			if (!rasBruh.visible)
		 			{
		 				rasBruh.visible = true;
		 				rasBruh.animation.play('enter');
		 			}
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
