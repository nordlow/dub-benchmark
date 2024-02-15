import std;
import std.datetime.stopwatch : StopWatch, AutoStart;

// import dub.recipe.packagerecipe;
// import dub.recipe.json : dub_parseJson = parseJson;
// import dub.recipe.sdl : parseSDL;
import dub.recipe.io : parsePackageRecipe;

import std.experimental.allocator.mallocator: Mallocator;
import std.experimental.allocator.showcase: StackFront;

import asdf.jsonparser : asdf_parseJson = parseJson;

import mir.serde; // `serdeOptional` etc

import mir.deser.json: deserializeJson;
import mir.algebraic_alias.json : JsonAlgebraic;

alias Name = serdeKeys;

@serdeIgnoreUnexpectedKeys
struct PackageRecipe {
	/**
	 * Name of the package, used to uniquely identify the package.
	 *
	 * This field is the only mandatory one.
	 * Must be comprised of only lower case ASCII alpha-numeric characters,
	 * "-" or "_".
	 */
	string name;

	/// Brief description of the package.
	@serdeOptional string description;

	/// URL of the project website
	@serdeOptional string homepage;

	/**
	 * List of project authors
	 *
	 * the suggested format is either:
	 * "Peter Parker"
	 * or
	 * "Peter Parker <pparker@example.com>"
	 */
	@serdeOptional string[] authors;

	/// Copyright declaration string
	@serdeOptional string copyright;

	/// License(s) under which the project can be used
	@serdeOptional string license;

	/// Set of version requirements for DUB, compilers and/or language frontend.
	version (none) @serdeOptional ToolchainRequirements toolchainRequirements;

	/**
	 * Specifies an optional list of build configurations
	 *
	 * By default, the first configuration present in the package recipe
	 * will be used, except for special configurations (e.g. "unittest").
	 * A specific configuration can be chosen from the command line using
	 * `--config=name` or `-c name`. A package can select a specific
	 * configuration in one of its dependency by using the `subConfigurations`
	 * build setting.
	 * Build settings defined at the top level affect all configurations.
	 */
	version (none) @serdeOptional @serdeKeys("name") ConfigurationInfo[] configurations;

	/**
	 * Defines additional custom build types or overrides the default ones
	 *
	 * Build types can be selected from the command line using `--build=name`
	 * or `-b name`. The default build type is `debug`.
	 */
	version (none) @serdeOptional BuildSettingsTemplate[string] buildTypes;

	/**
	 * Build settings influence the command line arguments and options passed
	 * to the compiler and linker.
	 *
	 * All build settings can be present at the top level, and are optional.
	 * Build settings can also be found in `configurations`.
	 */
	version (none) @serdeOptional BuildSettingsTemplate buildSettings;
	version (none) alias buildSettings this;

	/**
	 * Specifies a list of command line flags usable for controlling
	 * filter behavior for `--build=ddox` [experimental]
	 */
	@serdeOptional @Name("-ddoxFilterArgs") string[] ddoxFilterArgs;

	/// Specify which tool to use with `--build=ddox` (experimental)
	@serdeOptional @Name("-ddoxTool") string ddoxTool;

	/**
	 * Sub-packages path or definitions
	 *
	 * Sub-packages allow to break component of a large framework into smaller
	 * packages. In the recipe file, sub-packages entry can take one of two forms:
	 * either the path to a sub-folder where a recipe file exists,
	 * or an object of the same format as a recipe file (or `PackageRecipe`).
	 */
	version (none) @serdeOptional SubPackage[] subPackages;

	/// Usually unused by users, this is set by dub automatically
	@serdeOptional @Name("version") string version_;

	version (none)
	inout(ConfigurationInfo) getConfiguration(string name)
	inout {
		foreach (c; configurations)
			if (c.name == name)
				return c;
		throw new Exception("Unknown configuration: "~name);
	}

	/** Clones the package recipe recursively.
	 */
	version (none)
	PackageRecipe clone() const { return .clone(this); }
}

/// Bundles information about a build configuration.
version (none)
struct ConfigurationInfo {
	string name;
	@serdeOptional string[] platforms;
	@serdeOptional BuildSettingsTemplate buildSettings;
	alias buildSettings this;

