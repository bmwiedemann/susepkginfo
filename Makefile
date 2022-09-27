CACHEDIR=cache
M=ftp.gwdg.de/pub/linux
T=root@vm11c6.zq1.de.
wget=wget --progress=dot:mega -N
export PERL_HASH_SEED = 42

all: sync
update: db/opensusesrc.dbm db/filepkg.dbm db/pkgsrc.dbm db/provides.dbm db/develproject.dbm db/altlinuxsrc.dbm db/alpinelinuxsrc.dbm db/archlinuxsrc.dbm db/slackwaresrc.dbm db/ubuntusrc.dbm db/debiansrc.dbm db/mageiasrc.dbm db/fedorasrc.dbm db/centossrc.dbm db/gentoosrc.dbm db/voidlinuxsrc.dbm db/nixossrc.dbm db/guixsrc.dbm

#db/provides.dbm: ${CACHEDIR}/opensuse/packages.gz
#	gzip -cd $< | ./parser/parsepackages.pl

db/develproject.dbm: cache/opensuse/develproject.xml
	./parser/parsedevelproject.pl $$(basename $@) < $<

sync: update copy
copy:
	[ `date +%u` = 1 ] || exclude=--exclude=filepkg.dbm ;\
	rsync -rlptzvSP $$exclude db/ $T:/home/aw/html/db.suse/
	rsync -pt opensusemaintainer $T:/home/aw/inc/cgi-bin/public/

clean:
	rm -f db/*

fetch:
	mkdir -p ${CACHEDIR}/{opensuse,fedora,centos,mageia,debian,ubuntu,slackware,alpinelinux,archlinux,altlinux,gentoo,voidlinux,nixos,guix,solus,pclinuxos}
	#rsync -ptLP /mounts/dist/openSUSE/openSUSE-Factory/suse/setup/descr/packages.gz /mounts/dist/full/full-head-x86_64/ARCHIVES.gz ${CACHEDIR}/opensuse
	#cd ${CACHEDIR}/opensuse && ${wget} http://$M/suse/opensuse/tumbleweed/repo/oss/ARCHIVES.gz
	cd ${CACHEDIR}/opensuse && ../../getprimary http://$M/suse/opensuse/tumbleweed/repo/oss/
	cd ${CACHEDIR}/opensuse && ../../getfilelists http://$M/suse/opensuse/tumbleweed/repo/oss/
	osc api '/search/package?match=@project="openSUSE:Factory"' > ${CACHEDIR}/opensuse/develproject.xml.new && mv ${CACHEDIR}/opensuse/develproject.xml.new ${CACHEDIR}/opensuse/develproject.xml
	cd ${CACHEDIR}/fedora ; ../../getprimary http://$M/fedora/linux/development/rawhide/Everything/source/tree/
	cd ${CACHEDIR}/centos ; ../../getprimary http://$M/centos/8-stream/BaseOS/x86_64/os/
	cd ${CACHEDIR}/mageia ; ${wget} http://$M/mageia/distrib/cauldron/SRPMS/core/release/media_info/info.xml.lzma
	echo or http://$M/mageia/distrib/cauldron/SRPMS/core/release/repodata/
	-cd ${CACHEDIR}/pclinuxos && ${wget} http://pclinuxos.mirror.wearetriple.com/pclinuxos/apt/pclinuxos/64bit/base/pkglist.x86_64.bz2
	-cd ${CACHEDIR}/solus && ${wget} https://mirrors.rit.edu/solus/packages/unstable/eopkg-index.xml.xz
	cd ${CACHEDIR}/debian ; for p in main contrib non-free ; do ${wget} -x http://$M/debian/debian/dists/unstable/$$p/source/Sources.xz ; done
	cd ${CACHEDIR}/ubuntu ; for p in main universe multiverse restricted ; do ${wget} -x http://$M/debian/ubuntu/dists/devel/$$p/source/Sources.gz ; done
	cd ${CACHEDIR}/nixos ;${wget} https://channels.nixos.org/nixos-unstable/packages.json.br
	cd ${CACHEDIR}/guix ; rm packages.json ; ${wget} https://guix.gnu.org/packages.json ; touch packages.json
	cd ${CACHEDIR}/slackware ; ${wget} http://$M/slackware/slackware-current/PACKAGES.TXT
	cd ${CACHEDIR}/alpinelinux ; ${wget} http://dl-cdn.alpinelinux.org/alpine/edge/main/x86_64/APKINDEX.tar.gz
	cd ${CACHEDIR}/archlinux ; for p in core community multilib extra ; do ${wget} http://$M/archlinux/$$p/os/x86_64/$$p.db ; done #git clone https://projects.archlinux.org/git/svntogit/packages.git ; git clone https://projects.archlinux.org/git/svntogit/community.git
	cd ${CACHEDIR}/gentoo ; test -e gentoo || git clone --depth 1 https://github.com/gentoo/gentoo.git ; cd gentoo ; git pull
	cd ${CACHEDIR}/voidlinux ; test -e void-packages || git clone --depth 1 https://github.com/void-linux/void-packages.git ; cd void-packages ; git pull
	cd ${CACHEDIR}/altlinux ; ${wget} http://ftp.altlinux.org/pub/distributions/ALTLinux/Sisyphus/files/list/src.list.xz

db/opensusesrc.dbm db/pkgsrc.dbm db/provides.dbm: ${CACHEDIR}/opensuse/primary.xml.zst ./parser/parseprimary.pl
	zstd -cd $< | OPENSUSE=1 ./parser/parseprimary.pl $$(basename $@)

#db/pkgsrc.dbm: cache/opensuse/ARCHIVES.gz
#	gzip -cd $< | parser/parsearchives.pl

db/filepkg.dbm: ${CACHEDIR}/opensuse/filelists.xml.zst ./parser/parsefilelist.pl
	zstd -cd $< | ./parser/parsefilelist.pl $$(basename $@)

db/fedorasrc.dbm: cache/fedora/primary.xml.gz
	zcat $< | ./parser/parseprimary.pl $$(basename $@)

db/centossrc.dbm: cache/centos/primary.xml.gz
	zcat $< | ./parser/parseprimary.pl $$(basename $@)

db/mageiasrc.dbm: cache/mageia/info.xml.lzma
	xz -cd $< | ./parser/parsemageia.pl $$(basename $@)

db/pclinuxossrc.dbm: cache/pclinuxos/pkglist.x86_64.bz2
	bzip2 -cd $< | parser/parsepclinuxos.pl $$(basename $@)

db/solussrc.dbm: cache/solus/eopkg-index.xml.xz
	xz -cd $< | parser/parsesolus.pl $$(basename $@)

db/debiansrc.dbm: cache/debian/$M/debian/debian/dists/unstable/*/source/Sources.xz
	xzcat $^ | ./parser/parsedebiansource.pl $$(basename $@)

