#!/bin/sh -x

#zypper -n in sudo
zypper -n up
zypper -n in --no-recommends apache2-mod_perl perl-core-DB_File perl-JSON-XS perl-URI perl-XML-Simple wget make

wget -O /srv/www/cgi-bin/opensusemaintainer https://raw.githubusercontent.com/bmwiedemann/susepkginfo/master/opensusemaintainer
chmod a+x /srv/www/cgi-bin/opensusemaintainer
a2enmod perl
echo exec apacheXX

exec bash -i
