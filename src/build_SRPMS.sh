#!/usr/bin/env bash

SPOTIFY_BRANCH=$1

#https://github.com/zicstardust/spotify-debfixes/releases
if [ "$SPOTIFY_BRANCH" == "stable" ]; then
    ffmpeg_spotify_release="1.0"
elif [ "$SPOTIFY_BRANCH" == "testing" ]; then
    ffmpeg_spotify_release="1.0"
fi

current_dir=$(pwd)
cd /tmp
spotify_version=$(cat /tmp/spotify-client.${SPOTIFY_BRANCH}.Version)
deb_file="/tmp/spotify-client_${spotify_version}_amd64.deb"
BUILD_DIR="/home/spotify/rpmbuild"
SOURCES_DIR="${BUILD_DIR}/SOURCES"


# Extract .deb
echo "Extracting .deb..."
ar x ${deb_file}
tar -xf data.tar.gz
mkdir spotify-client-${spotify_version}
mv usr spotify-client-${spotify_version}

#Delete apt-keys folder
rm -Rf spotify-client-${spotify_version}/usr/share/spotify/apt-keys

#Include FFMPEG libraries
if [[ "$BUILTIN_FFMPEG" =~ ^(1|true|True|y|Y)$ ]]; then
    echo "Including FFMPEG libraries..."
    curl -fSL "https://github.com/zicstardust/spotify-debfixes/releases/download/${ffmpeg_spotify_release}/spotify_ffmpeg_libs_linux_x86_64.tar.gz" -o "/tmp/ffmpeg_libs.tar.gz" &> /dev/null
    mkdir -p spotify-client-${spotify_version}/usr/share/spotify/ffmpeg
    tar -xzf /tmp/ffmpeg_libs.tar.gz  -C spotify-client-${spotify_version}/usr/share/spotify/ffmpeg &> /dev/null
fi

# Generate Desktop Entry
generate_desktopentry.sh spotify-client-${spotify_version}/usr/share/applications ${spotify_version}
rm -f spotify-client-${spotify_version}/usr/share/spotify/spotify.desktop

#Copy icons
copy_icons.sh spotify-client-${spotify_version}/usr/share/spotify/icons spotify-client-${spotify_version}/usr/share/icons
rm -Rf spotify-client-${spotify_version}/usr/share/spotify/icons
mkdir -p spotify-client-${spotify_version}/usr/share/icons/hicolor/scalable/apps
cp -ar /usr/local/bin/spotify-client.svg spotify-client-${spotify_version}/usr/share/icons/hicolor/scalable/apps/


# Generate man page
generate_man.sh spotify-client-${spotify_version}/usr/share/man/man1

# Generate appdata
generate_appdata.sh spotify-client-${spotify_version}/usr/share/appdata ${spotify_version}


# Genarate bin
rm -f spotify-client-${spotify_version}/usr/bin/spotify
generate_bin.sh spotify-client-${spotify_version}/usr/bin $BUILTIN_FFMPEG
generate_generate_flags_file.sh spotify-client-${spotify_version}/usr/share/spotify/
generate_generate_envs_file.sh spotify-client-${spotify_version}/usr/share/spotify/


#Create and move spotify-client.tar.gz to SOURCES
tar -czf spotify-client-${spotify_version}.tar.gz spotify-client-${spotify_version}
cp spotify-client-${spotify_version}.tar.gz ${SOURCES_DIR}/

# Generate spec file
echo "Create spec file"
generate_spec.sh ${BUILD_DIR}/SPECS/spotify.spec $spotify_version


echo "Building SRPMS spotify-client:${spotify_version}..."
rpmbuild -bs --define "_topdir ${BUILD_DIR}" ${BUILD_DIR}/SPECS/spotify.spec &> /dev/null

cd $current_dir

build_RPMS_mock.sh $(ls ${BUILD_DIR}/SRPMS/spotify-client-${spotify_version}*.src.rpm) $spotify_version $SPOTIFY_BRANCH