#!/usr/bin/env bash
# verify.sh — the showcase's "動く実証": compile the verbatim SQLite
# subset BOTH with nelisp-cfront (C -> nelisp grammar -> native .o) and
# with the system gcc, link each against the same C driver, run both, and
# assert the two outputs are identical (and "ALL-OK").
#
# Env overrides (defaults assume the sibling dev/ layout):
#   CFRONT_ROOT  path to the nelisp-cfront repo   (default ../nelisp-cfront)
#   NELISP_ROOT  path to the nelisp repo          (default ../nelisp)
#   EMACS        emacs binary                     (default emacs)
#   CC           C compiler                       (default cc, else gcc)
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFRONT_ROOT="${CFRONT_ROOT:-$here/../nelisp-cfront}"
NELISP_ROOT="${NELISP_ROOT:-$here/../nelisp}"
EMACS="${EMACS:-emacs}"
CC="${CC:-$(command -v cc || command -v gcc)}"

pp="$here/sqlite/sqlite-subset.pp.c"
drv="$here/sqlite/driver.c"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "== nelisp-cfront: $pp -> ${work}/subset.o (C -> nelisp grammar -> native) =="
"$EMACS" -Q --batch \
  -L "$CFRONT_ROOT/src" -L "$NELISP_ROOT/lisp" -L "$NELISP_ROOT/src" \
  -l nelisp-cfront-cc \
  --eval "(nelisp-cfront-compile-string
            (with-temp-buffer (insert-file-contents \"$pp\") (buffer-string))
            \"$work/subset.o\")"

echo "== link + run (nelisp-cfront object) =="
"$CC" "$drv" "$work/subset.o" -o "$work/prog-cfront"
"$work/prog-cfront" | tee "$work/out-cfront.txt"

echo "== link + run (gcc reference) =="
"$CC" -O2 "$pp" "$drv" -o "$work/prog-gcc"
"$work/prog-gcc" | tee "$work/out-gcc.txt"

echo "== compare =="
if diff -u "$work/out-gcc.txt" "$work/out-cfront.txt" >/dev/null \
   && grep -q "ALL-OK" "$work/out-cfront.txt"; then
  echo "PASS — nelisp-cfront output matches gcc byte-for-byte."
else
  echo "FAIL — outputs differ:"; diff -u "$work/out-gcc.txt" "$work/out-cfront.txt" || true
  exit 1
fi
