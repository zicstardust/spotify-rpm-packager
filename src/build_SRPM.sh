#!/usr/bin/env bash

SPOTIFY_BRANCH=$1
SPOTIFY_VERSION=$2

#https://github.com/zicstardust/spotify-debfixes/releases
if [ "$SPOTIFY_BRANCH" == "stable" ]; then
    ffmpeg_spotify_release="7.1.5"
elif [ "$SPOTIFY_BRANCH" == "testing" ]; then
    ffmpeg_spotify_release="7.1.5"
fi

current_dir=$(pwd)
cd /tmp
deb_file="/tmp/spotify-client_${SPOTIFY_VERSION}_amd64.deb"

# Extract .deb
echo "Extracting .deb..."
ar x ${deb_file}
tar -xf data.tar.gz
mkdir spotify-client-${SPOTIFY_VERSION}
mv usr spotify-client-${SPOTIFY_VERSION}

#Delete apt-keys folder
rm -Rf spotify-client-${SPOTIFY_VERSION}/usr/share/spotify/apt-keys

#Include FFMPEG libraries
if [[ "$BUILTIN_FFMPEG" =~ ^(1|true|True|y|Y)$ ]]; then
    echo "Including FFMPEG ${ffmpeg_spotify_release} libraries..."
    mkdir -p spotify-client-${SPOTIFY_VERSION}/usr/share/spotify/ffmpeg
    if [ "$LOG_LEVEL" = "all" ]; then
        tar -xzf /tmp/ffmpeg_libs.tar.gz  -C spotify-client-${SPOTIFY_VERSION}/usr/share/spotify/ffmpeg
    else
        tar -xzf /tmp/ffmpeg_libs.tar.gz  -C spotify-client-${SPOTIFY_VERSION}/usr/share/spotify/ffmpeg &> /dev/null
    fi
fi

# Generate Desktop Entry
generate_desktopentry.sh spotify-client-${SPOTIFY_VERSION}/usr/share/applications ${SPOTIFY_VERSION}
rm -f spotify-client-${SPOTIFY_VERSION}/usr/share/spotify/spotify.desktop

#Copy icons
copy_icons.sh spotify-client-${SPOTIFY_VERSION}/usr/share/spotify/icons spotify-client-${SPOTIFY_VERSION}/usr/share/icons
rm -Rf spotify-client-${SPOTIFY_VERSION}/usr/share/spotify/icons
mkdir -p spotify-client-${SPOTIFY_VERSION}/usr/share/icons/hicolor/scalable/apps
cp -ar /usr/local/bin/spotify-client.svg spotify-client-${SPOTIFY_VERSION}/usr/share/icons/hicolor/scalable/apps/


# Generate man page
generate_man.sh spotify-client-${SPOTIFY_VERSION}/usr/share/man/man1

# Generate appdata
generate_appdata.sh spotify-client-${SPOTIFY_VERSION}/usr/share/appdata ${SPOTIFY_VERSION}


# Genarate bin
rm -f spotify-client-${SPOTIFY_VERSION}/usr/bin/spotify
generate_bin.sh spotify-client-${SPOTIFY_VERSION}/usr/bin $BUILTIN_FFMPEG
generate_generate_flags_file.sh spotify-client-${SPOTIFY_VERSION}/usr/share/spotify/
generate_generate_envs_file.sh spotify-client-${SPOTIFY_VERSION}/usr/share/spotify/


#Create and move spotify-client.tar.gz to SOURCES
tar -czf spotify-client-${SPOTIFY_VERSION}.tar.gz spotify-client-${SPOTIFY_VERSION}
cp spotify-client-${SPOTIFY_VERSION}.tar.gz ${SOURCES_DIR}/

# Generate spec file
echo "Create spec file"
generate_spec.sh ${BUILD_DIR}/SPECS/spotify.spec $SPOTIFY_VERSION


echo "Building SRPMS spotify-client:${SPOTIFY_VERSION}..."
if [ "$LOG_LEVEL" = "all" ]; then
    rpmbuild -bs --define "_topdir ${BUILD_DIR}" ${BUILD_DIR}/SPECS/spotify.spec
else
    rpmbuild -bs --define "_topdir ${BUILD_DIR}" ${BUILD_DIR}/SPECS/spotify.spec &> /dev/null
fi

cd $current_dir

