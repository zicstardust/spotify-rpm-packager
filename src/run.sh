#!/usr/bin/env bash

set -e
: "${INTERVAL:=1d}"


#GPG Key
if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
    
    export GPG_TTY=$(tty)

    gpg --import /gpg-key/private.pgp
    gpg --import /gpg-key/public.pgp
    
    gpg --export -a "${GPG_EMAIL}" > /data/gpg

    set_rpmmacros.sh
fi




while :
do
    check_latest_version.sh
    
    if [ "$(cat /tmp/spotify.version 2> /dev/null)" != "$(cat /tmp/spotify.version.old 2> /dev/null)" ]; then
        echo "New .deb version found!"
        download_deb.sh
        build_SRPMS.sh
        cleanup.sh
    else
        echo "New .deb version not found, skip"
    fi


    #Start interval
    echo "Start INTERVAL: ${INTERVAL}"
    sleep ${INTERVAL}
done
