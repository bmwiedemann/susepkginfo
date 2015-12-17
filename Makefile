CACHEDIR=cache
M=ftp5.gwdg.de/pub/linux

all: sync
update: db/pkgsrc.dbm db/provides.dbm

db/pkgsrc.dbm: ${CACHEDIR}/opensuse/ARCHIVES.gz
	gzip -cd $< | ./parsearchives.pl
	mv /dev/shm/parsearchives/*.dbm db/

db/provides.dbm: ${CACHEDIR}/opensuse/packages
	./parsepackages.pl < $<
	mv /dev/shm/parsearchives/*.dbm db/

sync: update copy
copy:
	rsync -azSP db/ vm11.zq1.de:/home/aw/html/db.suse/
	rsync -a opensusemaintainer vm11.zq1.de:/home/aw/inc/cgi-bin/public/

clean:
	rm -f db/*

fetch:
	mkdir -p ${CACHEDIR}/{opensuse,fedora,debian,ubuntu,archlinux,gentoo}
	rsync -aP /mounts/dist/full/full-head-x86_64/suse/setup/descr/packages /mounts/dist/full/full-head-x86_64/ARCHIVES.gz ${CACHEDIR}/opensuse
	cd ${CACHEDIR}/fedora ; wget -N http://$M/fedora/linux/development/rawhide/source/SRPMS/repodata/repomd.xml ;\
	p=$$(zgrep -o '[^"]*primary.xml.gz' repomd.xml) ;\
	wget -N http://$M/fedora/linux/development/rawhide/source/SRPMS/$$p ; gzip -cd $$(basename $$p) > primary.xml
	cd ${CACHEDIR}/debian ; for p in main contrib non-free ; do wget -x -N http://$M/debian/debian/dists/unstable/$$p/source/Sources.xz ; done
	cd ${CACHEDIR}/ubuntu ; for p in main universe multiverse restricted ; do wget -x -N http://$M/debian/ubuntu/dists/devel/$$p/source/Sources.gz ; done
	cd ${CACHEDIR}/archlinux ; for p in core community multilib extra ; do wget -N http://$M/archlinux/$$p/os/x86_64/$$p.db ; done #git clone https://projects.archlinux.org/git/svntogit/packages.git ; git clone https://projects.archlinux.org/git/svntogit/community.git
	cd ${CACHEDIR}/gentoo ; test -e gentoo-x86 || cvs -d :pserver:anonymous@anoncvs.gentoo.org:/var/cvsroot co gentoo-x86 ; cd gentoo-x86 ; cvs up

db/fedorasrc.dbm: cache/fedora/primary.xml
	cat $< | ./parseprimary.pl
	mv /dev/shm/parsearchives/*.dbm db/

db/debiansrc.dbm: cache/debian/$M/debian/debian/dists/unstable/*/source/Sources.xz
	xzcat $^ | ./parsedebiansource.pl $$(basename $@)
	mv /dev/shm/parsearchives/*.dbm db/

db/ubuntusrc.dbm: cache/ubuntu/$M/debian/ubuntu/dists/devel/*/source/Sources.gz
	zcat $^ | ./parsedebiansource.pl $$(basename $@)
	mv /dev/shm/parsearchives/*.dbm db/

db/archlinuxsrc.dbm: cache/archlinux/*.db
	for f in $^ ; do tar tf $$f ; done | ./parsearchlinux.pl $$(basename $@)
	mv /dev/shm/parsearchives/*.dbm db/

db/gentoosrc.dbm: cache/gentoo/gentoo-x86/CVS/Entries
	for d in cache/gentoo/gentoo-x86/*/* ; do ls $$d/*.ebuild 2>/dev/null |tail -1 ; done | ./parsegentoosource.pl $$(basename $@)
	mv /dev/shm/parsearchives/*.dbm db/
