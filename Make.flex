## Make.flex
#
# Doesn't cope with --sysconfdir

flex:
	@echo Making GNU flex
	rm -rf $(BUILD)/flex
	mkdir -p $(BUILD)/flex
	( [ -f $(ARCHIVE)/flex-*gz ] \
		&& tar xzf $(ARCHIVE)/flex-*gz -C $(BUILD)/flex ) \
	    || ( [ -f $(ARCHIVE)/flex-*bz2 ] \
		&& tar xjf $(ARCHIVE)/flex-*bz2 -C $(BUILD)/flex ) \
	    || ( echo No archive found for flex ; exit 1 )
	# patch -d $(BUILD)/flex -p0 < patches/flex-2.5.31-jtl1.diff || true
	( cd $(BUILD)/flex/* \
		&& CFLAGS="$(JTL_CFLAGS)" CXXFLAGS="$(JTL_CXXFLAGS)" \
			HELP2MAN=/bin/true \
			./configure --prefix=$(PREFIX) \
			--mandir=$(PREFIX)/share/man \
			--infodir=$(PREFIX)/share/info $(JTL_CONFIG) \
		&& $(MAKE) HELP2MAN=true \
		&& $(REALLY) $(MAKE) install )
	du -hs $(BUILD)/flex > $(MADE)/flex
	rm -rf $(BUILD)/flex
