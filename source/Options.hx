package;

import lime.app.Application;
import lime.system.DisplayMode;
import flixel.util.FlxColor;
import Controls.KeyboardScheme;
import flixel.FlxG;
import openfl.display.FPS;
import openfl.Lib;

class OptionCategory
{
	private var _options:Array<Option> = new Array<Option>();
	public final function getOptions():Array<Option>
	{
		return _options;
	}

	public final function addOption(opt:Option)
	{
		_options.push(opt);
	}

	
	public final function removeOption(opt:Option)
	{
		_options.remove(opt);
	}

	private var _name:String = "New Category";
	public final function getName() {
		return _name;
	}

	public function new (catName:String, options:Array<Option>)
	{
		_name = catName;
		_options = options;
	}
}

class Option
{
	public function new()
	{
		display = updateDisplay();
	}

	private var description:String = "";
	private var display:String;

	/**
	 * Set this to true if your Option re 
	 * (i think i accidentally cut this off but oh well)
	 */
	private var acceptValues:Bool = false;

	public var acceptType:Bool = false;

	public var waitingType:Bool = false;

	public final function getDisplay():String
	{
		return display;
	}

	public final function getAccept():Bool
	{
		return acceptValues;
	}

	public final function getDescription():String
	{
		return description;
	}

	public function onType(text:String)
	{

	}

	public function getValue():String
	{
		return throw "stub!";
	};
	
	// Returns whether the label is to be updated.
	public function press():Bool
	{
		return throw "stub!";
	}

	private function updateDisplay():String
	{
		return throw "stub!";
	}

	public function left():Bool
	{ 
		return throw "stub!";
	}

	public function right():Bool
	{ 
		return throw "stub!";
	}

}


//  DFJKOption
// 	DownscrollOption
// 	MiddleScrollOption
// 	LaneUnderlayOption
// 	GhostTapOption
// 	Judgement
// 	FPSCapOption
// 	ScrollSpeedOption
//  HealthBarOption
// 	AccuracyDOption
// 	ResetButtonOption
// 	InstantRespawn
// 	OffsetMenu
// 	CustomizeGameplay

//! GAMEPLAY

class DFJKOption extends Option
{
	private var controls:Controls;

	public function new(controls:Controls)
	{
		super();
		this.controls = controls;
	}

	public override function press():Bool
	{
		OptionsMenu.instance.openSubState(new KeyBindMenu());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Key Bindings";
	}
}

class DownscrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return FlxG.save.data.downscroll ? "Downscroll" : "Upscroll";
	}
}

class MiddleScrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.middleScroll = !FlxG.save.data.middleScroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Middle Scroll: " + (FlxG.save.data.middleScroll ? "Enabled" : "Disabled");
	}
}

class LaneUnderlayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	private override function updateDisplay():String
	{
		return "Lane Transparency";
	}

	override function right():Bool
	{
		FlxG.save.data.laneTransparency += 0.1;

		if (FlxG.save.data.laneTransparency > 1)
			FlxG.save.data.laneTransparency = 1;
		return true;
	}

	override function left():Bool
	{
		FlxG.save.data.laneTransparency -= 0.1;

		if (FlxG.save.data.laneTransparency < 0)
			FlxG.save.data.laneTransparency = 0;

		if (FlxG.save.data.laneTransparency == 0)
			FlxG.save.data.laneUnderlay = false;
		else
			FlxG.save.data.laneUnderlay = true;

		return true;
	}

	override function getValue():String
	{
		return "Lane Transparency: " + HelperFunctions.truncateFloat(FlxG.save.data.laneTransparency, 1);
	}
}

class GhostTapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.ghost = !FlxG.save.data.ghost;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return FlxG.save.data.ghost ? "Ghost Tapping" : "No Ghost Tapping";
	}
}

