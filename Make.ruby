## Make.ruby

ruby: openssl gdbm
	@echo Making ruby
	$(REALLY) rm -rf $(BUILD)/ruby
	mkdir -p $(BUILD)/ruby
	tar xjf $(ARCHIVE)/ruby-*bz2 -C $(BUILD)/ruby
	# if [ x$(JTL_PATCH) != x ] ; then patch -d $(BUILD)/ruby/* -p1 -F5 < patches/$(JTL_PATCH) ; fi
	( cd $(BUILD)/ruby/* \
		&& CFLAGS="$(JTL_CFLAGS)" CXXFLAGS="$(JTL_CXXFLAGS)" \
			./configure $(JTL_CONFIG) --prefix=$(PREFIX) --without-openssl \
		&& $(MAKE) \
		&& $(REALLY) $(MAKE) install )
	cd $(PREFIX)/include/ruby-*/ruby && $(REALLY) ln -sfT ../*-linux/ruby/config.h config.h
	du -hs $(BUILD)/ruby > $(MADE)/ruby
	( $(REALLY) rm -rf $(BUILD)/ruby ; sync ) &
