# skinkjs — Skink to ECMAScript/JavaScript Transpiler

`skinkjs` is the official transpiler that compiles **Skink** source programs into portable ECMAScript / JavaScript, allowing Skink code to run in any JavaScript runtime environment (Node.js, browsers, Deno, Bun, edge workers).

---

## 1. Features

- **Full Skink Frontend Integration**: Uses the official Skink module resolver (`std/resolver`) and two-pass static type checker (`std/checker`) before lowering the AST to JavaScript.
- **Full Browser DOM & JS Interop (`std/dom` & `std/js`)**:
  - `import "std/dom"` provides type-checked access to `Element`, `Event`, `Canvas2D`, `WebSocket`, `GetElementById`, `Query`/`QueryAll`, `CreateElement`, attributes, `classList`, inline styles, `dataset`, DOM tree manipulation, event listeners (`OnClick`, `OnInput`, `OnKeyDown`, etc.), `LocalStorage`/`SessionStorage`, `History`/`Location`, timers (`SetTimeout`, `SetInterval`, `RequestAnimationFrame`), and `FetchText`/`FetchJSON`.
  - `import "std/js"` provides a universal `js.Value` escape hatch (`js.Global()`, `js.Window()`, `js.Document()`, `.Get()`, `.Set()`, `.Call()`, `.Invoke()`, `js.New()`, `js.Eval()`) to interact with any browser or third-party JavaScript library without leaving Skink.
- **Multiple Output Module Formats**:
  - `esm` — ES Modules (`export { ... }`, `import ... from ...`)
  - `cjs` — CommonJS (`"use strict";`, `module.exports = { ... }`, `require(...)`)
  - `iife` — Immediately Invoked Function Expression exposing `globalThis[<globalName>]` for `<script>` tags
  - `umd` — Universal Module Definition compatible with AMD, CommonJS, and browser globals
  - `script` — Plain top-level JavaScript script
- **Single-File & Multi-File Output**:
  - **Single-file bundle** (`--bundle` / `"bundle": true`): Emits a single self-contained `.js` file containing the runtime prelude and all transitive modules.
  - **Multi-file output** (`--multi-file` / `"bundle": false`): Emits `_skink_runtime.js` plus one `.js` module per resolved Skink module in `outDir` linked via relative `import` / `require` statements.
- **Minification (`--minify`)**: Lexical JavaScript minifier that strips comments and redundant whitespace while preserving string/template literals and source mapping comments.
- **Source Map v3 (`--sourcemap` / `--inline-sourcemap`)**: Generates standard Revision 3 `.js.map` files with Base64 VLQ mappings and optional embedded `sourcesContent`, or inline `data:application/json;charset=utf-8;base64,...` URLs.
- **JSON Configuration (`skinkjs.json`) + CLI Overrides**: Automatically loads `./skinkjs.json` (or `--config <path>`) and allows any option to be overridden from the command line.

---

## 2. JSON Configuration (`skinkjs.json`)

Generate a starter configuration file with `skinkjs init`:

```json
{
  "entry": "main.skink",
  "format": "esm",
  "target": "es2022",
  "env": "universal",
  "outFile": "",
  "outDir": "dist",
  "bundle": true,
  "minify": false,
  "sourceMap": false,
  "inlineSourceMap": false,
  "includeSources": true,
  "globalName": "SkinkApp",
  "autoRunMain": true,
  "includeRuntime": true,
  "strict": true,
  "keepComments": false,
  "checkType": true
}
```

---

## 3. CLI Usage

```bash
# Transpile a single Skink file to main.js (ESM bundle)
skinkjs main.skink

# Override format, output directory, output filename, minification, and source map
skinkjs -f cjs -d dist -o app.cjs --minify --sourcemap main.skink

# Emit an IIFE bundle for browsers exposing window.MySkinkLib
skinkjs --format iife --global-name MySkinkLib -o bundle.js main.skink

# Emit multi-file ES modules into dist/modules/
skinkjs --multi-file --format esm --out-dir dist/modules main.skink

# Load a custom JSON config file and override minify on the CLI
skinkjs --config build.json --minify
```

---

## 4. Building, Testing, and Installing

```bash
make          # Build the skinkjs binary
make check    # Type-check skinkjs without linking
make test     # Run the unit and end-to-end Node.js test suite
make install  # Install skinkjs to ~/.local/skink/bin/skinkjs
```
