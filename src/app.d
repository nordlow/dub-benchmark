import std;
import std.datetime.stopwatch : StopWatch, AutoStart;

import dub.recipe.packagerecipe;
// import dub.recipe.json : dub_parseJson = parseJson;
// import dub.recipe.sdl : parseSDL;
import dub.recipe.io : parsePackageRecipe;

import std.experimental.allocator.mallocator: Mallocator;
import std.experimental.allocator.showcase: StackFront;

import asdf.jsonparser : asdf_parseJson = parseJson;

import mir.serde; // `serdeOptional` etc

import mir.deser.json: deserializeJson;

struct PackageRecipe {
	@serdeAnnotation @serdeRequired
	string name;
	@serdeAnnotation @serdeOptional
	string license;
}

// auto s = `{"a":[1, 2, 3]}`.deserializeJson!S;

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
					writeln("- Recipe ", e4.name, " of size ", text.length, ":");

					auto sw = StopWatch(AutoStart.yes);

					if (bn == "dub.json") {
						try {
							sw.reset();
							sw.start();
							const json = text.deserializeJson!PackageRecipe;
							writeln("  - Pass: ", sw.peek, ": mir.deser.json.deserializeJson!PackageRecipe()");
						} catch (Exception e) {
							writeln("  - Fail: ", sw.peek, ": mir.deser.json.deserializeJson!PackageRecipe()");
						}

						StackFront!(2048, Mallocator) allocator;
						alias Allocator = typeof(allocator);
						try {
							sw.reset();
							sw.start();
							const json = text.asdf_parseJson(allocator);
							writeln("  - Pass: ", sw.peek, ": asdf.jsonparser.parseJson(", Allocator.stringof, ")");
						} catch (Exception e) {
							writeln("  - Fail:   ", ": asdf.jsonparser.parseJson(", Allocator.stringof, ")");
						}

						try {
							sw.reset();
							sw.start();
							const json = text.asdf_parseJson;
							writeln("  - Pass: ", sw.peek, ": asdf.jsonparser.parseJson()");
						} catch (Exception e) {
							writeln("  - Fail: ", sw.peek, ": asdf.jsonparser.parseJson()");
						}

						try
						{
							sw.reset();
							sw.start();
							const json = text.parseJSON;
							writeln("  - Pass: ", sw.peek, ": std.json.parseJSON()");
						} catch (Exception e) {
							writeln("  - Fail: ", sw.peek, ": std.json.parseJSON()");
						}
					}

					try {
						sw.reset();
						sw.start();
						auto pr =  parsePackageRecipe(text, e4.name);
						const span = sw.peek;
						writeln("  - Pass: ", sw.peek, ": parsePackageRecipe()");
					} catch (Exception _) {
						writeln("  - Fail: ", sw.peek, ": parsePackageRecipe()");
					}

					writeln();
				}
			}
		}
	}
}
