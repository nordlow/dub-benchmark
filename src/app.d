import std;
import std.datetime.stopwatch : StopWatch, AutoStart;

import dub.recipe.packagerecipe;
// import dub.recipe.json : dub_parseJson = parseJson;
// import dub.recipe.sdl : parseSDL;
import dub.recipe.io : parsePackageRecipe;

import std.experimental.allocator.mallocator: Mallocator;
import std.experimental.allocator.showcase: StackFront;
import asdf.jsonparser : asdf_parseJson = parseJson;

void main() {
	const sm = SpanMode.shallow;
	foreach (e1; dirEntries("~/.dub/packages/".expandTilde, sm)) {
		if (!e1.isDir)
			continue;
		foreach (e2; dirEntries(e1.name, sm)) {
			if (!e2.isDir)
				continue;
			foreach (e3; dirEntries(e2.name, sm)) {
				if (!e3.isDir)
					continue;
				foreach (e4; dirEntries(e3.name, sm)) {
					if (e4.isDir)
						continue;

					const bn = e4.name.baseName;

					if (!bn.among("dub.json", "dub.sdl"))
						continue;

					const text = cast(string)e4.name.read();
					writeln("text.length: ", text.length);

					auto sw = StopWatch(AutoStart.yes);

					if (bn == "dub.json") {
						StackFront!(2048, Mallocator) allocator;
						try {
							sw.reset();
							sw.start();
							const json = text.asdf_parseJson(allocator);
							writeln("Pass: ", sw.peek, ": asdf.jsonparser.parseJson(", typeof(allocator).stringof, ") ", e4.name);
						} catch (Exception e) {
							writeln("Fail:   ", ": asdf.jsonparser.parseJson(", typeof(allocator).stringof, ") ", e4.name);
						}

						try {
							sw.reset();
							sw.start();
							const json = text.asdf_parseJson;
							writeln("Pass: ", sw.peek, ": asdf.jsonparser.parseJson() ", e4.name);
						} catch (Exception e) {
							writeln("Fail: ", sw.peek, ": asdf.jsonparser.parseJson() ", e4.name);
						}

						try
						{
							sw.reset();
							sw.start();
							const json = text.parseJSON;
							writeln("Pass: ", sw.peek, ": std.json.parseJSON() ", e4.name);
						} catch (Exception e) {
							writeln("Fail: ", sw.peek, ": std.json.parseJSON() ", e4.name);
						}
					}

					try {
						sw.reset();
						sw.start();
						auto pr =  parsePackageRecipe(text, e4.name);
						const span = sw.peek;
						writeln("Pass: ", sw.peek, ": parsePackageRecipe() ", e4.name);
					} catch (Exception _) {
						writeln("Fail: ", sw.peek, ": parsePackageRecipe() ", e4.name);
					}

					writeln();
				}
			}
		}
	}
}
