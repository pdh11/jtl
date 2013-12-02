## Make.bison

bison:
	$(MAKE) PROG=bison _gnu \
		JTL_TESTS_BOGUS=2.4.2
