package;

import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class StaticArrows extends FlxSprite
{
	public var modifiedByLua:Bool = false;
	public var modAngle:Float = 0; // The angle set by modcharts
	public var localAngle:Float = 0; // The angle to be edited inside here

	public function new(x:Float, y:Float)
	{
		this.x = x;
		this.y = y;
		super(this.x, this.y);
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		if (!modifiedByLua)
			angle = localAngle + modAngle;
		else
			angle = modAngle;
		super.update(elapsed);
	}

	public function playAnim(name:String, ?force:Bool = false):Void
	{
		animation.play(name, force);

		if (!name.startsWith('dirCon'))
			localAngle = 0;

		updateHitbox();
		offset.set(frameWidth / 2, frameHeight / 2);

		offset.x -= 54;
		offset.y -= 56;

		angle = localAngle + modAngle;
	}
}