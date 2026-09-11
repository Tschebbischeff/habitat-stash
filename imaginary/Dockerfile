FROM nextcloud/aio-imaginary:latest

RUN apk upgrade --no-cache -a; \
    apk add --no-cache patch

COPY ./patches /habitat-patches
RUN patch "/start.sh" <"/habitat-patches/start.sh.patch"
RUN rm -rf /habitat-patches