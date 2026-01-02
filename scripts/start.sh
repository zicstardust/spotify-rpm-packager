#!/bin/bash

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
    python3 /build/download_deb.py
    /build/build_rpm.sh


    #copy RPM
    echo "copy RPM to /data"
    /build/copy_rpm_to_repo.sh
    

    #cleanup
    echo "cleanup..."
    rm -f /build/spotify.info
    rm -Rf /build/spotify*.deb
    rm -f /build/data.tar.gz
    rm -f /build/control.tar.gz
    rm -f /build/debian-binary
    rm -Rf /build/usr

    rm -Rf /home/spotify/rpmbuild

    if [ "$DISABLE_WEB_SERVER" != "1" ]; then
        echo "update metadata repository..."
        for i in $(ls /data); do
            createrepo /data/$i/x86_64/stable
        done
    fi


    #Start interval
    echo "Start INTERVAL: ${INTERVAL}"
    sleep ${INTERVAL}
done
