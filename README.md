
			JUST THE LINUX 1.1
			==================

JTL is a very simple Linux distribution. It doesn't come with any of the
random junk that the big distros like to fill your winchester with --
stuff you don't even understand, let alone need.

	* JTL does not use PAM
	* JTL does not even use shadow passwords
	* JTL uses a BSD-style /etc/rc, not all this init.d drivel
	* JTL does not have binary packages
	* JTL does not, in fact, have any package management at all

So what does it have?

	* JTL is only about a 90Kbyte download [1].
	* JTL builds everything from source. There are NO binary packages,
	  except for those programs which do not come with source.
	* JTL has shiny new versions of most things, except gcc. This
	  includes KDE3, XFree86 4.2.0, glibc 2.2.5, and binutils 2.12.
	* JTL builds everything optimised for your CPU (-mpentiumpro or
	  whatever).
	* JTL builds its own bootable install CD -- or, alternatively,
	  its own bootable NFS root directory. You can copy its ideas
	  to make your own custom distributions for specific purposes,
	  e.g. for booting discless audio/video clients.

[1] Plus about two hundred miscellaneous source tarballs which you
    have to find and download yourself, total around 500Mbytes.


INSTALLATION INSTRUCTIONS
-------------------------

Because JTL has no binary packages, you need an existing Linux system
on which to build your installation CD. (An alternative name I
considered was "Contagious Linux", as you can only catch it from a
system that already has it.)

Download the latest jtl-*.tar.gz and unpack it. In it you'll find
"FILES", which is a list of all the source tarballs you'll need for
a complete JTL system. You don't need all of them to get started, but
you'll need at least the ones mentioned in Make.sub:

	autoconf automake bash binutils bzip2 dhcpcd e2fsprogs
	fileutils findutils gawk gcc gettext glibc grep gzip
	sysvinit linux lilo make modutils ncurses net-tools
	netkit-combo patch procps sed sh-utils tar tcp_wrappers
	textutils util-linux fakeroot dosfstools syslinux mtools
	cdrtools

When you've fetched all the tarballs, you can start building. Building
occurs in the "build" subdirectory of your jtl directory, so use a
symbolic link or a mount point if necessary to make sure there's at
least 1200Mbytes free on the partition it points to.

Now build your bootable installation CD. In your jtl directory, type

	make JTL_ARCH=i386 sub

bearing in mind that you probably don't want these binaries optimised
for your CPU, as that would produce an installation CD unusable on
earlier CPUs.

This process will first build a few tools (fakeroot, syslinux) that
are necessary for building JTL itself. These tools are installed,
by default, in /usr. If you are not root, or do not trust JTL to put
stuff in /usr/bin responsibly, you should do

	make PREFIX=/home/whoever fakeroot
	fakeroot make JTL_ARCH=i386 PREFIX=/home/whoever sub

but you will need to make sure that PREFIX/bin and PREFIX/sbin are
in your PATH.

Some time after you've typed that, you should be left with i386.iso
in your JTL directory. Burn that file to a CD and boot from it.


INSTALLATION INSTRUCTIONS, PART 2: THE INSTALLATION CD
------------------------------------------------------

OK, I lied. It's not an installation CD. There is no form of
installation program on that CD whatsoever. It is, however, enough
of a Linux distribution for an expert to manually use fdisk, lilo
etc. to install Linux on any detected mass-storage device. There
is even enough of a distribution there that, if you have a PCI
network card supported by Linux 2.4.18, and you have a DHCP server
elsewhere on your network, telnetd will run and you can log in as
root (blank password) and install the system remotely.

