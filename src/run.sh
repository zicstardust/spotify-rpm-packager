#!/usr/bin/env bash

releasever=$(python3 -c 'import dnf, json; db = dnf.dnf.Base(); data = json.loads(json.dumps(db.conf.substitutions, indent=2)); print(data["releasever"])')
export GPG_TTY=$(tty)

#GPG Key
if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
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
        build_SRPMS.sh $releasever
        cleanup.sh
    else
        echo "New .deb version not found, skip"
    fi


    #Start interval
    echo "Start INTERVAL: ${INTERVAL}"
    sleep ${INTERVAL}
done