	/**
	 * Equivalent to the default constructor, used by Configy
	 */
	this(string name, string[] p, BuildSettingsTemplate build_settings)
		@safe pure nothrow @nogc
	{
		this.name = name;
		this.platforms = p;
		this.buildSettings = build_settings;
	}

	this(string name, BuildSettingsTemplate build_settings)
	{
		enforce(!name.empty, "Configuration name is empty.");
		this.name = name;
		this.buildSettings = build_settings;
	}

	bool matchesPlatform(in BuildPlatform platform)
	const {
		if( platforms.empty ) return true;
		foreach(p; platforms)
			if (platform.matchesSpecification(p))
				return true;
		return false;
	}
}

/++ DUB Package Name.
 +/
struct PackageName {
	string value;
	alias value this;
}

static immutable url = "https://code.dlang.org/packages/index.json";

/++ Get all DUB package names registered on code.dlang.org.
 +/
auto getPackageNames() @trusted {
	import std.algorithm : map;
	import std.json : parseJSON;
	import std.net.curl : get;
	return url.get.parseJSON.array.map!(a => PackageName(a.str));
}

/++ Duration statistics.
 +/
@safe struct DurationStat {
	Duration _min = Duration.max;
	Duration _max = Duration.min;;
	Duration _sum;
	void add(in Duration dur) pure nothrow @nogc {
		_min = min(_min, dur);
		_min = max(_min, dur);
		_sum += dur;
	}
}

alias DurationStats = DurationStat[PackageName];

void add(DurationStats stats, PackageName pn, in Duration dur) {
	if (auto ds = pn in stats) {
		ds.add(dur);
	} else {
		DurationStat stat;
		stat.add(dur);
		stats[pn] = stat;
	}
}

void prettyPrint(in DurationStats stats) {
	foreach (const ref kv; stats.byKeyValue) {
		writeln(kv.key, kv.value);
	}
}

void main() {
	const bool checkName = false;
	const names = checkName ? getPackageNames.array : [];
	const sm = SpanMode.shallow;

	DurationStats stats_parsePackageRecipe;

	foreach (e1; dirEntries("~/.dub/packages/".expandTilde, sm)) {
		if (!e1.isDir)
			continue;
		const packageName = PackageName(e1.name.baseName);
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

						try {
							sw.reset();
							sw.start();
							const ja = text.deserializeJson!JsonAlgebraic;
							writeln("  - Pass: ", sw.peek, ": mir.deser.json.deserializeJson!JsonAlgebraic()");
						} catch (Exception e) {
							writeln("  - Fail: ", sw.peek, ": mir.deser.json.deserializeJson!JsonAlgebraic()");
						}

						try {
							sw.reset();
							sw.start();
							const pr = text.deserializeJson!PackageRecipe;
							writeln("  - Pass: ", sw.peek, ": mir.deser.json.deserializeJson!PackageRecipe()");
						} catch (Exception e) {
							writeln("  - Fail: ", sw.peek, ": mir.deser.json.deserializeJson!PackageRecipe() with exception:\n", e.toString);
						}

						try
						{
							sw.reset();
							sw.start();
							const json = text.parseJSON;
							writeln("  - Pass: ", sw.peek, ": std.json.parseJSON()");
							if (checkName) {
								const name = json.object["name"].str;
								if (!names.canFind(name)) {
									writeln("Warning: Name ", name, " not found in ", url);
								}
							}
						} catch (Exception e) {
							writeln("  - Fail: ", sw.peek, ": std.json.parseJSON()");
						}
					}

					try {
						sw.reset();
						sw.start();
						auto pr =  parsePackageRecipe(text, e4.name);
						const dur = sw.peek;
						stats_parsePackageRecipe.add(packageName, dur);
						writeln("  - Pass: ", dur, ": parsePackageRecipe()");
					} catch (Exception _) {
						writeln("  - Fail: ", sw.peek, ": parsePackageRecipe()");
					}

					writeln();
				}
			}
		}
	}

	stats_parsePackageRecipe.prettyPrint();
}
