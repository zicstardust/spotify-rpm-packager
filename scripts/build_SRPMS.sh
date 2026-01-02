#!/usr/bin/env bash

releasever=$1
current_dir=$(pwd)
cd /tmp
spotify_version=$(cat /tmp/spotify.version)
deb_file="/tmp/spotify-client_${spotify_version}_amd64.deb"
BUILD_DIR="/home/spotify/rpmbuild"
SOURCES_DIR="${BUILD_DIR}/SOURCES"


# Extract .deb manually
echo "Extract .deb"
ar x ${deb_file}
tar -xf data.tar.gz
mkdir spotify-client-${spotify_version}
mv usr spotify-client-${spotify_version}
tar -czf spotify-client-${spotify_version}.tar.gz spotify-client-${spotify_version}
cp spotify-client-${spotify_version}.tar.gz ${SOURCES_DIR}/

# Generate spec file
echo "Create spec file"
generate_spec.sh ${BUILD_DIR}/SPECS/spotify.spec $spotify_version


echo "building SRPM..."
rpmbuild -bs --define "_topdir ${BUILD_DIR}" ${BUILD_DIR}/SPECS/spotify.spec

cd $current_dir

build_RPMS_mock.sh ${BUILD_DIR}/SRPMS/spotify-client-${spotify_version}-1.fc$releasever.src.rpm $spotify_version