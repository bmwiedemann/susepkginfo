#!/bin/sh -ex
# packages and modules are already set up by buildscript.sh at image build time

mkdir -p /var/lib/wwwrun/db/xml
chown -R wwwrun /var/lib/wwwrun/db

exec /usr/sbin/start_apache2 -DFOREGROUND -k start
