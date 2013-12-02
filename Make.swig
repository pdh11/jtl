## Make.swig

swig: tcl python perl
	$(MAKE) PROG=swig _gnu \
		JTL_TESTS_BOGUS=bogus

