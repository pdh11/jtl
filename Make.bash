## Make.bash

bash:
	$(MAKE) PROG=bash -j1 JTL_CONFIG="--with-curses --mandir=$(PREFIX)/share/man --infodir=$(PREFIX)/share/info" JTL_PATCH0=bash-4.3.diff _gnu
	if [ "$(PREFIX)" = "/usr" ]; then \
		$(REALLY) mv -f $(JTL_ROOT)/usr/bin/bash $(JTL_ROOT)/bin/bash ; \
		$(REALLY) ln -sf bash $(JTL_ROOT)/bin/sh ; \
	fi
