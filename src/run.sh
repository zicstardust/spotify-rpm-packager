#!/usr/bin/env bash

set -e
: "${INTERVAL:=1d}"
: "${STABLE_BUILDS:=true}"
: "${TESTING_BUILDS:=false}"
: "${SRPMS_BUILDS:=false}"


export STABLE_BUILDS
export TESTING_BUILDS
export SRPMS_BUILDS

#GPG Key
if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
    
    export GPG_TTY=$(tty)

    gpg --import /gpg-key/private.pgp
    gpg --import /gpg-key/public.pgp
    
    gpg --export -a "${GPG_EMAIL}" > /data/gpg

    set_rpmmacros.sh
fi


build_RPM(){

    SPOTIFY_BRANCH=$1

    parser_debian_control_file.py $SPOTIFY_BRANCH spotify-client Version
    
    if [ "$(cat /tmp/spotify-client.${SPOTIFY_BRANCH}.Version 2> /dev/null)" != "$(cat /tmp/spotify-client.${SPOTIFY_BRANCH}.Version.old 2> /dev/null)" ]; then
        echo "New .deb ${SPOTIFY_BRANCH} version found!"
        download_deb.sh $SPOTIFY_BRANCH
        build_SRPMS.sh $SPOTIFY_BRANCH
        cleanup.sh $SPOTIFY_BRANCH
    else
        echo "New .deb ${SPOTIFY_BRANCH} version not found, skip"
    fi
}



while :
do

    if [[ "$STABLE_BUILDS" =~ ^(1|true|True|y|Y)$ ]]; then
        build_RPM stable
    else
        echo "Skip build stable RPM"
    fi

    if [[ "$TESTING_BUILDS" =~ ^(1|true|True|y|Y)$ ]]; then
        build_RPM testing
    else
        echo "Skip build testing RPM"
    fi

    #Start interval
    echo "Start INTERVAL: ${INTERVAL}"
    sleep ${INTERVAL}
done
