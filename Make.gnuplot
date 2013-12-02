## Make.gnuplot

gnuplot: pango cairo zlib x
	$(MAKE) PROG=gnuplot _gnu \
                JTL_CONFIG="$(JTL_CONFIG) --without-lisp-files EMACS=no" \
                MAKEINFO="makeinfo --force"
