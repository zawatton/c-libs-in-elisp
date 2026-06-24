#!/usr/bin/env bash
# regen.sh — regenerate the derived artifacts from sqlite/sqlite-subset.c:
#   sqlite-subset.pp.c  (gcc -E -P : macro expansion only; nelisp-cfront
#                        consumes already-preprocessed C)
#   sqlite-subset.el    (nelisp-cfront emit-el : the nelisp-cc grammar =
#                        the "elisp-ified" SQLite, the showcase artifact)
#
# Env overrides: CFRONT_ROOT, NELISP_ROOT, EMACS, CC (see verify.sh).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFRONT_ROOT="${CFRONT_ROOT:-$here/../nelisp-cfront}"
NELISP_ROOT="${NELISP_ROOT:-$here/../nelisp}"
EMACS="${EMACS:-emacs}"
CC="${CC:-$(command -v cc || command -v gcc)}"

src="$here/sqlite/sqlite-subset.c"
pp="$here/sqlite/sqlite-subset.pp.c"
el="$here/sqlite/sqlite-subset.el"

echo "== preprocess (macro expansion only): $src -> $pp =="
"$CC" -E -P "$src" > "$pp"

echo "== emit-el (C -> nelisp-cc grammar): $pp -> $el =="
"$EMACS" -Q --batch \
  -L "$CFRONT_ROOT/src" -L "$NELISP_ROOT/lisp" -L "$NELISP_ROOT/src" \
  -l nelisp-cfront-cc \
  --eval "(nelisp-cfront-emit-el-file \"$pp\" \"$el\")"

echo "done: $pp , $el"
