import std;
import std.datetime.stopwatch : StopWatch, AutoStart;

import dub.recipe.packagerecipe;
// import dub.recipe.json : dub_parseJson = parseJson;
// import dub.recipe.sdl : parseSDL;
import dub.recipe.io : parsePackageRecipe;
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

					auto sw = StopWatch(AutoStart.yes);

					if (bn == "dub.json") {
						try {
							sw.reset();
							sw.start();
							const json = text.asdf_parseJson;
							writeln("arsd.jsonparser.parseJson ", e4.name, " succeeded after ", sw.peek);
						} catch (Exception e) {
							writeln("arsd.jsonparser.parseJson ", e4.name, " failed");
						}
						try
						{
							sw.reset();
							sw.start();
							const json = text.parseJSON;
							writeln("std.json.parseJSON ", e4.name, " succeeded after ", sw.peek);
						} catch (Exception e) {
							writeln("std.json.parseJSON ", e4.name, " failed");
						}
					}

					try {
						sw.reset();
						sw.start();
						auto pr =  parsePackageRecipe(text, e4.name);
						const span = sw.peek;
						writeln("parsePackageRecipe ", e4.name, " succeeded after ", span);
					} catch (Exception _) {
						writeln("parsePackageRecipe ", e4.name, " failed");
					}

					writeln();
				}
			}
		}
	}
}
