# Various benchmarks for DUB

This benchmark parses dub recipes (`dub.json` and `dub.sdl`) under
`~/.dub/packages/` using either `std.json`, `asdf.jsonparser`, and
`dub.recipe.io : parsePackageRecipe`.

A single non-JSON-compliant `dub.json` fails to parse (resolved by
https://github.com/rikkimax/ctfepp/pull/3).

Run release build benchmark either as

`dub run --build=release --compiler=ldc2`

or

`DFLAGS='-mattr=+sse4.2' dub -v run --compiler=ldc2 --build=release`

to utilize SSE 4.2 optimizations in asdf.

For debug build run as.

or debug build benchmark as

`dub run --build=debu --compiler=dmd`

.

Sample output: for release build benchmark via

```
dub -q run --build=release --compiler=ldc2
```

is

```
- Recipe /home/per/.dub/packages/dscanner/0.16.0-beta.2/dscanner/dub.json of size 916:
  - Pass: 8 μs and 5 hnsecs: asdf.jsonparser.parseJson(FallbackAllocator!(InSituRegion!(2048LU, 16LU), Mallocator))
  - Pass: 9 μs and 5 hnsecs: asdf.jsonparser.parseJson()
  - Pass: 38 μs and 3 hnsecs: mir.deser.json.deserializeJson!JsonAlgebraic()
  - Pass: 28 μs and 4 hnsecs: std.json.parseJSON()
  - Pass: 334 μs and 4 hnsecs: parsePackageRecipe()

- Recipe /home/per/.dub/packages/dscanner/0.12.0/dscanner/dub.json of size 952:
  - Pass: 4 μs and 2 hnsecs: asdf.jsonparser.parseJson(FallbackAllocator!(InSituRegion!(2048LU, 16LU), Mallocator))
  - Pass: 4 μs and 5 hnsecs: asdf.jsonparser.parseJson()
  - Pass: 17 μs and 9 hnsecs: mir.deser.json.deserializeJson!JsonAlgebraic()
  - Pass: 16 μs and 8 hnsecs: std.json.parseJSON()
  - Pass: 193 μs: parsePackageRecipe()

- Recipe /home/per/.dub/packages/dscanner/0.12.2/dscanner/dub.json of size 935:
  - Pass: 3 μs and 4 hnsecs: asdf.jsonparser.parseJson(FallbackAllocator!(InSituRegion!(2048LU, 16LU), Mallocator))
  - Pass: 4 μs and 1 hnsec: asdf.jsonparser.parseJson()
  - Pass: 15 μs and 5 hnsecs: mir.deser.json.deserializeJson!JsonAlgebraic()
  - Pass: 14 μs and 6 hnsecs: std.json.parseJSON()
  - Pass: 175 μs and 3 hnsecs: parsePackageRecipe()

- Recipe /home/per/.dub/packages/dscanner/0.8.0/dscanner/dub.json of size 983:
  - Pass: 3 μs and 6 hnsecs: asdf.jsonparser.parseJson(FallbackAllocator!(InSituRegion!(2048LU, 16LU), Mallocator))
  - Pass: 4 μs and 1 hnsec: asdf.jsonparser.parseJson()
  - Pass: 19 μs and 7 hnsecs: mir.deser.json.deserializeJson!JsonAlgebraic()
  - Pass: 17 μs and 7 hnsecs: std.json.parseJSON()
  - Pass: 181 μs and 5 hnsecs: parsePackageRecipe()

- Recipe /home/per/.dub/packages/libackis/1.0.4/libackis/dub.json of size 724:
  - Pass: 2 μs: asdf.jsonparser.parseJson(FallbackAllocator!(InSituRegion!(2048LU, 16LU), Mallocator))
  - Pass: 4 μs and 1 hnsec: asdf.jsonparser.parseJson()
  - Pass: 14 μs and 6 hnsecs: mir.deser.json.deserializeJson!JsonAlgebraic()
  - Pass: 12 μs: std.json.parseJSON()
  - Pass: 133 μs and 5 hnsecs: parsePackageRecipe()

- Recipe /home/per/.dub/packages/odbc/1.0.0/odbc/dub.json of size 608:
  - Pass: 1 μs and 5 hnsecs: asdf.jsonparser.parseJson(FallbackAllocator!(InSituRegion!(2048LU, 16LU), Mallocator))
  - Pass: 2 μs and 9 hnsecs: asdf.jsonparser.parseJson()
  - Pass: 12 μs and 7 hnsecs: mir.deser.json.deserializeJson!JsonAlgebraic()
  - Pass: 10 μs and 4 hnsecs: std.json.parseJSON()
  - Pass: 126 μs and 1 hnsec: parsePackageRecipe()

- Recipe /home/per/.dub/packages/dmech/0.4.1/dmech/dub.json of size 469:
  - Pass: 1 μs and 4 hnsecs: asdf.jsonparser.parseJson(FallbackAllocator!(InSituRegion!(2048LU, 16LU), Mallocator))
  - Pass: 2 μs and 5 hnsecs: asdf.jsonparser.parseJson()
  - Pass: 8 μs and 8 hnsecs: mir.deser.json.deserializeJson!JsonAlgebraic()
  - Pass: 12 μs and 2 hnsecs: std.json.parseJSON()
  - Pass: 106 μs and 9 hnsecs: parsePackageRecipe()

- Recipe /home/per/.dub/packages/smimeasym/3.3.0/smimeasym/dub.json of size 593:
  - Pass: 1 μs and 9 hnsecs: asdf.jsonparser.parseJson(FallbackAllocator!(InSituRegion!(2048LU, 16LU), Mallocator))
  - Pass: 2 μs and 3 hnsecs: asdf.jsonparser.parseJson()
  - Pass: 9 μs and 5 hnsecs: mir.deser.json.deserializeJson!JsonAlgebraic()
  - Pass: 7 μs and 9 hnsecs: std.json.parseJSON()
  - Pass: 113 μs and 4 hnsecs: parsePackageRecipe()

- Recipe /home/per/.dub/packages/derelict-cf/0.0.1/derelict-cf/dub.json of size 515:
  - Pass: 8 hnsecs: asdf.jsonparser.parseJson(FallbackAllocator!(InSituRegion!(2048LU, 16LU), Mallocator))
  - Pass: 1 μs and 8 hnsecs: asdf.jsonparser.parseJson()
  - Pass: 7 μs and 3 hnsecs: mir.deser.json.deserializeJson!JsonAlgebraic()
  - Pass: 6 μs and 9 hnsecs: std.json.parseJSON()
  - Pass: 81 μs: parsePackageRecipe()
```

.
