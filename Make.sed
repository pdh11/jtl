## Make.sed

sed:
	$(MAKE) PROG=sed _gnu-strip
	if [ $(PREFIX) = /usr ] ; then \
	  $(REALLY) mv $(JTL_ROOT)/usr/bin/sed $(JTL_ROOT)/bin ; \
	fi
