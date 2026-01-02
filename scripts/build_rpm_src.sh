#!/usr/bin/env bash

current_dir=$(pwd)
cd /tmp
spotify_version=$(cat /tmp/spotify.version)
deb_file="/tmp/spotify-client_${spotify_version}_amd64.deb"
BUILD_DIR="/home/spotify/rpmbuild"
#INSTALL_DIR="${BUILD_DIR}/BUILD/spotify-${spotify_version}/BUILDROOT"
SOURCES_DIR="${BUILD_DIR}/SOURCES"


# Create directory structure for rpmbuild
##echo "Create directory structure for rpmbuild"
##mkdir -p ${BUILD_DIR}/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# Copy .deb to SOURCES
#cp $deb_file $BUILD_DIR/SOURCES
##cp /build/copy_icons.sh ${SOURCES_DIR}/
##cp /build/generate_appdata.sh ${SOURCES_DIR}/
##cp /build/generate_bin.sh ${SOURCES_DIR}/
##cp /build/generate_desktopentry.sh ${SOURCES_DIR}/
##cp /build/generate_man.sh ${SOURCES_DIR}/


# Extract .deb manually
echo "Extract .deb"
ar x ${deb_file}
tar -xf data.tar.gz
mkdir spotify-client-${spotify_version}
mv usr spotify-client-${spotify_version}
tar -czf spotify-client-${spotify_version}.tar.gz spotify-client-${spotify_version}
cp spotify-client-${spotify_version}.tar.gz ${SOURCES_DIR}/
#tar xf /build/data.tar.gz


# Create installation directory
#mkdir -p ${INSTALL_DIR}/usr/bin
#mkdir -p ${INSTALL_DIR}/usr/share/spotify
#mkdir -p ${INSTALL_DIR}/usr/share/applications
#mkdir -p ${INSTALL_DIR}/usr/share/icons/hicolor
#mkdir -p ${INSTALL_DIR}/usr/share/appdata
#mkdir -p ${INSTALL_DIR}/usr/share/man/man1


# Copy Spotify files
#cp -ar /build/usr/share/spotify/* ${INSTALL_DIR}/usr/share/spotify/


# Create launcher script


# Create .desktop file



# Copy icons

# Create appdata.xml


#Create man page



# Adjust library permissions
#chmod -R +x $SOURCES_DIR/usr/share/spotify/*.so


# Generate spec file
echo "Create spec file"
generate_spec.sh ${BUILD_DIR}/SPECS/spotify.spec $spotify_version


#Delete trash files
#rm -Rf ${INSTALL_DIR}/usr/share/spotify/icons
#rm -f ${INSTALL_DIR}/usr/share/spotify/spotify.desktop
#rm -Rf ${INSTALL_DIR}/usr/share/spotify/apt-keys


# Build the RPM
#echo "building RPM..."
#rpmbuild -bb --define "_topdir ${BUILD_DIR}" ${BUILD_DIR}/SPECS/spotify.spec 2>&1 | grep -E '(^Wrote:|^error:|^Error)' || true
#rpmbuild -bb --define "_topdir ${BUILD_DIR}" ${BUILD_DIR}/SPECS/spotify.spec

echo "building SRC RPM..."
rpmbuild -bs --define "_topdir ${BUILD_DIR}" ${BUILD_DIR}/SPECS/spotify.spec

#Copy RPM Source to repository
echo "Copy RPM Source to repository"
mkdir -p /data/src/source/stable/Packages
cp  ${BUILD_DIR}/SRPMS/*.rpm /data/src/source/stable/Packages/


if [[ -v $GPG_NAME ]] && [[ -v $GPG_EMAIL ]]; then
    echo "Sign RPM file..."
    #rpm --addsign /home/spotify/rpmbuild/RPMS/x86_64/*.rpm
    rpm --addsign /data/src/source/stable/Packages/*.rpm
fi

cd $current_dir
