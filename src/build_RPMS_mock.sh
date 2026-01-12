#!/usr/bin/env bash

srpms_file=$1
spotify_version=$2
SPOTIFY_BRANCH=$3

set -e
: "${BUILD:=fc43}"


IFS="," read -ra distros <<< "$BUILD"


mock_config(){
    local config=$1
    local distro=$2

    if [ "$distro" == "fc42" ]; then
        mock_config_file="fedora-42-x86_64"
        releasever="42"
    elif [ "$distro" == "fc43" ]; then
        mock_config_file="fedora-43-x86_64"
        releasever="43"
    elif [ "$distro" == "fc44" ]; then
        mock_config_file="fedora-44-x86_64"
        releasever="44"
    elif [ "$distro" == "rawhide" ]; then
        mock_config_file="fedora-rawhide-x86_64"
        releasever="44"
    elif [ "$distro" == "el10" ]; then
        mock_config_file="alma+epel-10-x86_64"
        releasever="10"
    else
        echo "BUILD: ${distro} invalid!"
        exit 1
    fi


    if [ "$config" == "mock_config_file" ]; then
        echo $mock_config_file
    elif [ "$config" == "releasever" ]; then
        echo $releasever
    fi
}


for item in "${distros[@]}"; do
    if [ -e "$(ls /data/$(mock_config releasever $item)/x86_64/${SPOTIFY_BRANCH}/Packages/spotify-client-${spotify_version}*.x86_64.rpm 2> /dev/null)" ]; then
        echo "spotify-client:${spotify_version} RPM to $(mock_config mock_config_file $item) exists, skip"
        continue
    else
        echo "Building spotify-client:${spotify_version} to $(mock_config mock_config_file $item)..."
        mock -r $(mock_config mock_config_file $item) --rebuild $srpms_file &> /dev/null
    fi

    if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
        echo "Signing RPMs spotify-client:${spotify_version} to $(mock_config mock_config_file $item)..."
        rpm --addsign /var/lib/mock/$(mock_config mock_config_file $item)/result/spotify-client-${spotify_version}*.x86_64.rpm
        rpm --addsign /var/lib/mock/$(mock_config mock_config_file $item)/result/spotify-client-${spotify_version}*.src.rpm
    fi


    mkdir -p /data/$(mock_config releasever $item)/x86_64/${SPOTIFY_BRANCH}/Packages/
    cp /var/lib/mock/$(mock_config mock_config_file $item)/result/spotify-client-${spotify_version}*.x86_64.rpm /data/$(mock_config releasever $item)/x86_64/${SPOTIFY_BRANCH}/Packages/
    remove_old_rpms.sh /data/$(mock_config releasever $item)/x86_64/${SPOTIFY_BRANCH}/Packages
    createrepo /data/$(mock_config releasever $item)/x86_64/${SPOTIFY_BRANCH}/ &> /dev/null

    if [[ "$SRPMS_BUILDS" =~ ^(1|true|True|y|Y)$ ]]; then
        mkdir -p /data/$(mock_config releasever $item)/source/${SPOTIFY_BRANCH}/Packages/
        cp /var/lib/mock/$(mock_config mock_config_file $item)/result/spotify-client-${spotify_version}*.src.rpm /data/$(mock_config releasever $item)/source/${SPOTIFY_BRANCH}/Packages/
        remove_old_rpms.sh /data/$(mock_config releasever $item)/source/${SPOTIFY_BRANCH}/Packages
        createrepo /data/$(mock_config releasever $item)/source/${SPOTIFY_BRANCH}/ &> /dev/null
    fi

    echo "Finish: spotify-client, branch=${SPOTIFY_BRANCH}, version=${spotify_version} to $(mock_config mock_config_file $item)!"
done
