## Make.x
#
# X libraries and clients

x: pcre perl freetype pkgconfig libxslt fontconfig gperf
	touch $(MADE)/x

x: xdata xfonts xapps xlibs xorg-cf-files

xlibs: libfontenc libICE libSM libX11 libXau libXaw libxcb \
		libXcomposite libXcursor libXdamage libXdmcp libXext \
		libXfixes libXfont libXfontcache libXft libXi libXinerama \
		libxkbfile libxkbui libXmu libXp libXpm libXrandr libXrender \
		libXScrnSaver libXt libXtst libXv libXvMC libXxf86dga \
		libXxf86misc libXxf86vm pixman xcb-util
	touch $(MADE)/xlibs

xfonts: font-adobe-utopia-type1 font-bh-ttf font-bh-type1 \
		font-bitstream-type1 font-cursor-misc font-ibm-type1 \
		font-misc-misc font-xfree86-type1 font-util
	touch $(MADE)/xfonts

xapps: iceauth imake mkfontdir mkfontscale setxkbmap twm xauth xdpyinfo xev \
		xhost \
		xinit xload xmag xorg-scripts xprop xrdb xset xsetroot xterm \
		xtrans xmodmap xrandr
	touch $(MADE)/xapps

xdata: rgb xbitmaps xkbdata
	touch $(MADE)/xdata

##
# Fonts

bdftopcf: util-macros libXfont perl
	$(MAKE) PROG=$@ _xgnu

font-adobe-utopia-type1: util-macros mkfontdir mkfontscale
	$(MAKE) PROG=$@ _xgnu

font-bh-ttf: util-macros mkfontdir mkfontscale
	$(MAKE) PROG=$@ _xgnu

font-bh-type1: util-macros mkfontdir mkfontscale
	$(MAKE) PROG=$@ _xgnu

font-bitstream-type1: util-macros mkfontdir mkfontscale
	$(MAKE) PROG=$@ _xgnu

font-cursor-misc: util-macros bdftopcf mkfontdir mkfontscale
	$(MAKE) PROG=$@ _xgnu

font-ibm-type1: util-macros mkfontdir mkfontscale
	$(MAKE) PROG=$@ _xgnu

font-misc-misc: util-macros bdftopcf font-util mkfontdir mkfontscale
	$(MAKE) PROG=$@ _xgnu

font-xfree86-type1: util-macros mkfontdir mkfontscale
	$(MAKE) PROG=$@ _xgnu

font-util: util-macros
	$(MAKE) PROG=$@ _xgnu

##
# Data

rgb: util-macros xproto
	$(MAKE) PROG=$@ _xgnu

xbitmaps: util-macros
	$(MAKE) PROG=$@ _xgnu

xkbdata: util-macros xkbcomp
	$(MAKE) PROG=$@ _xgnu

##
# Apps

iceauth: util-macros libICE
	$(MAKE) PROG=$@ _xgnu

imake: util-macros
	$(MAKE) PROG=$@ _xgnu

makedepend: util-macros
	$(MAKE) PROG=$@ _xgnu

mkfontdir: util-macros
	$(MAKE) PROG=$@ _xgnu

mkfontscale: util-macros libfontenc freetype
	$(MAKE) PROG=$@ _xgnu

setxkbmap: util-macros libxkbfile libX11
	$(MAKE) PROG=$@ _xgnu

twm: util-macros libX11 libXext libXt libXmu
	$(MAKE) PROG=$@ _xgnu

xauth: util-macros libX11 libXau libXext libXmu
	$(MAKE) PROG=$@ _xgnu

xdpyinfo: util-macros libX11 libxkbfile libXext libXxf86vm libXxf86dga \
		libXxf86misc libXrender libXp libXtst libXi libXinerama
	$(MAKE) PROG=$@ _xgnu

xev: util-macros libX11 libXau libXext libXmu
	$(MAKE) PROG=$@ _xgnu

xhost: util-macros libX11 libXmu libXau
	$(MAKE) PROG=$@ _xgnu

xkbcomp: util-macros libX11 libxkbfile
	$(MAKE) PROG=$@ _xgnu

xinit: util-macros libX11
	$(MAKE) PROG=$@ _xgnu

xload: util-macros libX11 libXaw
	$(MAKE) PROG=$@ _xgnu

xmag: util-macros libX11 libXaw
	$(MAKE) PROG=$@ _xgnu

xmodmap: util-macros libX11 libXaw
	$(MAKE) PROG=$@ _xgnu

xorg-scripts: util-macros libX11
	$(MAKE) PROG=$@ _xgnu

xset: util-macros libXmu libXfontcache
	$(MAKE) PROG=$@ _xgnu

