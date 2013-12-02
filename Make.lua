## Make.lua

lua:
	@echo Making Lua
	mv $(BUILD)/lua $(BUILD)/lua.old || true
	( $(REALLY) rm -rf $(BUILD)/lua.old ) &
	mkdir -p $(BUILD)/lua
	tar xjf $(ARCHIVE)/lua-[0-9]*bz2 -C $(BUILD)/lua
	( cd $(BUILD)/lua/* \
		&& $(MAKE) linux \
		&& $(MAKE) test \
		&& $(REALLY) $(MAKE) install INSTALL_TOP=/usr INSTALL_MAN=/usr/share/man/man1 )
	$(REALLY) /sbin/ldconfig || true
	du -hs $(BUILD)/lua > $(MADE)/lua
	( $(REALLY) rm -rf $(BUILD)/lua ; onesync ) &
