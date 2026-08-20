#!/usr/bin/env bash

srpms_file=$1
SPOTIFY_VERSION=$2
SPOTIFY_BRANCH=$3
item=$4


distro="${item:0:2}"
release="${item:2}"

if [ "$distro" == "fc" ]; then
    mock_file="fedora-${release}-x86_64"
elif [ "$distro" == "el" ]; then
    mock_file="${ENTERPRISE_LINUX_BACKEND}+epel-${release}-x86_64"
fi


if [ ! -e "/etc/mock/${mock_file}.cfg" ]; then
    echo "BUILD: ${item} invalid!"
    exit 0
fi


if [ -e "$(ls /data/${release}/x86_64/${SPOTIFY_BRANCH}/Packages/spotify-client-${SPOTIFY_VERSION}*.x86_64.rpm 2> /dev/null)" ]; then
    echo "spotify-client:${SPOTIFY_VERSION} RPM to ${mock_file} exists, skip"
    exit 0
else
    echo "Building spotify-client:${SPOTIFY_VERSION} to ${mock_file}..."
    if [[ "$LOG_DEBUG" =~ ^(1|true|True|y|Y)$ ]]; then
        mock -r ${mock_file} --rebuild $srpms_file
    else
        mock -r ${mock_file} --rebuild $srpms_file &> /dev/null
    fi
fi

if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
    echo "Signing RPMs spotify-client:${SPOTIFY_VERSION} to ${mock_file}..."
    rpm --addsign /var/lib/mock/${mock_file}/result/spotify-client-${SPOTIFY_VERSION}*.x86_64.rpm
    rpm --addsign /var/lib/mock/${mock_file}/result/spotify-client-${SPOTIFY_VERSION}*.src.rpm
fi


mkdir -p /data/${release}/x86_64/${SPOTIFY_BRANCH}/Packages/
cp /var/lib/mock/${mock_file}/result/spotify-client-${SPOTIFY_VERSION}*.x86_64.rpm /data/${release}/x86_64/${SPOTIFY_BRANCH}/Packages/
remove_old_rpms.sh /data/${release}/x86_64/${SPOTIFY_BRANCH}/Packages
if [[ "$LOG_DEBUG" =~ ^(1|true|True|y|Y)$ ]]; then
    createrepo /data/${release}/x86_64/${SPOTIFY_BRANCH}/
else
    createrepo /data/${release}/x86_64/${SPOTIFY_BRANCH}/ &> /dev/null
fi

if [[ "$SRPMS_BUILDS" =~ ^(1|true|True|y|Y)$ ]]; then
    mkdir -p /data/${release}/source/${SPOTIFY_BRANCH}/Packages/
    cp /var/lib/mock/${mock_file}/result/spotify-client-${SPOTIFY_VERSION}*.src.rpm /data/${release}/source/${SPOTIFY_BRANCH}/Packages/
    remove_old_rpms.sh /data/${release}/source/${SPOTIFY_BRANCH}/Packages
    if [[ "$LOG_DEBUG" =~ ^(1|true|True|y|Y)$ ]]; then
        createrepo /data/${release}/source/${SPOTIFY_BRANCH}/
    else
        createrepo /data/${release}/source/${SPOTIFY_BRANCH}/ &> /dev/null
    fi
fi
mock -r ${mock_file} --clean &> /dev/null
echo "Finish: spotify-client, branch=${SPOTIFY_BRANCH}, version=${SPOTIFY_VERSION} to ${mock_file}!"

