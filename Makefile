# Just The Linux
#

# Override these on the command line if need be (use JTL_ARCH=i386 to be safe)
# X, for reasons best known to itself, barfs if you omit the quotes on -march
PREFIX:=/usr
JTL_DIR:=$(shell pwd)
ARCHIVE:=$(shell pwd)/archive
BUILD:=$(JTL_DIR)/build
MADE:=$(JTL_DIR)/made
JTL_ARCH:=$(shell uname -m)

SUB_ROOT:=$(JTL_DIR)/$(JTL_ARCH)-root
CROSS_ROOT:=$(PREFIX)/$(JTL_CROSS)-linux/$(JTL_CROSS)-root
JTL_SUBLIBS=-L$(SUB_ROOT)/lib -L$(SUB_ROOT)/usr/lib
JTL_ARMLIBS=-L$(ARM_ROOT)/lib -L$(ARM_ROOT)/usr/lib
JTL_ARMINCS=-I$(ARM_ROOT)/usr/include
JTL_ARCHFLAGS_arm:=-O1 -msoft-float
JTL_ARCHFLAGS_i386:=-march="i386" -mcpu="i386"
JTL_ARCHFLAGS_i586:=-march="i586" -mcpu="i586"
JTL_ARCHFLAGS_i686:=-march="i686" -mcpu="i686"
JTL_ARCHFLAGS_x86_64:=-march=native -mtune=native
JTL_ARCHFLAGS_sparc:=
JTL_ARCHFLAGS_sparc64:= -m64 -Wa,-xarch=v9a -mcpu=ultrasparc -D__sparc64__ -D_LP64
JTL_ARCHFLAGS:=$(JTL_ARCHFLAGS_$(JTL_ARCH))
# Linux name, in case it's different from GCC name (e.g. ppc/powerpc)
JTL_CROSS2:=$(JTL_CROSS)
JTL_ROOT=/

# You shouldn't need to alter anything below here

ifeq ($(PREFIX),/usr)
JTL_SYSCONFDIR:=/etc
JTL_VARDIR:=/var
else
JTL_SYSCONFDIR:=$(PREFIX)/etc
JTL_VARDIR:=$(PREFIX)/var
endif
JTL_CFLAGS=-O2 -O9 $(JTL_ARCHFLAGS) -pipe
JTL_CXXFLAGS=-O2 -O9 $(JTL_ARCHFLAGS) -pipe
JTL_CROSSCFLAGS:=-O2 -O9 -pipe
JTL_CROSSCXXFLAGS:=-O2 -O9 -pipe
JTL_CONFIG:=--enable-shared --disable-static --sysconfdir=$(JTL_SYSCONFDIR) \
	--localstatedir=$(JTL_VARDIR) \
	--mandir=$(PREFIX)/share/man --infodir=$(PREFIX)/share/info 
JTL_SCONSCONFIG:=configure
# For when the Linux arch name differs from the GCC one (e.g. ppc/powerpc)
JTL_CROSS2:=$(JTL_CROSS)

ifneq ($(wildcard $(JTL_SYSCONFDIR)/jtl.conf),)
-include $(JTL_SYSCONFDIR)/jtl.conf
else
ifneq ($(wildcard /etc/jtl.conf),)
-include /etc/jtl.conf
endif
endif

COMPONENTS:=$(sort $(filter-out %~,$(wildcard Make.*)))
TARGETS:=$(COMPONENTS:Make.%=%)

# TARGETS:=$(filter-out arm-% sub-%,$(TARGETS))

.SUFFIXES:

vpath % $(MADE)

