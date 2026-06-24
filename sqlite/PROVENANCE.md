# Provenance — SQLite functions in this showcase

The C function bodies in [`sqlite-subset.c`](sqlite-subset.c) are copied
**verbatim** (unmodified) from the official SQLite amalgamation.  Only the
small preamble at the top of `sqlite-subset.c` is original to this repo: it
supplies the internal `typedef`s and macros (`u8`/`u32`/`u64`,
`SQLITE_PRIVATE`, `SLOT_2_0`, …) that the amalgamation defines elsewhere, so
the subset preprocesses standalone.

| field | value |
|-------|-------|
| product | SQLite |
| version | 3.39.3 (`#define SQLITE_VERSION "3.39.3"`) |
| file | `sqlite3.c` (preprocessor-free amalgamation) |
| sha256 | `e4e75433871863a69b47eb374772ff769d0ab5714997a2e2123a4941bc4c60a6` |
| upstream | https://www.sqlite.org/ — public domain (https://www.sqlite.org/copyright.html) |

## Functions (source line in `sqlite3.c` 3.39.3)

| function | line | notes |
|----------|------|-------|
| `sqlite3Strlen30`   | 33358 | calls libc `strlen` (PLT extern-call) |
| `putVarint64`       | 34229 | `static`, 9-byte LEB128 writer |
| `sqlite3PutVarint`  | 34253 | varint writer (1/2-byte fast paths → `putVarint64`) |
| `sqlite3GetVarint`  | 34283 | full 9-byte u64 varint reader (`SLOT_2_0`/`SLOT_4_2_0`) |
| `sqlite3GetVarint32`| 34444 | 32-bit varint reader (slow path → `sqlite3GetVarint`) |
| `sqlite3VarintLen`  | 34566 | encoded length of a u64 |
| `sqlite3Get4byte`   | 34576 | big-endian 4-byte load (`__builtin_bswap32` + `memcpy`) |
| `sqlite3Put4byte`   | 34594 | big-endian 4-byte store |

## Verifying the verbatim claim

`scripts/check-verbatim.sh` re-extracts each function from a local
`sqlite3.c` (brace-balanced) and diffs it against `sqlite-subset.c`.  Point
it at an amalgamation whose sha256 matches the table above:

```sh
SQLITE3_C=/path/to/sqlite3.c scripts/check-verbatim.sh
```
