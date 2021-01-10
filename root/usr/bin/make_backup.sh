#!/bin/bash

log() {
  level=$1
  shift
  echo "$(date -Iseconds) ${level} $*"
}

backup_src="/data"
backup_dest="/backup"
backup_file="${backup_dest}/$(date +%Y-%m-%dT%H:%M:%S).tar.gz"

exclusion_opts=( )

if [[ -f "/config/${TAR_EXCLUSIONS_FILE}" ]]; then
    while read line; do
        [[ -z "${line}" ]] && continue
        if [[ $line == /* ]]; then
            line="${backup_src}${line}";
        fi

        exclusion_opts+=( --exclude="$line" )
    done < "/config/${TAR_EXCLUSIONS_FILE}"
fi

if [[ -n "${PAUSE_CONTAINERS}" ]]; then
    unpause() {
        log INFO "Unpausing containers '${PAUSE_CONTAINERS}'..."

        docker unpause "$PAUSE_CONTAINERS"
        if [ $? = 0 ]; then
            log INFO "Unpausing containers done."
        else
            log ERROR "Unpausing containers failed."
            exit 1
        fi
    }

    log INFO "Pausing containers '${PAUSE_CONTAINERS}'..."

    docker pause "$PAUSE_CONTAINERS"

    if [ $? = 0 ]; then
        trap unpause EXIT

        log INFO "Pausing containers done."
        log INFO "Wait ${PAUSE_CONTAINERS_WAIT_SECONDS} seconds to settle down."
        sleep "$PAUSE_CONTAINERS_WAIT_SECONDS"
    else
        log ERROR "Pausing containers failed. Exiting."
        exit 1
    fi
fi

log INFO "Archiving data..."
tar \
    --gzip \
    --create \
    --preserve-permissions \
    --file="${backup_file}" \
    --directory="${backup_src}/.." \
    "${exclusion_opts[@]}" \
    "${backup_src}"

if [ $? = 0 ]; then
    log INFO "Archive created: ${backup_file}"
    log INFO "Setting permissions..."

    chown abc:abc "${backup_file}" && \
        chmod 644 "${backup_file}"
else
    log ERROR "Backup archive failed."
fi

log INFO "Rotating backups..."
/usr/bin/rotate-backups -c /config/rotate-backup.ini

if [ $? = 0 ]; then
    log INFO "Backup rotation done."
else
    log ERROR "Backup rotation failed."
fi