class Judgement extends Option
{
	

	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}
	
	public override function press():Bool
	{
		return true;
	}

	private override function updateDisplay():String
	{
		return "Safe Frames";
	}

	override function left():Bool {

		if (Conductor.safeFrames == 1)
			return false;

		Conductor.safeFrames -= 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		return false;
	}

	override function getValue():String {
		return "Safe Frames: " + Conductor.safeFrames +
		" - SIK: " + HelperFunctions.truncateFloat(45 * Conductor.timeScale, 0) +
		"ms GD: " + HelperFunctions.truncateFloat(90 * Conductor.timeScale, 0) +
		"ms BD: " + HelperFunctions.truncateFloat(135 * Conductor.timeScale, 0) + 
		"ms SHT: " + HelperFunctions.truncateFloat(166 * Conductor.timeScale, 0) +
		"ms TOTAL: " + HelperFunctions.truncateFloat(Conductor.safeZoneOffset,0) + "ms";
	}

	override function right():Bool {

		if (Conductor.safeFrames == 20)
			return false;

		Conductor.safeFrames += 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		return true;
	}
}

class FPSCapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "FPS Cap";
	}
	
	override function right():Bool {
		if (FlxG.save.data.fpsCap >= 290)
		{
			FlxG.save.data.fpsCap = 290;
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
		}
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap + 10;
		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		return true;
	}

	override function left():Bool {
		if (FlxG.save.data.fpsCap > 290)
			FlxG.save.data.fpsCap = 290;
		else if (FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = Application.current.window.displayMode.refreshRate;
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap - 10;
		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		return true;
	}

	override function getValue():String
	{
		return "Current FPS Cap: " + FlxG.save.data.fpsCap + 
		(FlxG.save.data.fpsCap == Application.current.window.displayMode.refreshRate ? "Hz (Refresh Rate)" : "");
	}
}

class ScrollSpeedOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "Scroll Speed";
	}

	override function right():Bool {
		FlxG.save.data.scrollSpeed += 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;
		return true;
	}

	override function getValue():String {
		return "Current Scroll Speed: " + HelperFunctions.truncateFloat(FlxG.save.data.scrollSpeed,1);
	}

	override function left():Bool {
		FlxG.save.data.scrollSpeed -= 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;

		return true;
	}
}


class HealthBarOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.healthBar = !FlxG.save.data.healthBar;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Health Bar " + (FlxG.save.data.healthBar ? "Enabled" : "Disabled");
	}
}

class AccuracyDOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.accuracyMod = FlxG.save.data.accuracyMod == 1 ? 0 : 1;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Accuracy Mode: " + (FlxG.save.data.accuracyMod == 0 ? "Accurate" : "Complex");
	}
}

class ResetButtonOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.resetButton = !FlxG.save.data.resetButton;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Reset Button " + (!FlxG.save.data.resetButton ? "off" : "on");
	}
}

class InstantRespawn extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.InstantRespawn = !FlxG.save.data.InstantRespawn;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Instant Respawn " + (!FlxG.save.data.InstantRespawn ? "off" : "on");
	}
}

class OffsetMenu extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		trace("switch");
		var poop:String = Highscore.formatSong("Tutorial", 1);

		PlayState.SONG = Song.loadFromJson(poop, "Tutorial");
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 0;
		PlayState.storyWeek = 0;
		PlayState.offsetTesting = true;
		trace('CUR WEEK' + PlayState.storyWeek);
		LoadingState.loadAndSwitchState(new PlayState());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Time your offset";
	}
}

class CustomizeGameplay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		trace("switch");
		FlxG.switchState(new GameplayCustomizeState());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Customize Gameplay";
	}
}

// DistractionsAndEffectsOption
// CamZoomOption
// StepManiaOption
// AccuracyOption
// ScoreText
// SongPositionOption
// NPSDisplayOption
// RainbowFPSOption
// NoteSplashOption
// CpuStrums

//! APPEARANCE

class DistractionsAndEffectsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.distractions = !FlxG.save.data.distractions;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Distractions " + (!FlxG.save.data.distractions ? "off" : "on");
	}
}

class CamZoomOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.camzoom = !FlxG.save.data.camzoom;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Camera Zoom " + (!FlxG.save.data.camzoom ? "off" : "on");
	}
}

class StepManiaOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.stepMania = !FlxG.save.data.stepMania;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Colors by quantization " + (!FlxG.save.data.stepMania ? "off" : "on");
	}
}

class AccuracyOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.accuracyDisplay = !FlxG.save.data.accuracyDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Accuracy " + (!FlxG.save.data.accuracyDisplay ? "off" : "on");
	}
}

class ScoreText extends Option
{
	public function new (desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.showScore = !FlxG.save.data.showScore;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Show Score " + (!FlxG.save.data.showScore ? "off" : "on");
	}
}

class SongPositionOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.songPosition = !FlxG.save.data.songPosition;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Song Position " + (!FlxG.save.data.songPosition ? "off" : "on");
	}
}

class NPSDisplayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.npsDisplay = !FlxG.save.data.npsDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "NPS Display " + (!FlxG.save.data.npsDisplay ? "off" : "on");
	}
}

class PopUpScoreOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.popUpScore = !FlxG.save.data.popUpScore;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Pop Up Score " + (!FlxG.save.data.popUpScore ? "off" : "on");
	}
}

class RainbowFPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.fpsRain = !FlxG.save.data.fpsRain;
		(cast (Lib.current.getChildAt(0), Main)).changeFPSColor(FlxColor.WHITE);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "FPS Rainbow " + (!FlxG.save.data.fpsRain ? "off" : "on");
	}
}

class NoteSplashOption extends Option
{
	public function new(desc:String)
		{
			super();
			description = desc;
		}
	
		public override function press():Bool
		{
			FlxG.save.data.noteSplashOpt = !FlxG.save.data.noteSplashOpt;
			display = updateDisplay();
			return true;
		}
	
		private override function updateDisplay():String
		{
			return "Note Splash " + (FlxG.save.data.noteSplashOpt ? "off" : "on");
		}
}

class CpuStrums extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.cpuStrums = !FlxG.save.data.cpuStrums;
		
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return  FlxG.save.data.cpuStrums ? "Light CPU Strums" : "CPU Strums stay static";
	}

}

// CrossFadeOpt
// ColorToggle
// ColorOptionR
// ColorOptionG
// ColorOptionB
// VelocityOption
// AlphaDecreaseOption
// StartingAlpha

//! CROSSFADE

class CrossFadeOpt extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.crossFadeOpt = !FlxG.save.data.crossFadeOpt;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "CrossFade " + (FlxG.save.data.crossFadeOpt ? "off" : "on");
	}
}

class ColorToggle extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.colorToggle = !FlxG.save.data.colorToggle;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Color Toggle " + (FlxG.save.data.colorToggle ? "off" : "on");
	}
}

class ColorOptionR extends Option
{
	public function new(desc:String) 
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		//change green or som
		return false;
	}
	
	private override function updateDisplay():String
	{
		return "Color Value RED";
	}
	
	override function right():Bool 
	{		
		if (FlxG.save.data.colorR >= 255)
			FlxG.save.data.colorR = 255;
		
		FlxG.save.data.colorR = FlxG.save.data.colorR + 1;

		return true;
	}

	override function left():Bool 
	{
		if (FlxG.save.data.colorR <= 0)
			FlxG.save.data.colorR = 0;
		
		FlxG.save.data.colorR = FlxG.save.data.colorR - 1;

		return true;
	}

	override function getValue():String
	{
		return "Color Value RED: " + Std.int(FlxG.save.data.colorR);
	}
}

class ColorOptionG extends Option
{
	public function new(desc:String) 
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		//change green or som
		return false;
	}
	
	private override function updateDisplay():String
	{
		return "Color Value GREEN";
	}
	
	override function right():Bool 
		{		
			if (FlxG.save.data.colorG >= 255)
				FlxG.save.data.colorG = 255;
			
			FlxG.save.data.colorG = FlxG.save.data.colorG + 1;
	
			return true;
		}
	
		override function left():Bool 
		{
			if (FlxG.save.data.colorG <= 0)
				FlxG.save.data.colorG = 0;
			
			FlxG.save.data.colorG = FlxG.save.data.colorG - 1;
	
			return true;
		}

	override function getValue():String
	{
		return "Color Value GREEN: " + Std.int(FlxG.save.data.colorG);
	}
}

