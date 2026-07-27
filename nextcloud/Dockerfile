FROM nextcloud:stable-apache

ENV NEXTCLOUD_UPDATE=1

RUN apt-get update && apt-get install -y supervisor && \
  mkdir /var/log/supervisord /var/run/supervisord
RUN apt-get update && apt-get install -y ffmpeg
# RUN apt-get update && apt-get install -y imagemagick libmagickcore-7.q16-10-extra

RUN rm -rf /var/lib/apt/lists/*

COPY ./supervisord.conf /

COPY ./entrypoint-hook.sh /entrypoint-hook.sh
RUN chmod +x /entrypoint-hook.sh

COPY ./notify-push.sh /notify-push.sh
RUN chmod +x /notify-push.sh

ENTRYPOINT ["/entrypoint-hook.sh"]
CMD	[ "/entrypoint.sh", "/usr/bin/supervisord", "-c", "/supervisord.conf" ]