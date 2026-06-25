# c-libs-in-elisp
#
# Vars (override on the command line):
#   CFRONT_ROOT  path to nelisp-cfront repo  (default ../nelisp-cfront)
#   NELISP_ROOT  path to nelisp repo         (default ../nelisp)
#   EMACS, CC, SQLITE3_C  (see scripts/)
.PHONY: help verify regen check-verbatim

help:
	@echo "make verify         — for each library (SQLite, libxml2) compile with"
	@echo "                      nelisp-cfront AND gcc, link + run both, assert"
	@echo "                      identical output (the demo)"
	@echo "make regen          — regenerate the .pp.c (sqlite) and .el grammar (both)"
	@echo "make check-verbatim SQLITE3_C=/path/to/sqlite3.c"
	@echo "                    — prove the SQLite function bodies are verbatim upstream"

verify:
	@scripts/verify.sh

regen:
	@scripts/regen.sh

check-verbatim:
	@scripts/check-verbatim.sh
