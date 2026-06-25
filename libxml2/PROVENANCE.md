# Provenance — libxml2 `xmlstring.c`

Unlike the SQLite demo (a curated subset), this compiles the **entire**
`xmlstring.c` translation unit from libxml2 — all 37 string functions —
through nelisp-cfront.  `xmlstring.c` is vendored verbatim; `xmlstring.pp.c`
is its preprocessed form (nelisp-cfront does not run cpp).

| field | value |
|-------|-------|
| product | libxml2 |
| version | 2.9.14 (Debian `2.12.7+dfsg+really2.9.14`) |
| file | `xmlstring.c` (whole TU) |
| sha256 | `3cb3a97457ff152921f330b3…` (vendored `xmlstring.c`) |
| upstream | https://gitlab.gnome.org/GNOME/libxml2 — MIT license |

## Preprocessing

`xmlstring.pp.c` was produced from the libxml2 source tree (so its private
headers + generated `config.h` are on the include path), with the trailing
`#include "elfgcchack.h"` removed (it only adds ELF symbol-version aliases):

```sh
# in the libxml2 2.9.14 source tree, after ./configure:
sed 's@#include "elfgcchack.h"@@' xmlstring.c > /tmp/xmlstring-noelf.c
gcc -E -P -I. -Iinclude -DNDEBUG /tmp/xmlstring-noelf.c > xmlstring.pp.c
```

## Externs

After nelisp-cfront lowers the TU, the object references only:

- `memcpy`, `vsnprintf` — libc (resolved by the linker).
- `xmlErrMemory` — libxml2 error path (a no-op stub in `driver.c`; not exercised).

libxml2's allocator hooks (`xmlMalloc` / `xmlMallocAtomic` / `xmlRealloc` /
`xmlFree`, normally defined in `xmlmemory.c`) are emitted by nelisp-cfront as
zero-init bss in the object, so the cfront build is self-contained.  The
**gcc reference** build needs real definitions, supplied by `alloc-stubs.c`
(the exercised functions do not allocate, so the choice doesn't affect the
compared output).

## Notable

`xmlStrPrintf` is a real C-variadic function (`va_start` → `vsnprintf` →
`va_end`).  nelisp-cfront compiles it natively via its SysV defined-varargs
support (register-save-area + `va-list-init`) — no stub — and it is exercised
by `driver.c`, matching glibc byte-for-byte.
