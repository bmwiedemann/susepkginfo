#!/bin/sh -x

#zypper -n in sudo
zypper -n up
zypper -n in --no-recommends apache2-mod_perl perl-CGI perl-core-DB_File perl-JSON-XS perl-URI perl-XML-Simple wget make

#wget -O /srv/www/cgi-bin/opensusemaintainer https://raw.githubusercontent.com/bmwiedemann/susepkginfo/master/opensusemaintainer
chmod a+x /srv/www/cgi-bin/opensusemaintainer
sed -i -e 's!our $dbdir.*!our $dbdir="/var/lib/wwwrun/db/";!' /srv/www/cgi-bin/opensusemaintainer
mkdir -p /var/lib/wwwrun/db/xml ; chown -R wwwrun /var/lib/wwwrun/db
a2enmod perl
/usr/sbin/start_apache2 -DFOREGROUND -k start

exec bash -i
