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

export STABLE_BUILDS
export TESTING_BUILDS
export SRPMS_BUILDS
export BUILTIN_FFMPEG
export BUILD
export LOG_DEBUG
export ENTERPRISE_LINUX_BACKEND

export BUILD_DIR="/home/spotify/rpmbuild"
export SOURCES_DIR="${BUILD_DIR}/SOURCES"

#GPG Key
if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
    export GPG_TTY=$(tty)

if [[ "$LOG_DEBUG" =~ ^(1|true|True|y|Y)$ ]]; then
    gpg --import /gpg-key/private.pgp 
    gpg --import /gpg-key/public.pgp
else
    gpg --import /gpg-key/private.pgp &> /dev/null
    gpg --import /gpg-key/public.pgp &> /dev/null
fi

    gpg --export -a "${GPG_EMAIL}" > /data/gpg

    set_rpmmacros.sh
fi

if [ "$REPO_FILE_URL" ]; then
    echo "Generating repo file..."
    generate_repofile.sh
fi

check_if_all_builds_exist(){
    distros=$1
    SPOTIFY_BRANCH=$2
    SPOTIFY_VERSION=$3
    
    for item in "${distros[@]}"; do

        release="${item:2}"

        if ! [ "$(ls /data/${release}/x86_64/${SPOTIFY_BRANCH}/Packages/spotify-client-${SPOTIFY_VERSION}*.x86_64.rpm 2> /dev/null)" ]; then
            echo "false"
            return
        fi

        if [[ "$SRPMS_BUILDS" =~ ^(1|true|True|y|Y)$ ]]; then
            if ! [ "$(ls /data/${release}/source/${SPOTIFY_BRANCH}/Packages/spotify-client-${SPOTIFY_VERSION}*.src.rpm 2> /dev/null)" ]; then
                echo "false"
                return
            fi
        fi
    done
    echo "true"
    return
}


build_RPM(){

    SPOTIFY_BRANCH=$1

    parser_debian_control_file.py $SPOTIFY_BRANCH spotify-client Version
    SPOTIFY_VERSION=$(cat /tmp/spotify-client.${SPOTIFY_BRANCH}.Version)
    IFS="," read -ra distros <<< "$BUILD"

    check_builds=$(check_if_all_builds_exist $distros $SPOTIFY_BRANCH $SPOTIFY_VERSION) 

    if [ "$check_builds" = "true" ]; then
        echo "Not Found new .deb ${SPOTIFY_BRANCH} version, skip"
        return
    fi
    
    echo "New .deb ${SPOTIFY_BRANCH} version found!"
    download_deb.sh $SPOTIFY_BRANCH $SPOTIFY_VERSION
    build_SRPM.sh $SPOTIFY_BRANCH $SPOTIFY_VERSION    

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
    if [[ "$INTERVAL" =~ ^(false|False|n|N)$ ]]; then
        echo "Interval disable, exit"
        exit 0
    else
        echo "Start INTERVAL: ${INTERVAL}"
        sleep ${INTERVAL}
    fi
done
