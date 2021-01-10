FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.12

ARG ROTATE_BACKUPS_VERSION=8.1

RUN apk add --no-cache docker python3 rsyslog tar
RUN python3 -m ensurepip && \
    python3 -m pip install --no-cache-dir rotate-backups==${ROTATE_BACKUPS_VERSION} && \
    rm -rf \
        /root/.cache \
        /usr/lib/python*/ensurepip

COPY root/ /

RUN chmod 755 /usr/bin/make_backup.sh

HEALTHCHECK --interval=120s --timeout=10s --retries=3 \
    CMD /bin/sh /healthcheck.sh

VOLUME ["/config", "/data", "/backup"]

ENV CRONTAB="0 3 * * *" \
    PAUSE_CONTAINERS="" \
    PAUSE_CONTAINERS_WAIT_SECONDS=10 \
    TAR_EXCLUSIONS_FILE="tar-exclusions.txt"

ENTRYPOINT ["/init"]
