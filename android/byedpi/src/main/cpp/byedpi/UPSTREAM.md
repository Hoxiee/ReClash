# Vendored ByeDPI

- Upstream: https://github.com/hufrea/byedpi
- Version: 0.17.3 (`#define VERSION "17.3"` in `main.c`)
- License: MIT, see `LICENSE`

Sources are copied verbatim. `win_service.c` is omitted because it only builds under `_WIN32`;
`win_service.h` is kept so `main.c` stays unmodified.

Updating: replace the `.c`/`.h` files, then re-check the three contract points the JNI glue depends on —
`main()` in `main.c`, `int server_fd` in `proxy.c`, and `extern struct params params` in `params.h`.
