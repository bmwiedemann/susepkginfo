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

