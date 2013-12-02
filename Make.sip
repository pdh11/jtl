## Make.sip

sip: python
	@echo Making sip
	$(REALLY) rm -rf $(BUILD)/sip
	mkdir -p $(BUILD)/sip
	tar xjf $(ARCHIVE)/sip-*bz2 -C $(BUILD)/sip
	# if [ x$(JTL_PATCH) != x ] ; then patch -d $(BUILD)/sip/* -p1 -F5 < patches/$(JTL_PATCH) ; fi
	( cd $(BUILD)/sip/* \
		&& python configure.py \
			CFLAGS="$(JTL_CFLAGS)" CXXFLAGS="$(JTL_CXXFLAGS)" \
		&& $(MAKE) \
		&& $(REALLY) $(MAKE) install )
	du -hs $(BUILD)/sip > $(MADE)/sip
	( $(REALLY) rm -rf $(BUILD)/sip ; sync ) &
