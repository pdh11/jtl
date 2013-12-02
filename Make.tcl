## Make.tcl
#
# The sed line to get around a bash-3.1 incompatibility in tcl-8.4.12:
# http://www.diy-linux.org/pipermail/diy-linux-dev/2005-December/000692.html

tcl:
	@echo Compiling tcl
	rm -rf $(BUILD)/tcl
	mkdir -p $(BUILD)/tcl
	tar xjf $(ARCHIVE)/tcl-*bz2 -C $(BUILD)/tcl
	( cd $(BUILD)/tcl/*/unix \
	        && sed -i.bak "s/relid'/relid/" configure \
		&& ./configure --prefix=$(PREFIX) \
			--mandir=$(PREFIX)/share/man \
			--infodir=$(PREFIX)/share/info \
		&& $(MAKE) \
		&& $(REALLY) $(MAKE) install )
	du -hs $(BUILD)/tcl > $(MADE)/tcl
	rm -rf $(BUILD)/tcl
