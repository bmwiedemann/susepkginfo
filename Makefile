CACHEDIR=cache
M=ftp5.gwdg.de/pub/linux
export PERL_HASH_SEED = 42

all: sync
update: db/pkgsrc.dbm db/provides.dbm db/develproject.dbm db/altlinuxsrc.dbm db/alpinelinuxsrc.dbm db/archlinuxsrc.dbm db/slackwaresrc.dbm db/ubuntusrc.dbm db/debiansrc.dbm db/mageiasrc.dbm db/fedorasrc.dbm db/centossrc.dbm db/gentoosrc.dbm db/voidlinuxsrc.dbm db/nixossrc.dbm db/guixsrc.dbm

#db/provides.dbm: ${CACHEDIR}/opensuse/packages.gz
#	gzip -cd $< | ./parsepackages.pl

db/develproject.dbm: cache/opensuse/develproject.xml
	./parsedevelproject.pl $$(basename $@) < $<

sync: update copy
copy:
	[ `date +%u` = 1 ] || exclude=--exclude=filepkg.dbm ;\
	rsync -azvSP $$exclude db/ vm11.zq1.de:/home/aw/html/db.suse/
	rsync -a opensusemaintainer vm11.zq1.de:/home/aw/inc/cgi-bin/public/

clean:
	rm -f db/*

fetch:
	mkdir -p ${CACHEDIR}/{opensuse,fedora,centos,mageia,debian,ubuntu,slackware,alpinelinux,archlinux,altlinux,gentoo,voidlinux,nixos,guix}
	#rsync -ptLP /mounts/dist/openSUSE/openSUSE-Factory/suse/setup/descr/packages.gz /mounts/dist/full/full-head-x86_64/ARCHIVES.gz ${CACHEDIR}/opensuse
	cd ${CACHEDIR}/opensuse && ../../getprimary http://$M/suse/opensuse/tumbleweed/repo/oss/
	cd ${CACHEDIR}/opensuse && ../../getfilelists http://$M/suse/opensuse/tumbleweed/repo/oss/
	osc api '/search/package?match=@project="openSUSE:Factory"' > ${CACHEDIR}/opensuse/develproject.xml.new && mv ${CACHEDIR}/opensuse/develproject.xml.new ${CACHEDIR}/opensuse/develproject.xml
	cd ${CACHEDIR}/fedora ; ../../getprimary http://$M/fedora/linux/development/rawhide/Everything/source/tree/
	cd ${CACHEDIR}/centos ; ../../getprimary http://$M/centos/7/os/x86_64
	cd ${CACHEDIR}/mageia ; wget -N http://$M/mageia/distrib/cauldron/SRPMS/core/release/media_info/info.xml.lzma
	echo or http://$M/mageia/distrib/cauldron/SRPMS/core/release/repodata/
	cd ${CACHEDIR}/debian ; for p in main contrib non-free ; do wget -x -N http://$M/debian/debian/dists/unstable/$$p/source/Sources.xz ; done
	cd ${CACHEDIR}/ubuntu ; for p in main universe multiverse restricted ; do wget -x -N http://$M/debian/ubuntu/dists/devel/$$p/source/Sources.gz ; done
	cd ${CACHEDIR}/nixos ; wget -N https://nixos.org/nixpkgs/packages.json.gz
	cd ${CACHEDIR}/guix ; wget -4 -N https://www.gnu.org/software/guix/packages/packages.json
	cd ${CACHEDIR}/slackware ; wget -N http://$M/slackware/slackware-current/PACKAGES.TXT
	cd ${CACHEDIR}/alpinelinux ; wget -N http://dl-cdn.alpinelinux.org/alpine/edge/main/x86_64/APKINDEX.tar.gz
	cd ${CACHEDIR}/archlinux ; for p in core community multilib extra ; do wget -N http://$M/archlinux/$$p/os/x86_64/$$p.db ; done #git clone https://projects.archlinux.org/git/svntogit/packages.git ; git clone https://projects.archlinux.org/git/svntogit/community.git
	cd ${CACHEDIR}/gentoo ; test -e gentoo || git clone --depth 1 https://github.com/gentoo/gentoo.git ; cd gentoo ; git pull
	cd ${CACHEDIR}/voidlinux ; test -e void-packages || git clone --depth 1 https://github.com/voidlinux/void-packages.git ; cd void-packages ; git pull
	cd ${CACHEDIR}/altlinux ; wget -N http://ftp.altlinux.org/pub/distributions/ALTLinux/Sisyphus/files/list/src.list

db/opensusesrc.dbm: ${CACHEDIR}/opensuse/primary.xml.gz ./parseprimary.pl
	gzip -cd $< | ./parseprimary.pl $$(basename $@)

db/filepkg.dbm: ${CACHEDIR}/opensuse/filelists.xml.gz ./parsefilelist.pl
	gzip -cd $< | ./parsefilelist.pl $$(basename $@)

db/fedorasrc.dbm: cache/fedora/primary.xml.gz
	zcat $< | ./parseprimary.pl $$(basename $@)

db/centossrc.dbm: cache/centos/primary.xml.gz
	zcat $< | ./parseprimary.pl $$(basename $@)

db/mageiasrc.dbm: cache/mageia/info.xml.lzma
	xz -cd $< | ./parsemageia.pl $$(basename $@)

db/debiansrc.dbm: cache/debian/$M/debian/debian/dists/unstable/*/source/Sources.xz
	xzcat $^ | ./parsedebiansource.pl $$(basename $@)

db/ubuntusrc.dbm: cache/ubuntu/$M/debian/ubuntu/dists/devel/*/source/Sources.gz
	zcat $^ | ./parsedebiansource.pl $$(basename $@)

db/nixossrc.dbm: cache/nixos/packages.json.gz
	zcat $< | ./parsenixossource.pl $$(basename $@)

db/guixsrc.dbm: cache/guix/packages.json
	cat $< | ./parseguixsource.pl $$(basename $@)

db/slackwaresrc.dbm: cache/slackware/PACKAGES.TXT
	cat $< | ./parseslackware.pl $$(basename $@)

db/alpinelinuxsrc.dbm: cache/alpinelinux/APKINDEX.tar.gz
	tar -xOf $< APKINDEX | ./parsealpinelinux.pl $$(basename $@)

db/archlinuxsrc.dbm: cache/archlinux/*.db
	for f in $^ ; do tar tf $$f ; done | ./parsearchlinux.pl $$(basename $@)

db/gentoosrc.dbm: cache/gentoo/gentoo/.git/refs/heads/master
	for d in cache/gentoo/gentoo/*/* ; do ls $$d/*.ebuild 2>/dev/null |tail -1 ; done | ./parsegentoosource.pl $$(basename $@)

db/voidlinuxsrc.dbm: cache/voidlinux/void-packages/.git/refs/heads/master
	grep -B99 ^version= cache/voidlinux/void-packages/srcpkgs/*/template|./parsevoidlinuxsource.pl $$(basename $@)

db/altlinuxsrc.dbm: cache/altlinux/src.list
	cat $< | ./parsealtlinuxsource.pl $$(basename $@)

test:
	for f in *.pl opensusemaintainer ; do \
	    perl -wc $$f || exit 2; \
	    ! grep $$'\t' $$f || exit 5 ;\
	done
