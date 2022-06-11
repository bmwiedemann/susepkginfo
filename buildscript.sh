#!/bin/sh -x

zypper -n up
zypper -n in --no-recommends apache2-mod_perl curl perl-CGI perl-core-DB_File perl-JSON-XS perl-URI perl-XML-Simple wget make
a2enmod perl
chmod +x /usr/bin/entrypoint
