package scripting;

import tjson.TJSON;
import hscript.Expr;
import hscript.Parser;
import hscript.Interp;
import flixel.FlxBasic;
import sys.thread.Thread;
import openfl.utils.Assets;
import lime.app.Application;
import scripting.HScriptClasses;
import flixel.graphics.tile.FlxGraphicsShader;

using StringTools;

/**
    Handles hscript shit for u lmfao
**/
class HScriptHandler
{
    public var script:String;

    public var program:Expr;

    public var parser:Parser = new Parser();
    public var interp:Interp = new Interp();

    public var other_scripts:Array<HScriptHandler> = [];

    public var createPost:Bool = false;

    public function new(hscript_path: String)
    {
        program = parser.parseString(Assets.getText(hscript_path));

		parser.allowTypes = parser.allowJSON = parser.allowMetadata = true;
		interp.allowPublicVariables = interp.allowStaticVariables = true;

        setDefaultVariables();

        interp.execute(program);
    }

    public function start()
    {
        callFunction("create");
    }

    public function update(elapsed:Float)
    {
        callFunction("update", [elapsed]);
    }

    public function callFunction(func:String, ?args:Array<Dynamic>)
    {
        if(interp.variables.exists(func))
        {
            var real_func = interp.variables.get(func);

            try {
                if(args == null)
                    real_func();
                else
                    Reflect.callMethod(null, real_func, args);
            } catch(e) {
                trace(e.details());
                trace("ERROR Caused in " + func + " with " + Std.string(args) + " args");
            }
        }

        for(other_script in other_scripts)
        {
            other_script.callFunction(func, args);
        }
    }

    public function setDefaultVariables()
    {
        interp.variables.set("FlxColor", HScriptClasses.get_FlxColor());
        interp.variables.set("FlxKey", HScriptClasses.get_FlxKey());
        interp.variables.set("FlxG", flixel.FlxG);
        interp.variables.set("Polymod", polymod.Polymod);
        interp.variables.set("Assets", openfl.utils.Assets);
        interp.variables.set("LimeAssets", lime.utils.Assets);
        interp.variables.set("FlxSprite", flixel.FlxSprite);
        interp.variables.set("Math", Math);
        interp.variables.set("FlxSprite", flixel.FlxSprite);
        interp.variables.set("FlxMath", flixel.math.FlxMath);
        interp.variables.set("Std", Std);
        interp.variables.set("StringTools", StringTools);

        interp.variables.set("HScriptClasses", HScriptClasses);
        interp.variables.set("HScriptHandler", this);
        interp.variables.set("Reflect", Reflect);
	    interp.variables.set("Array", Array);
        interp.variables.set("Float", Float);
        interp.variables.set("Int", Int);
        interp.variables.set("Bool", Bool);
        interp.variables.set("String", String);
        interp.variables.set("Dynamic", Dynamic);

	    interp.variables.set("FlxBackdrop", flixel.addons.display.FlxBackdrop);

        interp.variables.set("Window", Application.current.window);
        interp.variables.set("Application", Application);

        interp.variables.set("PlayState", PlayState);
        interp.variables.set("Conductor", Conductor);
        interp.variables.set("BGSprite", BGSprite);
        interp.variables.set("Paths", Paths);
        interp.variables.set("CoolUtil", CoolUtil);
        interp.variables.set("DancingSprite", DancingSprite);

        interp.variables.set("Json", {
            "parse": function(data:String) {return TJSON.parse(data);},
            "stringify": function(data:Dynamic, thing:String = "\t") {return TJSON.encode(data, thing == "\t" ? "fancy" : null);}
        });

        interp.variables.set("loadScript", function(script_path:String) {
            var new_script = new HScriptHandler(script_path);
            new_script.start();
            
            if(createPost)
                new_script.callFunction("createPost");

            other_scripts.push(new_script);

            return other_scripts.length - 1;
        });

        interp.variables.set("unloadScript", function(script_index:Int) {
            if(other_scripts.length - 1 >= script_index)
                other_scripts.remove(other_scripts[script_index]);
        });

        interp.variables.set("otherScripts", other_scripts);

        interp.variables.set("add", PlayState.instance.add);
        interp.variables.set("remove", PlayState.instance.remove);

        interp.variables.set("camPos", PlayState.instance.camPos);

        interp.variables.set("bf", PlayState.instance.boyfriend);
        interp.variables.set("gf", PlayState.instance.gf);
        interp.variables.set("dad", PlayState.instance.dad);

        interp.variables.set("removeStage", function() {
            PlayState.instance.remove(PlayState.instance.bg);
            PlayState.instance.remove(PlayState.instance.stageFront);
            PlayState.instance.remove(PlayState.instance.stageCurtains);
        });

		interp.variables.set("createThread", function(func:Void -> Void)
        {
            #if (target.threaded)
            Thread.create(() -> {
                func();
            });
            #else
            func();
            #end
        });
    }
}