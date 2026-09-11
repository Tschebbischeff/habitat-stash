FROM nextcloud/aio-imaginary:latest

USER root:root

RUN apk upgrade --no-cache -a; \
    apk add --no-cache patch

COPY ./patches /habitat-patches
# RUN patch -f -r - "/start.sh" <"/habitat-patches/start.sh.patch"
RUN rm -rf /habitat-patches

USER nobody:nobody