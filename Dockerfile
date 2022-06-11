FROM registry.opensuse.org/opensuse/leap:latest
ENV LANG en_US.UTF-8

COPY entrypoint.sh /usr/bin/entrypoint
#RUN ["sudo","chmod","+x","/usr/bin/entrypoint"]
#USER ${NORMAL_USER}
RUN ["chmod","+x","/usr/bin/entrypoint"]
USER root
ENTRYPOINT ["entrypoint"]
