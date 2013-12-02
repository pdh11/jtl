## Make.cmake
#
# In 2.8.2, for some cracksmoking reason, --mandir is relative to --prefix

cmake: qt
	$(MAKE) PROG=cmake _gnu \
		JTL_CONFIG="--prefix=/usr --mandir=/share/man"
