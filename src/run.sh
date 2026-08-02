#!/usr/bin/env bash

set -e
: "${INTERVAL:=1d}"
: "${STABLE_BUILDS:=true}"
: "${TESTING_BUILDS:=false}"
: "${SRPMS_BUILDS:=false}"
: "${BUILTIN_FFMPEG:=true}"
: "${BUILD:=el10}"
: "${LOG_DEBUG:=false}"
: "${ENTERPRISE_LINUX_BACKEND:=alma}"

if [[ "$LOG_DEBUG" =~ ^(1|true|True|y|Y)$ ]]; then
    output=""
else
    output="&> /dev/null"
fi


export STABLE_BUILDS
export TESTING_BUILDS
export SRPMS_BUILDS
export BUILTIN_FFMPEG
export BUILD
export output
export ENTERPRISE_LINUX_BACKEND

export BUILD_DIR="/home/spotify/rpmbuild"
export SOURCES_DIR="${BUILD_DIR}/SOURCES"

#GPG Key
if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
    
    export GPG_TTY=$(tty)

    gpg --import /gpg-key/private.pgp $output
    gpg --import /gpg-key/public.pgp $output
    
    gpg --export -a "${GPG_EMAIL}" > /data/gpg

    set_rpmmacros.sh
fi


build_RPM(){

    SPOTIFY_BRANCH=$1
    parser_debian_control_file.py $SPOTIFY_BRANCH spotify-client Version
    SPOTIFY_VERSION=$(cat /tmp/spotify-client.${SPOTIFY_BRANCH}.Version)

    if [ "$(ls ${BUILD_DIR}/SRPMS/spotify-client-${SPOTIFY_VERSION}*.src.rpm 2> /dev/null)" ]; then
        echo "Not Found new .deb ${SPOTIFY_BRANCH} version, skip"
    else
        echo "New .deb ${SPOTIFY_BRANCH} version found!"
        download_deb.sh $SPOTIFY_BRANCH $SPOTIFY_VERSION
        build_SRPM.sh $SPOTIFY_BRANCH $SPOTIFY_VERSION
    fi
    
    IFS="," read -ra distros <<< "$BUILD"

    for item in "${distros[@]}"; do
        build_RPM.sh $(ls ${BUILD_DIR}/SRPMS/spotify-client-${SPOTIFY_VERSION}*.src.rpm) $SPOTIFY_VERSION $SPOTIFY_BRANCH $item
    done

    cleanup.sh
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
