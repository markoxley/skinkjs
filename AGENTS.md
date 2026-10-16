# skinkjs — Project Notes

## Build & Test Commands

- `make` — Build the `skinkjs` CLI binary using `skink`
- `make check` — Type-check `skinkjs.skink` and all `pkg/*.skink` modules
- `make test` — Run the unit and end-to-end Node.js execution test suite (`skink -t skinkjs_test.skink`)
- `make install` — Install `skinkjs` to `~/.local/skink/bin/skinkjs` (override via `SKINK_PREFIX=...`)

## Architecture

- `skinkjs.skink` — CLI driver (`init`, `-c`/`--config`, `-f`/`--format`, `-t`/`--target`, `--env`, `-o`/`--out-file`, `-d`/`--out-dir`, `--bundle`/`--multi-file`, `-m`/`--minify`, `-s`/`--sourcemap`, `--inline-sourcemap`, `-g`/`--global-name`, `--stdout`, `-v`, `-h`)
- `pkg/config.skink` — Parser, validator, normalizer, and CLI override merger for `skinkjs.json`
- `pkg/transpiler.skink` — Core Skink AST-to-JavaScript/ECMAScript transpiler using `std/resolver` and `std/checker`
- `pkg/runtime.skink` — Self-contained JavaScript runtime prelude (`__skink`) and isomorphic standard library shims (`std/str`, `std/fmt`, `std/strconv`, `std/math`, `std/errors`, `std/path`, `std/json`, `std/time`, `std/regex`, `std/rand`, `std/sort`, `std/base64`, `std/os`, `std/fs`, `std/testing`, `std/buf`)
- `pkg/sourcemap.skink` — Source Map Revision 3 generator with Base64 VLQ encoding and inline data URL support
- `pkg/minify.skink` — Lexical JavaScript minifier preserving string/template literals and source mapping comments
