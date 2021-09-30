package;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef AfterImageSection = {
	var startTime:Float;
	var endTime:Float;
	var sectionNotes:Array<Dynamic>;
	var crossFade:Bool;
	var altAnim:Null<Bool>;
	var mustHitSection:Null<Bool>;
	var bpm:Null<Float>;
}

typedef CrossFades = {
	var song:String;
	var notes:Array<AfterImageSection>;
}


class AfterImages {

  public static function parseJSONshit(rawJson:String):CrossFades
	{
		var json = Json.parse(rawJson);
		if(json.crossFade!=null){
			var swagShit:CrossFades = cast json.crossFade;
			return swagShit;
		}
		return null;

	}

  public static function loadFromJson(jsonInput:String, ?folder:String):Null<CrossFades>
  {
    var rawJson = Assets.getText(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase())).trim();

    while (!rawJson.endsWith("}"))
    {
      rawJson = rawJson.substr(0, rawJson.length - 1);
    }

    return parseJSONshit(rawJson);
  }

}