xprop: util-macros libX11 libXmu
	$(MAKE) PROG=$@ _xgnu

xrdb: util-macros libX11 libXmu
	$(MAKE) PROG=$@ _xgnu

xrandr: util-macros libX11 libXrandr
	$(MAKE) PROG=$@ _xgnu

xsetroot: util-macros libX11 libXmu xbitmaps
	$(MAKE) PROG=$@ _xgnu

xterm: util-macros libXft imake pcre libX11 libXt libXaw libXmu libXext \
		libxkbui libxkbfile
	$(MAKE) PROG=$@ JTL_CONFIG="$(JTL_CONFIG) --enable-wide-chars --enable-setuid=root --without-app-defaults --without-icondir" \
		 _xgnu

xtrans: util-macros pkgconfig
	$(MAKE) PROG=$@ _xgnu

##
# Drivers

xf86-input-evdev: xorg-server
	$(MAKE) PROG=$@ _xgnu

xf86-input-keyboard: xorg-server
	$(MAKE) PROG=$@ _xgnu

xf86-input-mouse: xorg-server
	$(MAKE) PROG=$@ _xgnu

xf86-input-wacom: xorg-server
	$(MAKE) PROG=$@ _xgnu \
                JTL_TESTS_BOGUS=0.14.0

xf86-video-nouveau: xorg-server
	$(MAKE) PROG=$@ _xgnu

xf86-video-nv: xorg-server
	$(MAKE) PROG=$@ _xgnu

xf86-video-openchrome: xorg-server
	$(MAKE) PROG=$@ _xgnu

xf86-video-tdfx: xorg-server
	$(MAKE) PROG=$@ _xgnu

xf86-video-ati: xorg-server
	$(MAKE) PROG=$@ _xgnu

##
# Misc

util-macros:
	$(MAKE) PROG=$@ _xgnu

xorg-cf-files: util-macros
	$(MAKE) PROG=$@ _xgnu

##
# Libs

evieext: util-macros
	$(MAKE) PROG=$@ _xgnu

libdrm: util-macros udev
	$(MAKE) PROG=$@ _xgnu \
		JTL_CONFIG="$(JTL_CONFIG) --enable-nouveau-experimental-api" \
		JTL_TESTS_BOGUS=2.4.22

libfontenc: util-macros freetype xproto
	$(MAKE) PROG=$@ _xgnu

libICE: util-macros xproto xtrans
	$(MAKE) PROG=$@ _xgnu

libSM: util-macros libICE xproto
	$(MAKE) PROG=$@ _xgnu

libpthread-stubs:
	$(MAKE) PROG=$@ _xgnu

libX11: util-macros xtrans libXau xcmiscproto bigreqsproto xextproto \
		libXdmcp kbproto inputproto libxcb xf86bigfontproto
	$(MAKE) PROG=$@ _xgnu \
		JTL_TESTS_BOGUS=1.3

libXau: util-macros xproto pkgconfig
	$(MAKE) PROG=$@ _xgnu

# libXaw.so.8 was obsoleted in favour of libXaw.so.7 (!!) in 1.0.5
#
libXaw: util-macros libXp pkgconfig libXmu libXt libX11 libXext libXpm
	$(MAKE) PROG=$@ JTL_CONFIG="$(JTL_CONFIG) --enable-xaw7 --disable-xaw6" _xgnu

libxcb: util-macros xcb-proto libpthread-stubs libxslt libXau xproto libXdmcp
	$(MAKE) PROG=$@ _xgnu \
		JTL_TESTS_BOGUS=1.4

xcb-util: libxcb gperf
	$(MAKE) PROG=$@ _xgnu

libXcomposite: util-macros libXfixes libxcb
	$(MAKE) PROG=$@ _xgnu

libXcursor: util-macros fixesproto libXfixes libxcb
	$(MAKE) PROG=$@ _xgnu

libXdamage: util-macros libxcb libX11 libXfixes
	$(MAKE) PROG=$@ _xgnu

libXdmcp: util-macros xproto
	$(MAKE) PROG=$@ _xgnu

libXext: util-macros xproto libX11 xextproto libXau
	$(MAKE) PROG=$@ _xgnu

libXfixes: util-macros libxcb libX11 fixesproto
	$(MAKE) PROG=$@ _xgnu

libXfont: util-macros freetype fontcacheproto libfontenc fontsproto xtrans
	$(MAKE) PROG=$@ _xgnu

libXfontcache: libXfont libX11
	$(MAKE) PROG=$@ _xgnu

libXft: util-macros freetype fontconfig libxcb libX11 libXrender
	$(MAKE) PROG=$@ _xgnu \
                JTL_PATCH=libXft-2.3.1.diff

