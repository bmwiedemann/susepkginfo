CACHEDIR=cache
M=ftp5.gwdg.de/pub/linux

all: sync
update: db/pkgsrc.dbm db/provides.dbm

db/pkgsrc.dbm: /mounts/dist/full/full-head-x86_64/ARCHIVES.gz
	gzip -cd $< | ./parsearchives.pl
	mv /dev/shm/parsearchives/*.dbm db/

db/provides.dbm: /mounts/dist/full/full-head-x86_64/suse/setup/descr/packages
	./parsepackages.pl < $<
	mv /dev/shm/parsearchives/*.dbm db/

sync: update copy
copy:
	rsync -azSP db/ vm11.zq1.de:/home/aw/html/db.suse/
	rsync -a opensusemaintainer vm11.zq1.de:/home/aw/inc/cgi-bin/public/

clean:
	rm -f db/*

fetch:
	mkdir -p ${CACHEDIR}/{fedora,debian,ubuntu,archlinux,gentoo}
	cd ${CACHEDIR}/fedora ; wget -N http://$M/fedora/linux/development/rawhide/source/SRPMS/repodata/repomd.xml ;\
	p=$$(zgrep -o '[^"]*primary.xml.gz' repomd.xml) ;\
	wget -N http://$M/fedora/linux/development/rawhide/source/SRPMS/$$p ; gzip -cd $$(basename $$p) > primary.xml
	cd ${CACHEDIR}/debian ; for p in main contrib non-free ; do wget -x -N http://$M/debian/debian/dists/unstable/$$p/source/Sources.xz ; done
	cd ${CACHEDIR}/ubuntu ; for p in main universe multiverse restricted ; do wget -x -N http://$M/debian/ubuntu/dists/devel/$$p/source/Sources.gz ; done

db/fedorasrc.dbm: cache/fedora/primary.xml
	cat $< | ./parseprimary.pl
	mv /dev/shm/parsearchives/*.dbm db/