class ColorOptionB extends Option
{
	public function new(desc:String) 
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		//change green or som
		return false;
	}
	
	private override function updateDisplay():String
	{
		return "Color Value BLUE";
	}
	
	override function right():Bool 
	{		
		if (FlxG.save.data.colorB >= 255)
			FlxG.save.data.colorB = 255;
		
		FlxG.save.data.colorB = FlxG.save.data.colorB + 1;

		return true;
	}

	override function left():Bool 
	{
		if (FlxG.save.data.colorB <= 0)
			FlxG.save.data.colorB = 0;
		
		FlxG.save.data.colorB = FlxG.save.data.colorB - 1;

		return true;
	}

	override function getValue():String
	{
		return "Color Value BLUE: " + Std.int(FlxG.save.data.colorB);
	}
}

class VelocityOption extends Option
{
	public function new(desc:String) 
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}
	
	private override function updateDisplay():String
	{
		return "Speed";
	}
	
	override function right():Bool 
	{
		if (FlxG.save.data.velo >= 50)
			FlxG.save.data.velo = 50;
		
		FlxG.save.data.velo = FlxG.save.data.velo + 1;

		return true;
	}

	override function left():Bool 
	{
		if (FlxG.save.data.velo < 0)
			FlxG.save.data.velo = 0;
		
		FlxG.save.data.velo = FlxG.save.data.velo - 1;

		return true;
	}

	override function getValue():String
	{
		return "Speed: " + Std.int(FlxG.save.data.velo);
	}
}

class TimeAlpha extends Option
{
	public function new(desc:String) 
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}
	
	private override function updateDisplay():String
	{
		return "Transparency Time";
	}
	
	override function right():Bool 
	{
		if (FlxG.save.data.timeA >= 1)
			FlxG.save.data.timeA = 1;
		
		FlxG.save.data.timeA = FlxG.save.data.timeA + 0.01;

		return true;
	}

	override function left():Bool 
	{	
		if (FlxG.save.data.timeA < 0.01)
			FlxG.save.data.timeA = 0.01;
		
		FlxG.save.data.timeA = FlxG.save.data.timeA - 0.01;

		return true;
    }

	override function getValue():String
	{
		return "Time for transparency to reach 0: " + Std.parseFloat(FlxG.save.data.timeA);
	}
}

class StartingAlpha extends Option
{
	var holdShift:Bool = FlxG.keys.pressed.SHIFT;
	public function new(desc:String) 
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}
	
	private override function updateDisplay():String
	{
		return "Starting Transparency";
	}
	
	override function right():Bool 
	{
		if (FlxG.save.data.alphaS >= 1)
			FlxG.save.data.alphaS = 1;

		FlxG.save.data.alphaS += 0.1;

		return true;
	}

	override function left():Bool 
	{
		if (FlxG.save.data.alphaS < 0.1)
			FlxG.save.data.alphaS = 0.1;
		
		FlxG.save.data.alphaS -= 0.1;

		return true;
    }

	override function getValue():String
	{
		return "Starting Alpha: " + Std.parseFloat(FlxG.save.data.alphaS);
	}
}

// FPSOption
// FlashingLightsOption
// AntialiasingOption
// MissSoundsOption
// ScoreScreen
// ShowInput
// Optimization
// BotPlay

//! MISC

class FPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.fps = !FlxG.save.data.fps;
		(cast (Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "FPS Counter " + (!FlxG.save.data.fps ? "off" : "on");
	}
}

class FlashingLightsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.flashing = !FlxG.save.data.flashing;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Flashing Lights " + (!FlxG.save.data.flashing ? "off" : "on");
	}
}

class AntialiasingOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.antialiasing = !FlxG.save.data.antialiasing;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Antialiasing " + (!FlxG.save.data.antialiasing ? "off" : "on");
	}
}

class MissSoundsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.missSounds = !FlxG.save.data.missSounds;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Miss Sounds " + (!FlxG.save.data.missSounds ? "off" : "on");
	}
}

class ScoreScreen extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.scoreScreen = !FlxG.save.data.scoreScreen;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.scoreScreen ? "Show Score Screen" : "No Score Screen");
	}
}

class ShowInput extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		FlxG.save.data.inputShow = !FlxG.save.data.inputShow;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.inputShow ? "Extended Score Info" : "Minimalized Info");
	}
}

class Optimization extends Option
{
	public function new(desc:String)
		{
			super();
			description = desc;
		}
	
		public override function press():Bool
		{
			FlxG.save.data.optimize = !FlxG.save.data.optimize;
			display = updateDisplay();
			return true;
		}
	
		private override function updateDisplay():String
		{
			return "Optimization " + (FlxG.save.data.optimize ? "ON" : "OFF");
		}
}

class BotPlay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press():Bool
	{
		FlxG.save.data.botplay = !FlxG.save.data.botplay;
		trace('BotPlay : ' + FlxG.save.data.botplay);
		display = updateDisplay();
		return true;
	}
	
	private override function updateDisplay():String
		return "BotPlay " + (FlxG.save.data.botplay ? "on" : "off");
}

// ReplayOption
// ResetScoreOption
// LockWeeksOption
// ResetSettings

//! SAVES AND DATA

class ReplayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	public override function press():Bool
	{
		trace("switch");
		FlxG.switchState(new LoadReplayState());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Load replays";
	}
}

class ResetScoreOption extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		if(!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}
		FlxG.save.data.songScores = null;
		for(key in Highscore.songScores.keys())
		{
			Highscore.songScores[key] = 0;
		}
		FlxG.save.data.songCombos = null;
		for(key in Highscore.songCombos.keys())
		{
			Highscore.songCombos[key] = '';
		}
		confirm = false;
		trace('Highscores Wiped');
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? "Confirm Score Reset" : "Reset Score";
	}
}

class LockWeeksOption extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		if(!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}
		FlxG.save.data.weekUnlocked = 1;
		StoryMenuState.weekUnlocked = [true, true];
		confirm = false;
		trace('Weeks Locked');
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? "Confirm Story Reset" : "Reset Story Progress";
	}
}

class ResetSettings extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		description = desc;
	}
	public override function press():Bool
	{
		if(!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}
		FlxG.save.data.weekUnlocked = null;
		FlxG.save.data.newInput = null;
		FlxG.save.data.downscroll = null;
		FlxG.save.data.antialiasing = null;
		FlxG.save.data.missSounds = null;
		FlxG.save.data.dfjk = null;
		FlxG.save.data.accuracyDisplay = null;
		FlxG.save.data.offset = null;
		FlxG.save.data.songPosition = null;
		FlxG.save.data.fps = null;
		FlxG.save.data.changedHit = null;
		FlxG.save.data.fpsRain = null;
		FlxG.save.data.fpsCap = null;
		FlxG.save.data.scrollSpeed = null;
		FlxG.save.data.npsDisplay = null;
		FlxG.save.data.frames = null;
		FlxG.save.data.accuracyMod = null;
		FlxG.save.data.watermark = null;
		FlxG.save.data.ghost = null;
		FlxG.save.data.distractions = null;
		FlxG.save.data.stepMania = null;
		FlxG.save.data.flashing = null;
		FlxG.save.data.resetButton = null;
		FlxG.save.data.botplay = null;
		FlxG.save.data.noteSplashOpt = null;
		FlxG.save.data.cpuStrums = null;
		FlxG.save.data.strumline = null;
		FlxG.save.data.customStrumLine = null;
		FlxG.save.data.camzoom = null;
		FlxG.save.data.scoreScreen = null;
		FlxG.save.data.inputShow = null;
		FlxG.save.data.optimize = null;
		FlxG.save.data.cacheImages = null;
		FlxG.save.data.editor = null;

		Data.initSave();
		confirm = false;
		trace('All settings have been reset');
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? "Confirm Settings Reset" : "Reset Settings";
	}
}