This is the folder for a transpiler to generate ecmascript and javascript from skink code.
This will allow Skink code to be conmverted to javascript and run in any javascript environment.
A json configuration can be used to determine the output format and other options.
Command line parameters can be used to override the json configuration.
The transpiler should be able to handle all the features of Skink code.

Some options that should be available:
- Output format (ESM, CJS, IIFE, etc.)
- Output file name
- Output directory
- Minify output
- Source map generation
- Single file output
- Multiple file output
- etc.

If there are options that are not possible, add details to the end of this document.

---

## Implementation Details & Supported Options

`skinkjs` is implemented in Skink (`skinkjs.skink` + `pkg/{config,transpiler,runtime,sourcemap,minify}.skink`) using the official Skink module resolver (`std/resolver`) and static type checker (`std/checker`).

### Supported Configuration (`skinkjs.json`) & CLI Options

| JSON Property | CLI Flag Override | Description |
|---|---|---|
| `"entry"` | `<file.skink>`, `-i`, `--entry <file>` | Entry `.skink` source file |
| `"format"` | `-f`, `--format <esm\|cjs\|iife\|umd\|script>` | Output module format (`esm`, `cjs`, `iife`, `umd`, `script`) |
| `"target"` | `-t`, `--target <es2015\|es2020\|es2022\|esnext>` | Target ECMAScript language edition |
| `"env"` | `--env <universal\|node\|browser>` | Target JavaScript host environment |
| `"outFile"` | `-o`, `--out-file <file.js>` | Output file name (or `-` for stdout) |
| `"outDir"` | `-d`, `--out-dir <dir>` | Output directory for single-file or multi-file emission |
| `"bundle"` / `"singleFile"` | `-b`, `--bundle`, `--single-file` | Emit a single self-contained JavaScript bundle |
| `"multiFile"` | `-M`, `--multi-file`, `--no-bundle` | Emit `_skink_runtime.js` + one `.js` file per resolved module |
| `"minify"` | `-m`, `--minify` / `--no-minify` | Minify generated JavaScript (strip comments and whitespace) |
| `"sourceMap"` | `-s`, `--sourcemap` / `--no-sourcemap` | Generate Source Map Revision 3 (`.js.map`) files |
| `"inlineSourceMap"` | `--inline-sourcemap` | Embed Source Map v3 inline as a Base64 data URL |
| `"includeSources"` | `--sources-content` / `--no-sources-content` | Include original `.skink` source text in `sourcesContent` |
| `"globalName"` | `-g`, `--global-name <name>` | Global namespace identifier exported by `iife` and `umd` bundles |
| `"autoRunMain"` | `--run-main` / `--no-run-main` | Automatically invoke `main()` when present |
| `"includeRuntime"` | `--runtime` / `--no-runtime` | Include the `__skink` runtime prelude and standard library shims |
| `"strict"` | `--strict` / `--no-strict` | Emit `"use strict";` directive |
| `"keepComments"` | `--comments` / `--no-comments` | Preserve declaration comments in non-minified output |
| `"checkType"` | `--typecheck` / `--no-typecheck` | Run the Skink static type checker before transpilation |

---

## Options & Native Features Not Possible or Constrained in JavaScript Environments

Because JavaScript engines (V8, SpiderMonkey, JavaScriptCore) execute inside a garbage-collected, single-threaded event-loop virtual machine without raw hardware or arbitrary C ABI memory access, the following native Skink features have inherent platform constraints when transpiled to JavaScript:

1. **Raw C Pointer Arithmetic & Manual `libc` Heap Addresses (`int64(ptr) + offset`)**:
   - In native LLVM Skink, strings and pointers are raw 64-bit virtual memory addresses (`i8*`) that can be cast to `int64`, offset by bytes (`string(int64(buf) + offset)`), and passed to `libc.memcpy` / `libc.free`.
   - JavaScript does not expose virtual memory addresses or allow mutating immutable JS strings in place.
   - **How `skinkjs` handles this**: Value-level pointers (`&x`, `*p`, `*p = val`, `&struct.field`, `&slice[i]`) are fully supported via closure reference cells and `Proxy` wrappers (`__skink.addrOf` / `__skink.deref` / `__skink.setRef`), and `std/str`, `std/buf`, `std/fmt`, `std/path`, etc. are backed by native JavaScript runtime shims instead of `libc` pointer arithmetic. Arbitrary integer-cast pointer arithmetic (`int64(ptr) + 8`) is not possible in pure JavaScript.

2. **Arbitrary Native C FFI (`extern fn` / `import "C:..."`)**:
   - Skink's `extern fn` links directly against system C shared libraries (`libssl`, `libsqlite3`, `libz`, `libSDL2`, `libc`).
   - Standard JavaScript environments (especially browsers) cannot link native C object files or invoke arbitrary C symbols.
   - **How `skinkjs` handles this**: Standard library modules (`std/dom`, `std/js`, `std/str`, `std/math`, `std/strconv`, `std/fmt`, `std/json`, `std/regex`, `std/time`, `std/base64`, `std/os`, `std/fs`, `std/testing`, etc.) are provided by isomorphic JavaScript runtime shims. For any browser or third-party JavaScript API, `std/dom` provides typed DOM/Event/Window/Storage/Fetch/WebSocket/Canvas2D bindings and `std/js` provides universal `js.Value` interop (`js.Global()`, `.Get()`, `.Set()`, `.Call()`, `js.New()`, `js.Eval()`).

3. **Preemptive OS-Thread Concurrency & Blocking Channels (`spawn`, `chan`, `select`, `std/sync`)**:
   - Native Skink maps `spawn` routines onto OS pthreads with blocking mutexes and condition variables.
   - JavaScript is single-threaded per realm (without `SharedArrayBuffer` + Web Workers) and cannot block the main thread waiting on another routine scheduled on the same thread.
   - **How `skinkjs` handles this**: Channels (`make(chan<T>, cap)`), `spawn`, `select`, and `async`/`await` are supported cooperatively in the `__skink` runtime on the single thread, and `ruleset` declarations evaluate deterministically in priority order on `.start()` / `.eval()`. True multi-core shared-memory preemption is not possible on a single JS event loop thread.

4. **Browser Sandbox Restrictions on Filesystem, Raw Sockets, Hardware Buses, and SDL2 GUI**:
   - `std/gpio`, `std/i2c`, and `std/spi` rely on Linux `/sys/class/gpio` and `/dev/i2c-*` / `/dev/spidev*` `ioctl` calls, which do not exist in browser JS.
   - `std/ui` links against native SDL2 + Nuklear C headers and cannot open native OS desktop windows from browser JS.
   - `std/fs` and `std/os` use Node.js `fs` / `process` when running under Node.js, and fall back to an in-memory virtual filesystem (`_vfs`) when running in a browser sandbox.
