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
- Recipe ~/.dub/packages/dscanner/0.16.0-beta.2/dscanner/dub.json of size 916:
  - Pass: 10 μs and 8 hnsecs: asdf.jsonparser.parseJson(FallbackAllocator!(InSituRegion!(2048LU, 16LU), Mallocator))
  - Pass: 20 μs and 9 hnsecs: asdf.jsonparser.parseJson()
  - Pass: 43 μs and 3 hnsecs: std.json.parseJSON()
  - Pass: 341 μs: parsePackageRecipe()

- Recipe ~/.dub/packages/dscanner/0.12.0/dscanner/dub.json of size 952:
  - Pass: 3 μs and 2 hnsecs: asdf.jsonparser.parseJson(FallbackAllocator!(InSituRegion!(2048LU, 16LU), Mallocator))
  - Pass: 3 μs and 8 hnsecs: asdf.jsonparser.parseJson()
  - Pass: 13 μs and 5 hnsecs: std.json.parseJSON()
  - Pass: 159 μs and 1 hnsec: parsePackageRecipe()

- Recipe ~/.dub/packages/dscanner/0.12.2/dscanner/dub.json of size 935:
  - Pass: 2 μs and 3 hnsecs: asdf.jsonparser.parseJson(FallbackAllocator!(InSituRegion!(2048LU, 16LU), Mallocator))
  - Pass: 2 μs and 9 hnsecs: asdf.jsonparser.parseJson()
  - Pass: 13 μs and 5 hnsecs: std.json.parseJSON()
  - Pass: 127 μs and 6 hnsecs: parsePackageRecipe()

- Recipe ~/.dub/packages/dscanner/0.8.0/dscanner/dub.json of size 983:
  - Pass: 3 μs and 4 hnsecs: asdf.jsonparser.parseJson(FallbackAllocator!(InSituRegion!(2048LU, 16LU), Mallocator))
  - Pass: 3 μs and 5 hnsecs: asdf.jsonparser.parseJson()
  - Pass: 13 μs and 7 hnsecs: std.json.parseJSON()
  - Pass: 135 μs and 3 hnsecs: parsePackageRecipe()

- Recipe ~/.dub/packages/libackis/1.0.4/libackis/dub.json of size 724:
  - Pass: 2 μs and 3 hnsecs: asdf.jsonparser.parseJson(FallbackAllocator!(InSituRegion!(2048LU, 16LU), Mallocator))
  - Pass: 2 μs and 8 hnsecs: asdf.jsonparser.parseJson()
  - Pass: 7 μs and 7 hnsecs: std.json.parseJSON()
  - Pass: 102 μs and 2 hnsecs: parsePackageRecipe()

- Recipe ~/.dub/packages/odbc/1.0.0/odbc/dub.json of size 608:
  - Pass: 2 μs and 6 hnsecs: asdf.jsonparser.parseJson(FallbackAllocator!(InSituRegion!(2048LU, 16LU), Mallocator))
  - Pass: 1 μs and 8 hnsecs: asdf.jsonparser.parseJson()
  - Pass: 7 μs and 9 hnsecs: std.json.parseJSON()
  - Pass: 89 μs and 6 hnsecs: parsePackageRecipe()```

.
