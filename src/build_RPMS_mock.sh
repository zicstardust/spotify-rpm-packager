#!/usr/bin/env bash

srpms_file=$1
spotify_version=$2
SPOTIFY_BRANCH=$3


IFS="," read -ra distros <<< "$BUILD"


for item in "${distros[@]}"; do

    distro="${item:0:2}"
    release="${item:2}"

    if [ "$distro" == "fc" ]; then
        mock_file="fedora-${release}-x86_64"
    elif [ "$distro" == "el" ]; then
        mock_file="alma+epel-${release}-x86_64"
    fi


    if [ ! -e "/etc/mock/${mock_file}.cfg" ]; then
        echo "BUILD: ${item} invalid!"
        continue
    fi


    if [ -e "$(ls /data/${release}/x86_64/${SPOTIFY_BRANCH}/Packages/spotify-client-${spotify_version}*.x86_64.rpm 2> /dev/null)" ]; then
        echo "spotify-client:${spotify_version} RPM to ${mock_file} exists, skip"
        continue
    else
        echo "Building spotify-client:${spotify_version} to ${mock_file}..."
        mock -r ${mock_file} --rebuild $srpms_file &> /dev/null
    fi

    if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
        echo "Signing RPMs spotify-client:${spotify_version} to ${mock_file}..."
        rpm --addsign /var/lib/mock/${mock_file}/result/spotify-client-${spotify_version}*.x86_64.rpm
        rpm --addsign /var/lib/mock/${mock_file}/result/spotify-client-${spotify_version}*.src.rpm
    fi


    mkdir -p /data/${release}/x86_64/${SPOTIFY_BRANCH}/Packages/
    cp /var/lib/mock/${mock_file}/result/spotify-client-${spotify_version}*.x86_64.rpm /data/${release}/x86_64/${SPOTIFY_BRANCH}/Packages/
    remove_old_rpms.sh /data/${release}/x86_64/${SPOTIFY_BRANCH}/Packages
    createrepo /data/${release}/x86_64/${SPOTIFY_BRANCH}/ &> /dev/null

    if [[ "$SRPMS_BUILDS" =~ ^(1|true|True|y|Y)$ ]]; then
        mkdir -p /data/${release}/source/${SPOTIFY_BRANCH}/Packages/
        cp /var/lib/mock/${mock_file}/result/spotify-client-${spotify_version}*.src.rpm /data/${release}/source/${SPOTIFY_BRANCH}/Packages/
        remove_old_rpms.sh /data/${release}/source/${SPOTIFY_BRANCH}/Packages
        createrepo /data/${release}/source/${SPOTIFY_BRANCH}/ &> /dev/null
    fi

    echo "Finish: spotify-client, branch=${SPOTIFY_BRANCH}, version=${spotify_version} to ${mock_file}!"
done
