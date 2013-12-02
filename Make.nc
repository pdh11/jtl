## Make.nc
#
# Warning: (1) archive is called netcat- not nc-; (2) archive untars into CSD

nc:
	@echo Making nc
	rm -rf $(BUILD)/nc
	mkdir -p $(BUILD)/nc
	tar xjf $(ARCHIVE)/netcat-* -C $(BUILD)/nc
	( cd $(BUILD)/nc \
		&& $(MAKE) CFLAGS="$(JTL_CFLAGS) -include /usr/include/resolv.h" nc \
		&& $(REALLY) mkdir -p $(PREFIX)/bin \
		&& $(REALLY) install nc $(PREFIX)/bin )
	du -hs $(BUILD)/nc > $(MADE)/nc
	rm -rf $(BUILD)/nc
