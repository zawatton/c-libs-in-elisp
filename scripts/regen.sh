#!/usr/bin/env bash
# regen.sh — regenerate the derived artifacts (the nelisp-cc grammar `.el',
# i.e. the "elisp-ified" code, and where possible the preprocessed `.pp.c').
#
#   sqlite : sqlite-subset.c --gcc -E -P--> sqlite-subset.pp.c
#                            --cfront emit-el--> sqlite-subset.el
#   libxml2: xmlstring.el is regenerated from the vendored xmlstring.pp.c.
#            (xmlstring.pp.c itself needs the full libxml2 source tree to
#             reproduce — see libxml2/PROVENANCE.md.)
#
# Env overrides: CFRONT_ROOT, NELISP_ROOT, EMACS, CC (see verify.sh).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFRONT_ROOT="${CFRONT_ROOT:-$here/../nelisp-cfront}"
NELISP_ROOT="${NELISP_ROOT:-$here/../nelisp}"
EMACS="${EMACS:-emacs}"
CC="${CC:-$(command -v cc || command -v gcc)}"

emit_el() {  # $1=pp.c  $2=out.el
  "$EMACS" -Q --batch \
    -L "$CFRONT_ROOT/src" -L "$NELISP_ROOT/lisp" -L "$NELISP_ROOT/src" \
    -l nelisp-cfront-cc \
    --eval "(nelisp-cfront-emit-el-file \"$1\" \"$2\")"
}

echo "== sqlite: preprocess (macro expansion only) =="
"$CC" -E -P "$here/sqlite/sqlite-subset.c" > "$here/sqlite/sqlite-subset.pp.c"
echo "== sqlite: emit-el (C -> nelisp-cc grammar) =="
emit_el "$here/sqlite/sqlite-subset.pp.c" "$here/sqlite/sqlite-subset.el"

echo "== libxml2: emit-el from vendored xmlstring.pp.c =="
emit_el "$here/libxml2/xmlstring.pp.c" "$here/libxml2/xmlstring.el"

echo "done."
