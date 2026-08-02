#!/usr/bin/env bash

set -e
: "${INTERVAL:=1d}"
: "${STABLE_BUILDS:=true}"
: "${TESTING_BUILDS:=false}"
: "${SRPMS_BUILDS:=false}"
: "${BUILTIN_FFMPEG:=true}"
: "${BUILD:=el10}"


export STABLE_BUILDS
export TESTING_BUILDS
export SRPMS_BUILDS
export BUILTIN_FFMPEG
export BUILD

#GPG Key
if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
    
    export GPG_TTY=$(tty)

    gpg --import /gpg-key/private.pgp &> /dev/null
    gpg --import /gpg-key/public.pgp &> /dev/null
    
    gpg --export -a "${GPG_EMAIL}" > /data/gpg

    set_rpmmacros.sh
fi


build_RPM(){

    SPOTIFY_BRANCH=$1

    parser_debian_control_file.py $SPOTIFY_BRANCH spotify-client Version
    spotify_version=$(cat /tmp/spotify-client.${SPOTIFY_BRANCH}.Version)

    if [ "$(ls /data/*/*/${SPOTIFY_BRANCH}/Packages/spotify-client-${spotify_version}-1.*.rpm 2> /dev/null)" ]; then
        echo "New .deb ${SPOTIFY_BRANCH} version not found, skip"
    else
        echo "New .deb ${SPOTIFY_BRANCH} version found!"
        download_deb.sh $SPOTIFY_BRANCH
        build_SRPMS.sh $SPOTIFY_BRANCH
        cleanup.sh
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
