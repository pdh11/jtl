## Make.perl

perl: gdbm expat
	@echo Compiling perl
	rm -rf $(BUILD)/perl
	mkdir -p $(BUILD)/perl
	tar xjf $(ARCHIVE)/perl-*bz2 -C $(BUILD)/perl
	patch -d $(BUILD)/perl/p* -p1 -F5 < patches/perl-5.20.2.diff
	( cd $(BUILD)/perl/* \
		&& ./Configure -deO -Dprefix=$(PREFIX) -Uoptimize -Duseshrplib -Dcc=gcc -Dcppstdin=true -A define:cppstdin=true \
		&& $(MAKE) \
		&& $(REALLY) $(MAKE) install )
	du -hs $(BUILD)/perl > $(MADE)/perl
	rm -rf $(BUILD)/perl
