# Various benchmarks for DUB

This benchmark parses dub recipes (`dub.json` and `dub.sdl`) under
`~/.dub/packages/` using either `std.json`, `asdf.jsonparser`, and
`dub.recipe.io : parsePackageRecipe`.

Run release build benchmark as

`dub run --build=release --compiler=ldc2`

or debug build benchmark as

`dub run --build=debu --compiler=dmd`

.