libXi: util-macros xproto libX11 xextproto libXext inputproto
	$(MAKE) PROG=$@ _xgnu

libXinerama: util-macros libX11 libXext xineramaproto
	$(MAKE) PROG=$@ _xgnu

libxkbfile: util-macros kbproto libX11
	$(MAKE) PROG=$@ _xgnu

libxkbui: util-macros libX11 libXt libxkbfile
	$(MAKE) PROG=$@ _xgnu

libXmu: util-macros libXext libXt xextproto
	$(MAKE) PROG=$@ _xgnu

libXp: util-macros printproto libX11 libXext libXau xproto xextproto
	$(MAKE) PROG=$@ _xgnu

libXpm: util-macros libX11 xproto
	$(MAKE) PROG=$@ _xgnu

libXrandr: util-macros randrproto libX11 libXext
	$(MAKE) PROG=$@ _xgnu

libXrender: util-macros renderproto libX11
	$(MAKE) PROG=$@ _xgnu

libxshmfence: util-macros libX11
	$(MAKE) PROG=$@ _xgnu

libXScrnSaver: util-macros libxcb libXext libX11 scrnsaverproto
	$(MAKE) PROG=$@ _xgnu

libXt: util-macros libSM libX11 kbproto xproto
	$(MAKE) PROG=$@ _xgnu

libXtst: util-macros libX11 libXext recordproto inputproto libXi
	$(MAKE) PROG=$@ _xgnu

libXv: util-macros libX11 xextproto libXext videoproto
	$(MAKE) PROG=$@ _xgnu

libXvMC: util-macros libXv videoproto xextproto libXext libX11
	$(MAKE) PROG=$@ _xgnu

libXxf86dga: util-macros libX11 libXext xf86dgaproto
	$(MAKE) PROG=$@ _xgnu

libXxf86misc: util-macros xf86miscproto libX11 xextproto libXext
	$(MAKE) PROG=$@ _xgnu

libXxf86vm: util-macros xproto libX11 xextproto libXext xf86vidmodeproto
	$(MAKE) PROG=$@ _xgnu

pixman: util-macros pkgconfig
	$(MAKE) PROG=$@ _xgnu JTL_CONFIG="$(JTL_CONFIG) --disable-gtk"

##
# Protocol

randrproto: util-macros
	$(MAKE) PROG=$@ _xgnu

damageproto: util-macros
	$(MAKE) PROG=$@ _xgnu

renderproto: util-macros
	$(MAKE) PROG=$@ _xgnu

fixesproto: util-macros
	$(MAKE) PROG=$@ _xgnu

inputproto: util-macros
	$(MAKE) PROG=$@ _xgnu

kbproto: util-macros
	$(MAKE) PROG=$@ _xgnu

xcmiscproto: util-macros
	$(MAKE) PROG=$@ _xgnu

bigreqsproto: util-macros
	$(MAKE) PROG=$@ _xgnu

dri2proto: util-macros
	$(MAKE) PROG=$@ _xgnu

dri3proto: util-macros
	$(MAKE) PROG=$@ _xgnu

presentproto: util-macros
	$(MAKE) PROG=$@ _xgnu

glproto: util-macros
	$(MAKE) PROG=$@ _xgnu

xproto: util-macros pkgconfig
	$(MAKE) PROG=$@ _xgnu

xextproto: util-macros
	$(MAKE) PROG=$@ _xgnu

xf86driproto: util-macros
	$(MAKE) PROG=$@ _xgnu

xf86dgaproto: util-macros
	$(MAKE) PROG=$@ _xgnu

xf86miscproto: util-macros
	$(MAKE) PROG=$@ _xgnu

xf86vidmodeproto: util-macros
	$(MAKE) PROG=$@ _xgnu

xf86bigfontproto: util-macros
	$(MAKE) PROG=$@ _xgnu

scrnsaverproto: util-macros
	$(MAKE) PROG=$@ _xgnu

recordproto: util-macros
	$(MAKE) PROG=$@ _xgnu

xineramaproto: util-macros
	$(MAKE) PROG=$@ _xgnu

xcb-proto: util-macros python
	$(MAKE) PROG=$@ _xgnu

resourceproto: util-macros
	$(MAKE) PROG=$@ _xgnu

fontsproto: util-macros
	$(MAKE) PROG=$@ _xgnu

fontcacheproto: util-macros
	$(MAKE) PROG=$@ _xgnu

compositeproto: util-macros
	$(MAKE) PROG=$@ _xgnu

trapproto: util-macros
	$(MAKE) PROG=$@ _xgnu

videoproto: util-macros
	$(MAKE) PROG=$@ _xgnu

printproto: util-macros
	$(MAKE) PROG=$@ _xgnu
