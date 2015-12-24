CACHEDIR=cache
M=ftp5.gwdg.de/pub/linux

all: sync
update: db/pkgsrc.dbm db/provides.dbm

db/pkgsrc.dbm: ${CACHEDIR}/opensuse/ARCHIVES.gz
	gzip -cd $< | ./parsearchives.pl

db/provides.dbm: ${CACHEDIR}/opensuse/packages
	./parsepackages.pl < $<

sync: update copy
copy:
	rsync -azSP db/ vm11.zq1.de:/home/aw/html/db.suse/
	rsync -a opensusemaintainer vm11.zq1.de:/home/aw/inc/cgi-bin/public/

clean:
	rm -f db/*

fetch:
	mkdir -p ${CACHEDIR}/{opensuse,fedora,centos,mageia,debian,ubuntu,slackware,archlinux,altlinux,gentoo}
	rsync -aP /mounts/dist/full/full-head-x86_64/suse/setup/descr/packages /mounts/dist/full/full-head-x86_64/ARCHIVES.gz ${CACHEDIR}/opensuse
	cd ${CACHEDIR}/fedora ; ../../getprimary http://$M/fedora/linux/development/rawhide/source/SRPMS/
	cd ${CACHEDIR}/centos ; ../../getprimary http://$M/centos/7/os/x86_64
	cd ${CACHEDIR}/mageia ; wget -N http://ftp5.gwdg.de/pub/linux/mageia/distrib/cauldron/SRPMS/core/release/media_info/info.xml.lzma
	cd ${CACHEDIR}/debian ; for p in main contrib non-free ; do wget -x -N http://$M/debian/debian/dists/unstable/$$p/source/Sources.xz ; done
	cd ${CACHEDIR}/ubuntu ; for p in main universe multiverse restricted ; do wget -x -N http://$M/debian/ubuntu/dists/devel/$$p/source/Sources.gz ; done
	cd ${CACHEDIR}/slackware ; wget -N http://ftp5.gwdg.de/pub/linux/slackware/slackware-current/PACKAGES.TXT
	cd ${CACHEDIR}/archlinux ; for p in core community multilib extra ; do wget -N http://$M/archlinux/$$p/os/x86_64/$$p.db ; done #git clone https://projects.archlinux.org/git/svntogit/packages.git ; git clone https://projects.archlinux.org/git/svntogit/community.git
	cd ${CACHEDIR}/gentoo ; test -e gentoo-x86 || cvs -d :pserver:anonymous@anoncvs.gentoo.org:/var/cvsroot co gentoo-x86 ; cd gentoo-x86 ; cvs up
	cd ${CACHEDIR}/altlinux ; wget -N http://ftp.altlinux.org/pub/distributions/ALTLinux/Sisyphus/files/list/src.list

db/fedorasrc.dbm: cache/fedora/primary.xml.gz
	zcat $< | ./parseprimary.pl $$(basename $@)

db/centossrc.dbm: cache/centos/primary.xml.gz
	zcat $< | ./parseprimary.pl $$(basename $@)

db/mageiasrc.dbm: cache/mageia/info.xml.lzma
	lzma -cd $< | ./parsemageia.pl $$(basename $@)

db/debiansrc.dbm: cache/debian/$M/debian/debian/dists/unstable/*/source/Sources.xz
	xzcat $^ | ./parsedebiansource.pl $$(basename $@)

db/ubuntusrc.dbm: cache/ubuntu/$M/debian/ubuntu/dists/devel/*/source/Sources.gz
	zcat $^ | ./parsedebiansource.pl $$(basename $@)

db/slackwaresrc.dbm: cache/slackware/PACKAGES.TXT
	cat $< | ./parseslackware.pl $$(basename $@)

db/archlinuxsrc.dbm: cache/archlinux/*.db
	for f in $^ ; do tar tf $$f ; done | ./parsearchlinux.pl $$(basename $@)

db/gentoosrc.dbm: cache/gentoo/gentoo-x86/CVS/Entries
	for d in cache/gentoo/gentoo-x86/*/* ; do ls $$d/*.ebuild 2>/dev/null |tail -1 ; done | ./parsegentoosource.pl $$(basename $@)

db/altlinuxsrc.dbm: cache/altlinux/src.list
	cat $< | ./parsealtlinuxsource.pl $$(basename $@)