If you're not sure whether you're an expert or not, and want a bit
of a checklist of what a manual installation entails, you'll need
at least to:

	* Use fdisk to partition your winchester (if it's not
	  partitioned already, or if you want to change the way
	  it's partitioned). This hoses the whole disk, so watch
	  it.

	* Use mke2fs to format your root partition (and any other
	  partitions you want). This hoses the whole partition,
	  blah blah.

	* Use mkswap on the partition you want to swap to, if any.

	* Mount the partition you want your root filesystem in,
	  on /mnt. If you want /boot or /usr to be on different
	  filesystems, mount them in the right place under /mnt.

	* Untar /i386-root.tar.gz (from the installation CD) into
	  /mnt.

	* Edit /mnt/etc/fstab and /mnt/etc/lilo.conf appropriately,
	  and run lilo -r /mnt. This hoses your previous boot 
	  sector.

	* Once you're satisfied that /mnt is probably a bootable
	  root filesystem, and that lilo is going to do the Right
	  Thing, you can umount /mnt and reboot, dextrously
	  removing the CD before your system tries to boot from it
	  again.

Do not moan at me if it doesn't work, unless it's fairly provably
my fault. In particular, it's your fault, not mine, if you've 
misjudged whether you're an expert or not. That's why it's called
"Just The Linux". Any problems you have are a personal matter just
between you and Linux, and I'm not going to get involved.


INSTALLATION INSTRUCTIONS, PART 3: A NEW WORLD
----------------------------------------------

Unless you edited /mnt/etc/passwd above, the root password is
still blank. (Which has security implications, of course, but if
you didn't know that sort of stuff you wouldn't have read this far.)

Your new system has a JTL directory at /usr/src/jtl, and your
previous collection of archives in /archive. You'll probably
want to start by rebuilding the base packages, optimised for your
CPU (recall that those on the install CD were optimised for i386).
In /usr/src/jtl, type "make base" (which remakes everything that
came on the installation CD). JTL will optimise for your CPU by
default, you don't need to set JTL_ARCH.

If JTL doesn't work out how to optimise for your CPU (which is
likely, for instance, if you have an Athlon or Duron) you can
override the default optimisations by setting JTL_ARCHFLAGS in
/etc/jtl.conf (see the Makefile for how that works).

If you rebuild init or glibc (which "make base" does), don't forget
to run "telinit -u", or rc.shutdown won't be able to cleanly
unmount /.

The basic installation includes only enough programs to compile
the rest of the system: if anything could possibly be left out and
compiled later, it has been. So once you've recompiled the base
packages, you should start adding to your collection of tarballs,
and making further packages:

	* "make kde" might be a popular choice, or "make gnome",
	  or both. Making KDE takes 17.5 hours on a Celeron 366.

	* You'll almost certainly want packages such as man, time,
	  which, nfs-utils, apache, perl and python.
	
	* For a server you might also want imapd, samba, exim,
	  and procmail.

	* There's a good amount of audio/video stuff in JTL,
	  including freeamp, lame, mplayer, transcode, and ogle.


BUT IT DOESN'T HAVE PROGRAM FOO, WHICH I USE EVERY DAY
------------------------------------------------------

So figure out how to compile and install it, and send me a
Makefile so I can integrate it into the next version of JTL.
If you're a vi user, you'll have to figure out how to compile
and install vi using only xemacs. Ha ha, de ha ha, har.

Programs which can be installed by a simpleminded "untar ;
configure; make; su; make install" only need very simple
Makefiles, as most of the work is done by the generic "_gnu"
target; look at Make.pkgconfig for an example. Note that JTL
installs everything to /usr by default, not /usr/local.

JTL does have patches for a few particularly vital or
intransigent programs, but try to avoid relying on a patch when
adding further packages to JTL. Patches get out-of-date quickly,
whereas evilness in Makefiles (and some of the existing ones,
particularly ncurses, are tangibly evil) tends to be more durable.

If you submit a Makefile, I'd appreciate it if you donated that
Makefile to the public domain (rather than claiming copyright
on it), as I have done with all the Makefiles I wrote.


SPECIAL PRIZE FOR THE PACKAGE WHOSE BUILD SYSTEM CAUSED MOST GRIEF
------------------------------------------------------------------

Awarded to ncurses.


LICENSING AND LEGAL ISSUES
--------------------------

JTL will build many different packages, which between them have
many different licences. It is up to you to obtain and use those
packages in accordance with those licences. Just because JTL
includes a makefile for a given package, doesn't mean you're
necessarily allowed to build or use it.

For example, JTL will build libdvdcss for you, *if* you have
obtained a libdvdcss source tarball and *if* you tell JTL to build
it (or a package which depends on it). JTL itself contains no
CSS code whatsoever, nor links to where any may be found. Only
if you already have it, will JTL be able to build it.

As another example, JTL will build several packages which are
capable of reading or writing GIF images using LZW compression.
If you live in a country where software patents are enforceable,
then you may require a patent licence from Unisys to obtain or
use any of these packages. JTL itself contains no LZW code
whatsoever.

As a third example, JTL will build several packages which use
"strong crypto". Such packages may be illegal to export, or
require a special government permit, or may even be illegal
to own at all. JTL itself contains no cryptographic code
whatsoever.

Those parts of JTL which I did write -- the Makefiles, and
one or two (not all) of the patches -- are placed in the public
domain. As a request (not a demand), if you use them for
anything else, it'd be nice if you mentioned somewhere that your
creation was based on, or included, parts of JTL.


						 Peter Hartley
					pdh@utter.chaos.org.uk
						 23 April 2002
