package;

import haxe.Json;
import openfl.utils.Assets;

typedef SwagStoryCharacter =
{
	var animations:Array<SwagStoryAnimation>;
	var antialiasing:Bool;
	var scale:Float;
	var flipX:Bool;
	var flipY:Bool;
}

typedef SwagStoryAnimation =
{
	var animation:String;
	var prefix:String;
	var framerate:Int;
	var looped:Bool;
	var indices:Array<Int>;
	var flipX:Bool;
	var flipY:Bool;
	var offset:Array<Float>;
}

class StoryCharacterData
{
	public static function loadJson(file:String):SwagStoryCharacter
		return parseJson(Paths.json2('images/menucharacters/' + file));

	public static function parseJson(path:String):SwagStoryCharacter
	{
		var rawJson:String = '';

		if (Assets.exists(path))
			rawJson = Assets.getText(path);

		return Json.parse(rawJson);
	}
}
