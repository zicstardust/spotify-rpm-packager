#!/usr/bin/env bash

spotify_version=$(python3 -c 'from download_deb import parse_deb_control_file; result = parse_deb_control_file("/build/spotify.info"); print(result["Version"].replace("1:", ""))')
deb_file="/build/spotify-client_${spotify_version}_amd64.deb"
BUILD_DIR="/home/spotify/rpmbuild"
INSTALL_DIR="${BUILD_DIR}/BUILD/spotify-${spotify_version}/BUILDROOT"


# Create directory structure for rpmbuild
echo "Create directory structure for rpmbuild"
mkdir -p ${BUILD_DIR}/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# Copy .deb to SOURCES
cp $deb_file $BUILD_DIR/SOURCES

# Extract .deb manually
echo "Extract .deb"
ar x ${deb_file}
tar xf /build/data.tar.gz


# Create installation directory
mkdir -p ${INSTALL_DIR}/usr/bin
mkdir -p ${INSTALL_DIR}/usr/share/spotify
mkdir -p ${INSTALL_DIR}/usr/share/applications
mkdir -p ${INSTALL_DIR}/usr/share/icons/hicolor
mkdir -p ${INSTALL_DIR}/usr/share/appdata
mkdir -p ${INSTALL_DIR}/usr/share/man/man1


# Copy Spotify files
cp -ar /build/usr/share/spotify/* ${INSTALL_DIR}/usr/share/spotify/


# Create launcher script
cat > ${INSTALL_DIR}/usr/bin/spotify <<"EXEC"
#!/usr/bin/bash
# Spotify launcher with Fedora fixes

# Disable hardware acceleration that causes black screen
export SPOTIFY_CLEAN_CACHE=1

# Flags to improve compatibility
exec /usr/share/spotify/spotify \
    --disable-gpu-sandbox \
    --disable-seccomp-filter-sandbox \
    --no-zygote \
    "$@"
EXEC
chmod +x ${INSTALL_DIR}/usr/bin/spotify


# Create .desktop file
cat > ${INSTALL_DIR}/usr/share/applications/spotify.desktop <<DESKTOP
[Desktop Entry]
Type=Application
Name=Spotify
Version=${spotify_version}
GenericName=Music Player
Comment=Spotify streaming music client
Icon=spotify
Exec=spotify %U
Terminal=false
MimeType=x-scheme-handler/spotify;
Categories=Audio;Music;Player;AudioVideo;
StartupWMClass=spotify
DESKTOP


# Copy icons
for i in 16 22 24 32 48 64 128 256 512; do
if [ -f "/build/usr/share/spotify/icons/spotify-linux-${i}.png" ]; then
    mkdir -p ${INSTALL_DIR}/usr/share/icons/hicolor/${i}x${i}/apps
    cp /build/usr/share/spotify/icons/spotify-linux-${i}.png  ${INSTALL_DIR}/usr/share/icons/hicolor/${i}x${i}/apps/spotify.png
fi
done

# Create appdata.xml
cat > ${INSTALL_DIR}/usr/share/appdata/spotify.xml <<APPDATA
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop">
  <id>spotify.desktop</id>
  <metadata_license>CC0-1.0</metadata_license>
  <project_license>LicenseRef-proprietary</project_license>
  <name>Spotify</name>
  <summary>Online music streaming service</summary>
  <description>
    <p>Spotify is a digital music service that gives you access to millions of songs.</p>
  </description>
  <url type="homepage">https://www.spotify.com/</url>
</component>
APPDATA


#Create man page

cat > ${INSTALL_DIR}/usr/share/man/man1/spotify.1 <<"MAN"
TH SPOTIFY 1 "December 2025" "Spotify Client" "User Commands"
.SH NAME
spotify \- Spotify streaming music client
.SH SYNOPSIS
.B spotify
[\fIOPTIONS\fR]
.SH DESCRIPTION
Spotify is a digital music service that gives you access to millions of songs.
.SH OPTIONS
.TP
\fB\-\-help\fR
Show help options
.SH SEE ALSO
https://www.spotify.com/
MAN


# Adjust library permissions
chmod -R +x $INSTALL_DIR/usr/share/spotify/*.so


# Generate spec file
echo "Create spec file"
cat > ${BUILD_DIR}/SPECS/spotify.spec <<SPEC
%global debug_package %{nil}
%global __strip /bin/true

Name:           spotify-client
Version:        ${spotify_version}
Release:        1%{?dist}
Summary:        Spotify desktop client
License:        Proprietary
URL:            https://www.spotify.com/

Requires:       libatomic
Requires:       libayatana-appindicator-gtk3

%description
Spotify streaming music client.

%install
mkdir -p %{buildroot}
cp -a ${INSTALL_DIR}/* %{buildroot}/

%post
chmod -R a+wr %{_datadir}/spotify/ || true


%files
%{_bindir}/spotify
%{_datadir}/spotify/
%{_datadir}/applications/spotify.desktop
%{_datadir}/icons/hicolor/*/apps/spotify.png
%{_datadir}/appdata/spotify.xml
%{_mandir}/man1/spotify.1*

%changelog
* $(date +"%a %b %d %Y") Automated Build <builder@localhost> - ${spotify_version}-1
- Automated build of Spotify client ${spotify_version}
SPEC


#Delete trash files
rm -Rf ${INSTALL_DIR}/usr/share/spotify/icons
rm -f ${INSTALL_DIR}/usr/share/spotify/spotify.desktop
rm -Rf ${INSTALL_DIR}/usr/share/spotify/apt-keys


# Build the RPM
echo "building RPM..."
rpmbuild -bb --define "_topdir ${BUILD_DIR}" ${BUILD_DIR}/SPECS/spotify.spec 2>&1 | grep -E '(^Wrote:|^error:|^Error)' || true


if [[ -v $GPG_NAME ]] && [[ -v $GPG_EMAIL ]]; then
    echo "Sign RPM file..."
    rpm --addsign /home/spotify/rpmbuild/RPMS/x86_64/*.rpm
fi
