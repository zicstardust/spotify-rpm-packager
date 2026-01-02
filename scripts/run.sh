#!/usr/bin/env bash

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
    download_deb.py
    build_rpm_src.sh


    #copy RPM
    echo "copy RPM to /data"
    copy_rpm_to_repo.sh
    

    #cleanup
    cleanup.sh

    if [ "$DISABLE_WEB_SERVER" != "1" ]; then
        echo "update metadata repository..."
        for i in $(ls /data); do
            if [ "$i" != "src" ]; then
                createrepo /data/$i/x86_64/stable
            fi
        done
            createrepo /data/src/source/stable
    fi


    #Start interval
    echo "Start INTERVAL: ${INTERVAL}"
    sleep ${INTERVAL}
done