MADE_BEFORE:=$(wildcard $(MADE)/*) $(JTL_LOCAL_PACKAGES)
MADE_BEFORE1:=$(MADE_BEFORE:$(MADE)/%=%)
MADE_BEFORE2:=$(sort $(filter $(TARGETS),$(MADE_BEFORE1)))

ifeq ($(MAKECMDGOALS),)

.DEFAULT:
	@echo Possible targets are 
	@echo "  " $(TARGETS) | fmt
	@echo Or \'world\'
ifneq ($(MADE_BEFORE2),)
	@echo \'make all\' makes
	@echo "  " $(MADE_BEFORE2) | fmt
endif

world: .DEFAULT

else

include $(COMPONENTS)

world: $(TARGETS)

all:
	$(MAKE) -j1 base
	$(MAKE) $(MADE_BEFORE2)

rebuild:
	rm -f $(MADE)/*
	$(MAKE) -j1 base
	$(MAKE) $(MADE_BEFORE2)

clean::
	$(RM) -rf $(BUILD)/* $(TARGETS:%=$(MADE)/%)

RELEASE:=$(shell date +"%Y-%b-%d")

dist: files
	rm -rf $(BUILD)/jtl-$(RELEASE)
	mkdir -p $(BUILD)/jtl-$(RELEASE)/{build,etc,archive}
	cp -dpR README TODO FILES Make* etc patches $(BUILD)/jtl-$(RELEASE)
	find $(BUILD)/jtl-$(RELEASE) -name CVS -o -name '*~' | xargs rm -rf
	tar cf - -C $(BUILD) jtl-$(RELEASE) | gzip -9 > jtl-$(RELEASE).tar.gz
	rm -rf $(BUILD)/jtl-$(RELEASE)

checketc:
	@for i in $(filter-out %~ CVS,$(wildcard etc/* )) ; do \
		diff -q $$i /$$i || { diff $$i /$$i ; } ; \
	done

check:
	@echo "Checking contents of $(ARCHIVE)"
	@(ARCFILES=`find $(ARCHIVE) -follow -type f | sort | sed -e 's|$(ARCHIVE)/||'` ; FILES=`cat FILES` ; \
		MISSING= export MISSING ; \
		SPARE= export SPARE ; \
		for i in $$FILES ; do \
			{ echo $$ARCFILES | fgrep -q $$i || MISSING="$$MISSING $$i" ; } ; \4
		done ; \
		for i in $$ARCFILES ; do \
			{ echo $$FILES | fgrep -q $$i || SPARE="$$SPARE $$i" ; } ; \
		done ; \
		[ -z "$$MISSING" ] || (echo -e "**\n\tMissing:$$MISSING" | fmt -t ) ; \
		[ -z "$$SPARE" ] || (echo -e "**\n\tSpare:$$SPARE" | fmt -t ) ; \
		[ -z "$$MISSING$$SPARE" ] || (echo ; exit 1) ; \
	)
	@echo "OK"

files:
	find $(ARCHIVE) -follow -type f | sort | sed -e 's|$(ARCHIVE)/||' > FILES

%.png: %.svg
	inkscape --export-png=$*.png --export-background=white -z \
		--export-dpi=72 \
		--export-background-opacity=0.0 $*.svg

%.gif: %.png
	convert $*.png $*.gif

%.map: %.dot
	dot -Ncolor=black -Nfillcolor="#ccffff" -Nfontname="Verdana" -Nfontsize=36 -Nstyle=filled $*.dot -Granksep=0.2 -Gconcentrate=true -Gratio=compress -Goverlap=ortho -Gdpi=72 -Gsize=34,17 -Gbb="0,0,2448,1224" -Tcmap -o $*.map

%.svg: %.dot
	dot -Ncolor=black -Nfillcolor="#ccffff" -Nfontname="Verdana" -Nfontsize=36 -Nstyle=filled $*.dot -Granksep=0.2 -Gconcentrate=true -Gratio=compress -Goverlap=ortho -Gdpi=72 -Gsize=34,17 -Gbb="0,0,2448,1224" -Tsvg -o $*.svg

.PRECIOUS: %.dot %.gif %.svg %.png

doc/graph.dot:
	mkdir -p doc
	echo "digraph G {" > doc/graph1.dot
	LEN="1" ; \
	for i in $(filter-out $(BASE_PACKAGES) base,$(TARGETS)) ; do \
		echo ' base -> "'$$i'" [minlen='$$LEN'] ; ' >> doc/graph1.dot ; \
		LEN=`echo $$LEN | tr 123 231` ; \
	done
	for i in $(BASE_PACKAGES); do \
		echo ' "'$$i'" -> base;' >> doc/graph1.dot; \
	done
	for i in $(COMPONENTS) ; do \
		grep -v ':=' $$i | sed -n -e ':foo' -e '/\\$$/N' -e '/\\$$/b foo' -e 's/\\\n//g' -e '/^[a-z]/p' | grep ':' | grep -v BASE_PACK > doc/graph1.dot.$$i.tmp ; \
		FROM=`sed -e 's/:.*//g' < doc/graph1.dot.$$i.tmp | head -n 1` ; \
		TO=`sed -e 's/.*://g' < doc/graph1.dot.$$i.tmp | head -n 1 | tr ' \t' '\n\n' | sort` ; \
		LEN="1" ; \
		rm doc/graph1.dot.$$i.tmp ; \
		for j in $$TO ; do \
			echo '"'$$j'" -> "'$$FROM'" [minlen='$$LEN'] ;' >> doc/graph1.dot ; \
			LEN=`echo $$LEN | tr 123 231` ; \
		done ; \
	done
	echo "}" >> doc/graph1.dot
	@#
	@# Transitive reduction, trim stuff we don't want to see, add URLs
	@# (The URLs are never used as such, but in imagemap output they're
	@# replaced with the actual JS to do the image manipulation.)
	@#
	tred < doc/graph1.dot \
		| grep -v "sub-" \
		| grep -v "bins" \
		| grep -v "JTL_CROSS" \
		| gvpr 'N { URL="graph-"+name; } END_G { write($$G); }' \
		| dot -Tdot -o $@
	@rm doc/graph1.dot

doc/graph3.dot: doc/graph.dot
	@#
	@# Colourise 'all' and their ancestors
	@#
	head -n 1 $< > $@
	for i in $(MADE_BEFORE2) ; do \
		echo ' "'$$i'" [color=green] ;' >> $@ ; \
	done
	tail -n +2 $< >> $@

doc/graph4.dot: doc/graph3.dot
	@#
	@# Trace back ancestors of 'all'
	@#
	sed -e 's|G {|G { graph [flow=back] ; |' < $< | gvcolor > $@

doc/graph4.gpr: doc/graph4.dot
	@#
	@# Construct colouring-green script (the FOO stuff is to work around
	@# a bug in Graphviz 2.22.3)
	@#
	@sed -e '/,$$/ N' -e 's/,\n/,/' < $< | grep "color=\"0.3" | awk '{print $$1}' | tr -d '"' | sed -e 's|^|N [name=="|' -e 's|$$|"] { fillcolor="palegreen"; }|' > $@
	@echo 'N [name=="foo"] { ; }' >> $@
	@echo 'END_G { write($$G); }' >> $@

doc/graph5.dot: doc/graph4.dot $(MADE)
	@#
	@# Colourise anything absent
	@#
	head -n 1 doc/graph.dot > $@
	for i in `sed -e '/,$$/ N' -e 's/,\n/,/' < doc/graph4.dot | fgrep 0.333 | awk '{print $$1}' | tr -d '"'` ; do \
		make -q $$i || echo ' "'$$i'" [color=green] ;' >> $@ ; \
	done
	tail -n +2 doc/graph.dot >> $@

doc/graph6.dot: doc/graph5.dot
	@#
	@# Trace descendants of absent files
	@#
	gvcolor < $< > $@

doc/graph6.gpr: doc/graph6.dot
	@#
	@# Construct colouring-red script (the FOO stuff is to work around
	@# a bug in Graphviz 2.22.3)
	@#
	@sed -e '/,$$/ N' -e 's/,\n/,/' < $< | grep "color=\"0.3" | awk '{print $$1}' | tr -d '"' | sed -e 's|^|N [name=="|' -e 's|$$|" \&\& fillcolor=="palegreen"] { fillcolor="gold"; }|' > $@
	@echo 'N [name=="foo"] { ; }' >> $@
	@echo 'END_G { write($$G); }' >> $@

COL1:=lightpink1
COL2:=\#FFA0B4
COL3:=\#FF92AF
COL4:=palevioletred1

doc/graph7.dot: doc/graph6.gpr doc/graph4.gpr
	@#
	@# Create final graph: green for OK, gold for can be built, red for
	@# can't yet be built, grey for don't care.
	@#
	gvpr -f doc/graph4.gpr < doc/graph.dot > doc/graph7a.dot
	gvpr -f doc/graph6.gpr < doc/graph7a.dot > doc/graph7b.dot
	gvpr 'E [head.fillcolor=="gold"    && (tail.fillcolor=="gold"    || tail.fillcolor=="$(COL1)")] { head.fillcolor="$(COL1)"; } END_G { write($$G); }' < doc/graph7b.dot > doc/graph7c.dot
	gvpr 'E [head.fillcolor=="$(COL1)" && (tail.fillcolor=="$(COL1)" || tail.fillcolor=="$(COL2)")] { head.fillcolor="$(COL2)"; } END_G { write($$G); }' < doc/graph7c.dot > doc/graph7d.dot
	gvpr 'E [head.fillcolor=="$(COL2)" && (tail.fillcolor=="$(COL2)" || tail.fillcolor=="$(COL3)")] { head.fillcolor="$(COL3)"; } END_G { write($$G); }' < doc/graph7d.dot > doc/graph7e.dot
	gvpr 'E [head.fillcolor=="$(COL3)" && (tail.fillcolor=="$(COL3)" || tail.fillcolor=="$(COL4)")] { head.fillcolor="$(COL4)"; } END_G { write($$G); }' < doc/graph7e.dot > $@

doc/wallpaper.svg: doc/graph7.dot
	dot -Ncolor=black -Nfillcolor="#cccccc" -Nfontname="Luxi Sans" \
		-Nfontsize=36 -Nstyle=filled -Gconcentrate=true \
		-Gbgcolor=transparent -Gbackground=transparent \
		-Goverlap=ortho -Gratio=compress \
		-Gdpi=72 -Gsize=34,21 doc/graph7.dot \
		-Tsvg -o doc/wallpaper.svg 

doc/wallpaper.png: doc/wallpaper.svg
	inkscape --export-png=doc/wallpaper.png --export-background="#1E72A0" \
		 --export-dpi=72 -z doc/wallpaper.svg

doc/wallpaper2.png: doc/wallpaper.svg
	inkscape --export-png=doc/wallpaper2.png --export-width=2560 \
		--export-height=1600 --export-background="#1E72A0" \
		--export-area-drawing -z doc/wallpaper.svg

doc/graph-%.dot: doc/graph.dot
	@echo Graphing $*
	@#
	@# Colorize descendants into doc/graph1.dot
	@#
	@sed -e 's|G {|G { "$*" [color=aquamarine];|' < $< | gvcolor > doc/graph1-$*.dot
	@#
	@# Turn doc/graph1.dot into colourising script doc/graph1.gpr
	@#
	@sed -e '/,$$/ N' -e 's/,\n/,/' < doc/graph1-$*.dot | grep "color=\"0.4"  | awk '{print $$1}' | tr -d '"' | sed -e 's|^|N [name=="|' -e 's|$$|"] { fillcolor="aquamarine"; }|' > doc/graph1-$*.gpr
	@echo 'END_G { write($$G); }' >> doc/graph1-$*.gpr
	@rm doc/graph1-$*.dot
	@#
	@# Colourise into doc/graph2.dot
	@#
	@gvpr -f doc/graph1-$*.gpr < doc/graph.dot > doc/graph2-$*.dot
	@rm doc/graph1-$*.gpr
	@#
	@# Colorize ancestors into doc/graph4.dot
	@#
	@sed -e 's|G {|G { "$*" [color=mistyrose]; graph [flow=back];|' < $< | gvcolor > doc/graph4-$*.dot
	@#
	@# Turn doc/graph4.dot into colourising script doc/graph4.gpr
	@#
	@sed -e '/,$$/ N' -e 's/,\n/,/' < doc/graph4-$*.dot | grep "color=\"0.016" | awk '{print $$1}' | tr -d '"' | sed -e 's|^|N [name=="|' -e 's|$$|"] { fillcolor="mistyrose"; }|' > doc/graph4-$*.gpr
	@echo 'N [name=="'$*'"] { fillcolor="plum"; }' >> doc/graph4-$*.gpr
	@echo 'END_G { write($$G); }' >> doc/graph4-$*.gpr
	@rm doc/graph4-$*.dot
	@#
	@# Create doc/graph5.dot with descendants AND ancestors coloured
	@#
	@gvpr -f doc/graph4-$*.gpr < doc/graph2-$*.dot > doc/graph5-$*.dot
	@rm doc/graph4-$*.gpr doc/graph2-$*.dot
	@#
	@# Fade unfollowed links
	@gvpr 'E [head.fillcolor=="" || tail.fillcolor==""] { color="gray75"; } END_G { write($$G); }' < doc/graph5-$*.dot > doc/graph6-$*.dot
	@rm doc/graph5-$*.dot
	@#
	@# Canonicalise graph by sorting nodes and edges
	@echo 'digraph G {' > doc/graph-$*.dot
	@sed -e :a -e '/\\$$/ N' -e 's,\\\n,,' -e 'ta' \
		    -e '/,$$/ N' -e 's/,\n/,/' -e 'ta' < doc/graph6-$*.dot \
		| grep pos= \
		| sed -e 's/height=".*"/a=b/' \
		| sed -e 's/width=".*"/b=c/' \
		| sed -e 's/pos=".*"/c=d/' \
		| sort >> doc/graph-$*.dot
	@echo '}' >> doc/graph-$*.dot
	@rm doc/graph6-$*.dot

doc/deps.txt: doc/graph.dot
	:> $@.new
	for i in $(TARGETS); do \
		sed -e 's|G {|G { graph [Defcolor=black; flow=back]; "'$$i'" [color="red"];|' < $< | gvcolor > doc/deps.color.dot0 ; \
		gvpr 'N [color!="0.000000 0.000000 0.000000"] {print("        ",$$);}' < doc/deps.color.dot0 | grep -v $$i | sort | fmt >> $@.new ; \
		echo "->" $$i "->" >> $@.new ; \
		sed -e 's|G {|G { graph [Defcolor=black]; "'$$i'" [color="red"];|' < $< | gvcolor > doc/deps.color.dot ; \
		gvpr 'N [color!="0.000000 0.000000 0.000000"] {print("        ",$$);}' < doc/deps.color.dot | grep -v $$i | sort | fmt >> $@.new ; \
		echo >> $@.new ; \
	done
	mv $@.new $@

doc/deps-%.dot: doc/graph-%.dot doc/graph6.gpr doc/graph4.gpr Makefile
	gvpr 'N [fillcolor == "mistyrose" || fillcolor == "plum"] END_G { induce($$O); }' < $< > doc/deps2.dot
	gvpr -f doc/graph4.gpr < doc/deps2.dot > doc/deps2a.dot
	gvpr -f doc/graph6.gpr < doc/deps2a.dot > doc/deps2b.dot
	gvpr 'E [head.fillcolor=="gold"    && (tail.fillcolor=="gold"    || tail.fillcolor=="$(COL1)")] { head.fillcolor="$(COL1)"; } END_G { write($$G); }' < doc/deps2b.dot > doc/deps2c.dot
	gvpr 'E [head.fillcolor=="$(COL1)" && (tail.fillcolor=="$(COL1)" || tail.fillcolor=="$(COL2)")] { head.fillcolor="$(COL2)"; } END_G { write($$G); }' < doc/deps2c.dot > doc/deps2d.dot
	gvpr 'E [head.fillcolor=="$(COL2)" && (tail.fillcolor=="$(COL2)" || tail.fillcolor=="$(COL3)")] { head.fillcolor="$(COL3)"; } END_G { write($$G); }' < doc/deps2d.dot > doc/deps2e.dot
	gvpr 'E [head.fillcolor=="$(COL3)" && (tail.fillcolor=="$(COL3)" || tail.fillcolor=="$(COL4)")] { head.fillcolor="$(COL4)"; } END_G { write($$G); }' < doc/deps2e.dot > $@

.PRECIOUS: doc/graph-%.png doc/deps-%.dot doc/graph-%.dot

GRAPH_TARGETS:=$(filter-out sub%,$(TARGETS))

.PHONY: html
html: doc/graph-x.png doc/graph-x.map
	echo "<img border=0 src=graph-x.png name=tree usemap=#themap><map name=themap>" > doc/index.html
	awk '{ print gensub(/href=\"([^\"]*)\"/, "href=#top onmouseover=document.images[0].src=\"\\1.png\";", "g") }' < doc/graph-x.map >> doc/index.html
	echo "</map>" >> doc/index.html
	echo $(GRAPH_TARGETS) | awk '{ print gensub(/([^\" ]*)/, "<a href=#top onclick=document.images[0].src=\"graph-\\1.png\"; >\\1</a> ", "g") }' >> doc/index.html
	$(MAKE) $(patsubst %,doc/graph-%.png,$(GRAPH_TARGETS))

ifeq ($(JTL_TOUCH),)
JTL_TOUCH:=$(PROG)
endif
ifeq ($(JTL_BUILD),)
JTL_BUILD:=$(PROG)
endif
ifeq ($(JTL_INSTALL),)
JTL_INSTALL:=install
endif

#	[ x$(JTL_PATCH) != x ] && patch -d $(BUILD)/$(PROG)/* -p0 < patches/$(JTL_PATCH)

_gnu:
	@echo Making GNU $(PROG)
	mv $(BUILD)/$(JTL_BUILD) $(BUILD)/$(JTL_BUILD).old || true
	( $(REALLY) rm -rf $(BUILD)/$(JTL_BUILD).old ) &
	mkdir -p $(BUILD)/$(JTL_BUILD)
	( [ -f $(ARCHIVE)/$(PROG)-[0-9]*gz ] \
		&& tar xzf $(ARCHIVE)/$(PROG)-[0-9]*gz -C $(BUILD)/$(JTL_BUILD) ) \
	    || ( [ -f $(ARCHIVE)/$(PROG)-[0-9]*bz2 ] \
		&& tar xjf $(ARCHIVE)/$(PROG)-[0-9]*bz2 -C $(BUILD)/$(JTL_BUILD) ) \
	    || ( [ -f $(ARCHIVE)/$(PROG)-*gz ] \
		&& tar xzf $(ARCHIVE)/$(PROG)-*gz -C $(BUILD)/$(JTL_BUILD) ) \
	    || ( [ -f $(ARCHIVE)/$(PROG)-*bz2 ] \
		&& tar xjf $(ARCHIVE)/$(PROG)-*bz2 -C $(BUILD)/$(JTL_BUILD) ) \
	    || ( echo No archive found for $(PROG) ; exit 1 )
	if [ x$(JTL_PATCH) != x ] ; then patch -d $(BUILD)/$(JTL_BUILD)/* -p1 -F5 -z.old < patches/$(JTL_PATCH) ; fi
	( cd $(BUILD)/$(JTL_BUILD)/* \
		&& rm -f config.cache \
		&& ( [ -f configure ] || chmod a+x ./autogen.sh ) \
		&& ( [ -f configure ] || ./autogen.sh ) \
		&& if [ x$(JTL_AUTOCONF) != x ] ; then automake --add-missing ; autoreconf ; fi \
		&& chmod a+x configure \
		&& CFLAGS="$(JTL_CFLAGS)" CXXFLAGS="$(JTL_CXXFLAGS)" \
			./configure --prefix=$(PREFIX) $(JTL_CONFIG) \
		&& $(MAKE) $(JTL_MAKE) \
		&& if [ x$(JTL_TESTS_BOGUS) == x ] && grep -q '^check:' Makefile ; then $(MAKE) -j1 check ; fi \
		&& if [ x$(JTL_TESTS_BOGUS) == x ] && grep -q '^tests[ :]' Makefile ; then $(MAKE) -j1 tests ; fi \
		&& $(REALLY) $(MAKE) DESTDIR=$(JTL_ROOT) $(JTL_INSTALL) )
	$(REALLY) /sbin/ldconfig || true
	du -hs $(BUILD)/$(JTL_BUILD) > $(MADE)/$(JTL_TOUCH)
	( $(REALLY) rm -rf $(BUILD)/$(JTL_BUILD) ; onesync ) &

_qmake:
	@echo Making $(PROG)
	mv $(BUILD)/$(JTL_BUILD) $(BUILD)/$(JTL_BUILD).old || true
	( $(REALLY) rm -rf $(BUILD)/$(JTL_BUILD).old ) &
	mkdir -p $(BUILD)/$(JTL_BUILD)
	tar xjf $(ARCHIVE)/$(PROG)-[0-9]*bz2 -C $(BUILD)/$(JTL_BUILD)
	if [ x$(JTL_PATCH) != x ] ; then patch -d $(BUILD)/$(JTL_BUILD)/* -p1 -F5 -z.old < patches/$(JTL_PATCH) ; fi
	( cd $(BUILD)/$(JTL_BUILD)/* \
		&& qmake \
		&& $(MAKE) $(JTL_MAKE) \
		&& if [ x$(JTL_TESTS_BOGUS) == x ] && grep -q '^check:' Makefile ; then $(MAKE) -j1 check ; fi \
		&& if [ x$(JTL_TESTS_BOGUS) == x ] && grep -q '^tests[ :]' Makefile ; then $(MAKE) -j1 tests ; fi \
		&& $(REALLY) $(MAKE) $(JTL_INSTALL) )
	$(REALLY) /sbin/ldconfig || true
	du -hs $(BUILD)/$(JTL_BUILD) > $(MADE)/$(JTL_TOUCH)
	( $(REALLY) rm -rf $(BUILD)/$(JTL_BUILD) ; onesync ) &

_xgnu:
	$(MAKE) PREFIX=$(PREFIX)/X11 _gnu

_gnuscons:
	@echo Making GNU $(PROG) with scons
	rm -rf $(BUILD)/$(PROG)
	mkdir -p $(BUILD)/$(PROG)
	( [ -f $(ARCHIVE)/$(PROG)-*gz ] \
		&& tar xzf $(ARCHIVE)/$(PROG)-*gz -C $(BUILD)/$(PROG) ) \
	    || ( [ -f $(ARCHIVE)/$(PROG)-*bz2 ] \
		&& tar xjf $(ARCHIVE)/$(PROG)-*bz2 -C $(BUILD)/$(PROG) ) \
	    || ( echo No archive found for $(PROG) ; exit 1 )
	if [ x$(JTL_PATCH) != x ] ; then patch -d $(BUILD)/$(PROG)/* -p1 < patches/$(JTL_PATCH) ; fi
	( cd $(BUILD)/$(PROG)/* \
		&& CFLAGS="$(JTL_CFLAGS)" CXXFLAGS="$(JTL_CXXFLAGS)" \
			scons $(JTL_SCONSCONFIG) prefix=$(PREFIX) \
		&& scons \
		&& $(REALLY) scons install )
	du -hs $(BUILD)/$(PROG) > $(MADE)/$(JTL_TOUCH)
	( rm -rf $(BUILD)/$(PROG) ; onesync ) &

_gnucmake:
	@echo Making GNU $(PROG) with cmake
	rm -rf $(BUILD)/$(PROG)
	mkdir -p $(BUILD)/$(PROG)
	( [ -f $(ARCHIVE)/$(PROG)-[0-9]*gz ] \
		&& tar xzf $(ARCHIVE)/$(PROG)-[0-9]*gz -C $(BUILD)/$(PROG) ) \
	    || ( [ -f $(ARCHIVE)/$(PROG)-[0-9]*bz2 ] \
		&& tar xjf $(ARCHIVE)/$(PROG)-[0-9]*bz2 -C $(BUILD)/$(PROG) ) \
	    || ( echo No archive found for $(PROG) ; exit 1 )
	if [ x$(JTL_PATCH) != x ] ; then patch -d $(BUILD)/$(PROG)/* -p1 < patches/$(JTL_PATCH) ; fi
	mkdir -p $(BUILD)/$(PROG)/build
	( cd $(BUILD)/$(PROG)/build \
		&& CFLAGS="$(JTL_CFLAGS)" CXXFLAGS="$(JTL_CXXFLAGS)" \
			CMAKE_LIBRARY_PATH=/usr/X11/lib:/usr/qt/lib:/usr/kde/lib \
			cmake ../$(PROG)* -DCMAKE_INSTALL_PREFIX:PATH=$(PREFIX) $(JTL_CMAKE) \
		&& $(MAKE) \
		&& $(REALLY) $(MAKE) install )
	du -hs $(BUILD)/$(PROG) > $(MADE)/$(JTL_TOUCH)
	( rm -rf $(BUILD)/$(PROG) ; onesync ) &

_xstyle:
	@echo Making X-style $(PROG)
	rm -rf $(BUILD)/$(PROG)
	mkdir -p $(BUILD)/$(PROG)
	( [ -f $(ARCHIVE)/$(PROG)-*gz ] \
		&& tar xzf $(ARCHIVE)/$(PROG)-*gz -C $(BUILD)/$(PROG) ) \
	    || ( [ -f $(ARCHIVE)/$(PROG)-*bz2 ] \
		&& tar xjf $(ARCHIVE)/$(PROG)-*bz2 -C $(BUILD)/$(PROG) ) \
	    || ( echo No archive found for $(PROG) ; exit 1 )
	( cd $(BUILD)/$(PROG)/* \
		&& xmkmf \
		&& $(MAKE) Makefiles \
		&& $(MAKE) \
		&& $(REALLY) $(MAKE) install )
	du -hs $(BUILD)/$(PROG) > $(MADE)/$(PROG)
	( rm -rf $(BUILD)/$(PROG) ; onesync ) &

_perlstyle:
	@echo Making Perl-style $(PROG)
	rm -rf $(BUILD)/$(PROG)
	mkdir -p $(BUILD)/$(PROG)
	tar xzf $(ARCHIVE)/$(PROG)-*gz -C $(BUILD)/$(PROG) \
		|| tar xf $(ARCHIVE)/$(PROG)-*bz2 -C $(BUILD)/$(PROG) --use-compress-program bzip2 \
		|| ( echo No archive found for $(PROG) ; exit 1 )
	( cd $(BUILD)/$(PROG)/* \
		&& (yes "" | perl Makefile.PL $(JTL_CONFIG) ) \
		&& $(MAKE) \
		&& $(REALLY) $(MAKE) install )
	du -hs $(BUILD)/$(PROG) > $(MADE)/$(PROG)
	rm -rf $(BUILD)/$(PROG)
	onesync

perl_%: perl
	$(MAKE) PROG=$@ _perlstyle

_pythonstyle:
	@echo Making Python-style $(PROG)
	$(REALLY) rm -rf $(BUILD)/$(PROG)
	mkdir -p $(BUILD)/$(PROG)
	tar xzf $(ARCHIVE)/$(PROG)-*gz -C $(BUILD)/$(PROG) \
		|| tar xf $(ARCHIVE)/$(PROG)-*bz2 -C $(BUILD)/$(PROG) --use-compress-program bzip2 \
		|| ( echo No archive found for $(PROG) ; exit 1 )
	( cd $(BUILD)/$(PROG)/* \
		&& python setup.py build \
		&& $(REALLY) python setup.py install --prefix=$(PREFIX) )
	du -hs $(BUILD)/$(PROG) > $(MADE)/$(JTL_TOUCH)
	$(REALLY) rm -rf $(BUILD)/$(PROG)
	onesync

_gnu-strip:
	@echo Making GNU $(PROG)
	rm -rf $(BUILD)/$(PROG)
	mkdir -p $(BUILD)/$(PROG)
	tar xzf $(ARCHIVE)/$(PROG)-*gz -C $(BUILD)/$(PROG) \
		|| tar xf $(ARCHIVE)/$(PROG)-*bz2 -C $(BUILD)/$(PROG) --use-compress-program bzip2 \
		|| ( echo No archive found for $(PROG) ; exit 1 )
	( cd $(BUILD)/$(PROG)/* \
		&& CFLAGS="$(JTL_CFLAGS)" CXXFLAGS="$(JTL_CXXFLAGS)" \
			./configure --prefix=$(PREFIX) \
				--mandir=$(PREFIX)/share/man \
				--infodir=$(PREFIX)/share/info $(JTL_CONFIG) \
		&& $(MAKE) $(JTL_MAKE) \
		&& $(REALLY) $(MAKE) DESTDIR=$(JTL_ROOT) install-strip )
	du -hs $(BUILD)/$(PROG) > $(MADE)/$(PROG)
	rm -rf $(BUILD)/$(PROG)

endif
