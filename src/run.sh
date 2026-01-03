#!/usr/bin/env bash

releasever=$(python3 -c 'import dnf, json; db = dnf.dnf.Base(); data = json.loads(json.dumps(db.conf.substitutions, indent=2)); print(data["releasever"])')
export GPG_TTY=$(tty)

#GPG Key
if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
    echo "GPG key enabled!"
    echo "Importing GPG key..."

    gpg --import /gpg-key/private.pgp
    gpg --import /gpg-key/public.pgp
    

    cat > "/home/spotify/.rpmmacros" << RPMMACROS
%_signature gpg
%_gpg_name ${GPG_NAME}
%_gpgbin /usr/bin/gpg
RPMMACROS

    gpg --export -a "${GPG_EMAIL}" > /data/gpg

fi




while :
do
    check_latest_version.sh
    
    if [ "$(cat /tmp/spotify.version 2> /dev/null)" != "$(cat /tmp/spotify.version.old 2> /dev/null)" ]; then
        echo "New version found!"
        download_deb.sh
        build_SRPMS.sh $releasever
        cleanup.sh
    else
        echo "No new version found, skip"
    fi


    #Start interval
    echo "Start INTERVAL: ${INTERVAL}"
    sleep ${INTERVAL}
done
