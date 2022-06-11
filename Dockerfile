FROM registry.opensuse.org/opensuse/leap:latest
ENV LANG en_US.UTF-8

COPY entrypoint.sh /usr/bin/entrypoint
COPY buildscript.sh /usr/local/bin/buildscript.sh
#RUN ["sudo","chmod","+x","/usr/bin/entrypoint"]
#USER ${NORMAL_USER}
#RUN ["chmod","+x","/usr/local/bin/buildscript.sh"]
RUN ["bash","-x","/usr/local/bin/buildscript.sh"]
COPY opensusemaintainer /srv/www/cgi-bin/opensusemaintainer
COPY vhost.conf /etc/apache2/conf.d/opensusemaintainer.conf
COPY maintainerfavicon.ico /srv/www/htdocs/maintainerfavicon.ico
USER root
ENTRYPOINT ["entrypoint"]
