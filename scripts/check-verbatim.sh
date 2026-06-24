#!/usr/bin/env bash
# check-verbatim.sh — prove that every SQLite function in
# sqlite/sqlite-subset.c is byte-identical to the upstream amalgamation.
#
# Usage:  SQLITE3_C=/path/to/sqlite3.c scripts/check-verbatim.sh
# Expected sha256 of sqlite3.c (SQLite 3.39.3):
#   e4e75433871863a69b47eb374772ff769d0ab5714997a2e2123a4941bc4c60a6
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
sub="$here/sqlite/sqlite-subset.c"
SQLITE3_C="${SQLITE3_C:-}"
EXPECT_SHA="e4e75433871863a69b47eb374772ff769d0ab5714997a2e2123a4941bc4c60a6"

if [ -z "$SQLITE3_C" ] || [ ! -f "$SQLITE3_C" ]; then
  echo "set SQLITE3_C=/path/to/sqlite3.c (SQLite 3.39.3 amalgamation)"; exit 2
fi
got_sha="$(sha256sum "$SQLITE3_C" | cut -d' ' -f1)"
if [ "$got_sha" != "$EXPECT_SHA" ]; then
  echo "WARNING: sha256 mismatch (got $got_sha, expected $EXPECT_SHA)"
  echo "         line numbers / bodies may differ from the documented version."
fi

# brace-balanced extractor: from the definition signature line until the
# braces balance back to zero.
extract() { # $1=file $2=startline
  awk -v start="$2" 'NR>=start{print; n+=gsub(/{/,"{"); n-=gsub(/}/,"}");
    if(seen && n==0) exit; if(n>0) seen=1}' "$1"
}
defline() { # $1=file $2=signature-regex  -> first matching DEFINITION line (ends with {)
  grep -nE "$2" "$1" | grep "{[[:space:]]*$" | head -1 | cut -d: -f1
}

fns=(
  'int sqlite3Strlen30\(const char \*z\)'
  'static int SQLITE_NOINLINE putVarint64\(unsigned char \*p, u64 v\)'
  'int sqlite3PutVarint\(unsigned char \*p, u64 v\)'
  'u8 sqlite3GetVarint\(const unsigned char \*p, u64 \*v\)'
  'u8 sqlite3GetVarint32\(const unsigned char \*p, u32 \*v\)'
  'int sqlite3VarintLen\(u64 v\)'
  'u32 sqlite3Get4byte\(const u8 \*p\)'
  'void sqlite3Put4byte\(unsigned char \*p, u32 v\)'
)

fail=0
for re in "${fns[@]}"; do
  up_ln="$(defline "$SQLITE3_C" "$re" || true)"
  sub_ln="$(defline "$sub" "$re" || true)"
  if [ -z "$up_ln" ] || [ -z "$sub_ln" ]; then
    echo "MISSING: /$re/ (upstream=${up_ln:-?} subset=${sub_ln:-?})"; fail=1; continue
  fi
  if diff <(extract "$SQLITE3_C" "$up_ln") <(extract "$sub" "$sub_ln") >/dev/null; then
    echo "OK  verbatim: $re"
  else
    echo "DIFF: $re"; diff <(extract "$SQLITE3_C" "$up_ln") <(extract "$sub" "$sub_ln") || true
    fail=1
  fi
done
[ "$fail" = 0 ] && echo "PASS — all function bodies are verbatim." || { echo "FAIL"; exit 1; }
