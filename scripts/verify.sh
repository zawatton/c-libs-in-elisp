#!/usr/bin/env bash
# verify.sh — the showcase's "動く実証": for each vendored library, compile
# the (preprocessed) C BOTH with nelisp-cfront (C -> nelisp grammar ->
# native .o) and with the system gcc, link each against the same C driver,
# run both, and assert the two outputs are identical (and contain ALL-OK).
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

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

compile_cfront() {  # $1=pp.c  $2=out.o
  "$EMACS" -Q --batch \
    -L "$CFRONT_ROOT/src" -L "$NELISP_ROOT/lisp" -L "$NELISP_ROOT/src" \
    -l nelisp-cfront-cc \
    --eval "(nelisp-cfront-compile-string
              (with-temp-buffer (insert-file-contents \"$1\") (buffer-string))
              \"$2\")"
}

# run_case NAME PP_C DRIVER [EXTRA...]
# An EXTRA ending in .c is an extra source for the gcc reference only (e.g.
# libxml2 allocator hooks, which nelisp-cfront self-provides as bss);
# any other EXTRA (e.g. -lm) is a link flag passed to BOTH links.
run_case() {
  local name="$1" pp="$2" drv="$3"; shift 3
  local gcc_extra=() link_flags=()
  for a in "$@"; do
    case "$a" in
      *.c) gcc_extra+=("$a") ;;
      *)   link_flags+=("$a") ;;
    esac
  done
  echo "== [$name] nelisp-cfront: $(basename "$pp") -> native .o =="
  compile_cfront "$pp" "$work/$name.o"
  "$CC" "$drv" "$work/$name.o" "${link_flags[@]}" -o "$work/$name-cf"
  local cfout; cfout="$("$work/$name-cf")"
  echo "   cfront : $cfout"
  echo "== [$name] gcc reference =="
  "$CC" -O2 "$pp" "$drv" "${gcc_extra[@]}" "${link_flags[@]}" -o "$work/$name-gcc"
  local gccout; gccout="$("$work/$name-gcc")"
  echo "   gcc    : $gccout"
  if [ "$cfout" = "$gccout" ] && printf '%s' "$cfout" | grep -q "ALL-OK"; then
    echo "   PASS [$name] — byte-for-byte match"
  else
    echo "   FAIL [$name] — outputs differ"; exit 1
  fi
}

run_case sqlite  "$here/sqlite/sqlite-subset.pp.c" "$here/sqlite/driver.c"
run_case libxml2 "$here/libxml2/xmlstring.pp.c"    "$here/libxml2/driver.c" \
         "$here/libxml2/alloc-stubs.c"

echo "ALL PASS — every library matches gcc byte-for-byte."
