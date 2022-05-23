package;

import flixel.FlxG;
import flixel.util.FlxStringUtil;
import lime.utils.Assets;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['Easy', "Normal", "Hard", "Alt"];

	public static function difficultyFromInt(difficulty:Int):String
	{
		return difficultyArray[difficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	
	public static function coolStringFile(path:String):Array<String>
	{
		var daList:Array<String> = path.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function camLerpShit(ratio:Float):Float
	{
		return FlxG.elapsed / 0.016666666666666666 * ratio;
	}

	public static function coolLerp(a:Float, b:Int, ratio:Float):Float
	{
		return a + camLerpShit(ratio) * (b - a);
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
}
