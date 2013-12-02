## Make.gdb

gdb: expat python
	$(MAKE) PROG=gdb JTL_CONFIG="$(JTL_CONFIG) --enable-static --disable-werror $(JTL_ARCH)-linux" _gnu \
		JTL_TESTS_BOGUS=bogus
