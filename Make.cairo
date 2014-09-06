## Make.cairo
#
# png_REQUIRES because 1.8.8 only pkgconfigs for libpng12, 13, 10 (not 15)
#
# 1.2.14 doesn't like LTO in GCC 4.9.0/gold 2.24

cairo: x libpng glib udev0 
	@echo Making cairo
	rm -rf $(BUILD)/cairo
	mkdir -p $(BUILD)/cairo
	bunzip2 -c $(ARCHIVE)/cairo-*.bz2 | tar xf - -C $(BUILD)/cairo || exit 1
	#patch -d $(BUILD)/cairo/* -p1 -F5 < patches/cairo-1.2.6-jtl1.diff
	( cd $(BUILD)/cairo/* \
		&& CFLAGS="$(JTL_CFLAGS) -fno-lto" CXXFLAGS="$(JTL_CXXFLAGS) -fno-lto" \
			png_REQUIRES=libpng16 \
			./configure --prefix=$(PREFIX) --enable-shared \
			--disable-static --enable-tee --enable-xcb --enable-xcb-shm --disable-drm \
		&& $(MAKE) \
		&& $(REALLY) $(MAKE) install )
	du -hs $(BUILD)/cairo > $(MADE)/cairo
	rm -rf $(BUILD)/cairo