db/ubuntusrc.dbm: cache/ubuntu/$M/debian/ubuntu/dists/devel/*/source/Sources.gz
	zcat $^ | ./parser/parsedebiansource.pl $$(basename $@)

db/nixossrc.dbm: cache/nixos/packages.json.br
	brotli -cd $< | ./parser/parsenixossource.pl $$(basename $@)

db/guixsrc.dbm: cache/guix/packages.json
	cat $< | ./parser/parseguixsource.pl $$(basename $@)

db/slackwaresrc.dbm: cache/slackware/PACKAGES.TXT
	cat $< | ./parser/parseslackware.pl $$(basename $@)

db/alpinelinuxsrc.dbm: cache/alpinelinux/APKINDEX.tar.gz
	tar -xOf $< APKINDEX | ./parser/parsealpinelinux.pl $$(basename $@)

db/archlinuxsrc.dbm: cache/archlinux/*.db
	for f in $^ ; do tar tf $$f ; done | ./parser/parsearchlinux.pl $$(basename $@)

db/gentoosrc.dbm: cache/gentoo/gentoo/.git/refs/heads/master
	for d in cache/gentoo/gentoo/*/* ; do ls $$d/*.ebuild 2>/dev/null |tail -1 ; done | ./parser/parsegentoosource.pl $$(basename $@)

db/voidlinuxsrc.dbm: cache/voidlinux/void-packages/.git/refs/heads/master
	grep -B99 ^version= cache/voidlinux/void-packages/srcpkgs/*/template|./parser/parsevoidlinuxsource.pl $$(basename $@)

db/altlinuxsrc.dbm: cache/altlinux/src.list.xz
	xz -cd $< | ./parser/parsealtlinuxsource.pl $$(basename $@)

test:
	for f in *.pl opensusemaintainer ; do \
	    perl -wc $$f || exit 2; \
	    ! grep $$'\t' $$f || exit 5 ;\
	done
