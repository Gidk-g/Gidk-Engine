package;

import Song;
import Week;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.utils.Assets;

typedef SongMetaData =
{
	var name:String;
	var week:Int;
	var character:String;
	var color:Int;
}

class FreeplayState extends MusicBeatState
{
	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;
	private var iconArray:Array<HealthIcon> = [];
	private var songs:Array<SongMetaData> = [];
	private var curSelected:Int = 0;
	private var curDifficulty:Int = 1;
	private var scoreText:FlxText;
	private var diffText:FlxText;

	private var lerpScore:Float = 0;
	private var intendedScore:Float = 0;

	private var bg:FlxSprite;
	private var scoreBG:FlxSprite;

	override function create()
	{
		Week.loadJsons(false);

		for (i in 0...Week.weeksList.length)
		{
			if (!weekIsLocked(Week.weeksList[i]))
			{
				for (song in Week.currentLoadedWeeks.get(Week.weeksList[i]).songs)
				{
					var colors:Array<Int> = song.colors;
					if (colors == null || colors.length < 3)
						colors = [146, 113, 253];

					songs.push({
						name: song.name,
						week: i,
						character: song.character,
						color: FlxColor.fromRGB(colors[0], colors[1], colors[2])
					});
				}
			}
		}

		#if FUTURE_DISCORD_RCP
		// Updating Discord Rich Presence
		DiscordClient.changePresence('In the Freeplay Menu', null);
		#end

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);

		persistentUpdate = true;

		bg = new FlxSprite(0, 0).loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].name, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			if (songText.width > 980)
			{
				var textScale:Float = 980 / songText.width;
				songText.scale.x = textScale;
				for (letter in songText.lettersArray)
				{
					letter.x *= textScale;
					letter.offset.x *= textScale;
				}
			}

			var icon:HealthIcon = new HealthIcon(songs[i].character);
			icon.sprTracker = songText;
			iconArray.push(icon);
			add(icon);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		#if mobile
		addVirtualPad(LEFT_FULL, A_B_C);
		#end

		super.create();
	}

	private function weekIsLocked(name:String):Bool
	{
		var daWeek:SwagWeek = Week.currentLoadedWeeks.get(name);
		return (daWeek.locked
			&& daWeek.unlockAfter.length > 0
			&& (!StoryMenuState.weekCompleted.exists(daWeek.unlockAfter) || !StoryMenuState.weekCompleted.get(daWeek.unlockAfter)));
	}

	var instPlaying:Int = -1;

	public static var vocals:FlxSound = null;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		bg.color = FlxColor.interpolate(bg.color, songs[curSelected].color, CoolUtil.camLerpShit(0.045));

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
			changeDiff();
		}
		else if (controls.UI_DOWN_P)
		{
			changeSelection(1);
			changeDiff();
		}
		else if (FlxG.mouse.wheel != 0)
		{
			changeSelection(-FlxG.mouse.wheel);
			changeDiff();
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (FlxG.keys.justPressed.SPACE)
		{
			#if PRELOAD_ALL
			if (vocals != null) {
				vocals.stop();
				vocals.destroy();
				vocals = null;
			}

			FlxG.sound.music.volume = 0;

			var poop:String = Highscore.formatSong(songs[curSelected].name.toLowerCase(), curDifficulty);
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].name.toLowerCase());

			if (PlayState.SONG.needsVoices)
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			else
				vocals = new FlxSound();

			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);

			FlxG.sound.list.add(vocals);
			FlxG.sound.music.play(true);

			if (vocals != null)
				vocals.play();
			vocals.persist = false;
			vocals.looped = true;

			instPlaying = curSelected;

			Conductor.changeBPM(PlayState.SONG.bpm);
			Conductor.mapBPMChanges(PlayState.SONG);
			#end
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].name.toLowerCase(), curDifficulty);
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].name.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.storyWeek = songs[curSelected].week;

			if (FlxG.keys.pressed.SHIFT){
				FlxG.switchState(new ChartingState());
			}else{
				LoadingState.loadAndSwitchState(new PlayState());
			}

			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();

			if (vocals != null) {
				vocals.stop();
				vocals.destroy();
				vocals = null;
			}
		}
		else if (controls.BACK)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();

			if (vocals != null) {
				vocals.stop();
				vocals.destroy();
				vocals = null;
			}

			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);

			FlxG.switchState(new MainMenuState());
		}

		for (icon in iconArray)
			icon.scale.set(FlxMath.lerp(icon.scale.x, 1, elapsed * 9), FlxMath.lerp(icon.scale.y, 1, elapsed * 9));

		super.update(elapsed);
	}

	override function beatHit():Void {
		super.beatHit();

		if (iconArray[instPlaying] != null)
			iconArray[instPlaying].scale.add(0.2, 0.2);
	}

	private function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyArray.length - 1;
		else if (curDifficulty >= CoolUtil.difficultyArray.length)
			curDifficulty = 0;

		var poop:String = Highscore.formatSong(songs[curSelected].name.toLowerCase(), curDifficulty);
		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].name, curDifficulty);
		#end

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
			case 1:
				diffText.text = 'NORMAL';
			case 2:
				diffText.text = "HARD";
		}
	}

	private function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		else if (curSelected >= songs.length)
			curSelected = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].name, curDifficulty);
		#end

		for (i in 0...iconArray.length)
			iconArray[i].alpha = 0.6;

		iconArray[curSelected].alpha = 1;

		var bullShit:Int = 0;
		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
				item.alpha = 1;
		}
	}
}
