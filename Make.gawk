## Make.gawk
#

gawk:
	$(MAKE) PROG=gawk _gnu
	$(REALLY) ln -sf gawk $(DESTDIR)$(PREFIX)/bin/awk
