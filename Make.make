## Make.make

make:
	$(MAKE) PROG=make _gnu \
		JTL_CONFIG="$(JTL_CONFIG) --without-guile"
