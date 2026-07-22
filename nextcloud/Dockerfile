FROM nextcloud:stable-apache

ENV NEXTCLOUD_UPDATE=1
RUN apt-get update && apt-get install -y supervisor && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir /var/log/supervisord /var/run/supervisord

COPY ./supervisord.conf /

COPY ./entrypoint-hook.sh /entrypoint-hook.sh
RUN chmod +x /entrypoint-hook.sh

ENTRYPOINT ["/entrypoint-hook.sh"]
CMD	[ "/entrypoint.sh", "/usr/bin/supervisord", "-c", "/supervisord.conf" ]