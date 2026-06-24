# nelisp-cfront-showcase
#
# Vars (override on the command line):
#   CFRONT_ROOT  path to nelisp-cfront repo  (default ../nelisp-cfront)
#   NELISP_ROOT  path to nelisp repo         (default ../nelisp)
#   EMACS, CC, SQLITE3_C  (see scripts/)
.PHONY: help verify regen check-verbatim

help:
	@echo "make verify         — compile the SQLite subset with nelisp-cfront AND gcc,"
	@echo "                      link + run both, assert identical output (the demo)"
	@echo "make regen          — regenerate sqlite-subset.pp.c and sqlite-subset.el"
	@echo "make check-verbatim SQLITE3_C=/path/to/sqlite3.c"
	@echo "                    — prove the function bodies are verbatim upstream SQLite"

verify:
	@scripts/verify.sh

regen:
	@scripts/regen.sh

check-verbatim:
	@scripts/check-verbatim.sh
