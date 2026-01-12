#!/usr/bin/env bash

SPEC_FILE=$1
spotify_version=$2


if [[ "$BUILTIN_FFMPEG" =~ ^(1|true|True|y|Y)$ ]]; then
    RECOMMENDS_FFMPEG1=""
    RECOMMENDS_FFMPEG2=""
else
    RECOMMENDS_FFMPEG1="Recommends:       (compat-ffmpeg4 if rpmfusion-free-release else ffmpeg-free)"
    RECOMMENDS_FFMPEG2="Recommends:       (ffmpeg-libs if rpmfusion-free-release else (libavcodec-free and libavformat-free))"
fi

cat > ${SPEC_FILE} <<SPEC
%global debug_package %{nil}
%global __strip /bin/true

Name:           spotify-client
Version:        ${spotify_version}
Release:        1%{?dist}
Summary:        Spotify desktop client
License:        Proprietary
URL:            https://www.spotify.com/
ExclusiveArch:  x86_64
Source0:        spotify-client-%{version}.tar.gz
Source1:        copy_icons.sh
Source2:        generate_desktopentry.sh
Source3:        generate_man.sh
Source4:        generate_appdata.sh
Source5:        generate_bin.sh
Source6:        spotify-client.svg

BuildRequires:  tar
BuildRequires:  bash


Requires:       bash
Requires:       glibc
Requires:       alsa-lib
Requires:       at-spi2-atk
Requires:       libatomic
Requires:       mesa-libgbm
Requires:       glib2
Requires:       gtk3
Requires:       nss
Requires:       libxshmfence
Requires:       libXScrnSaver
Requires:       libXtst
Requires:       xdg-utils
Requires:       libayatana-appindicator-gtk3


$RECOMMENDS_FFMPEG1
$RECOMMENDS_FFMPEG2

Suggests:       libnotify


%description
Spotify streaming music client.


%prep
%setup

%install
mkdir -p %{buildroot}/usr/share/spotify/
cp -ar usr/share/spotify/* %{buildroot}/usr/share/spotify/
%{_sourcedir}/generate_desktopentry.sh %{buildroot}/usr/share/applications %{version}
%{_sourcedir}/copy_icons.sh usr/share/spotify/icons %{buildroot}/usr/share/icons
mkdir -p %{buildroot}/usr/share/icons/hicolor/scalable/apps
cp -ar %{_sourcedir}/spotify-client.svg %{buildroot}/usr/share/icons/hicolor/scalable/apps/
%{_sourcedir}/generate_appdata.sh %{buildroot}/usr/share/appdata %{version}
%{_sourcedir}/generate_man.sh %{buildroot}/usr/share/man/man1
%{_sourcedir}/generate_bin.sh %{buildroot}/usr/bin $BUILTIN_FFMPEG
chmod -R +x %{buildroot}/usr/share/spotify/*.so
rm -Rf %{buildroot}/usr/share/spotify/icons
rm -f %{buildroot}/usr/share/spotify/spotify.desktop
rm -Rf %{buildroot}/usr/share/spotify/apt-keys

%post
chmod -R a+wr %{_datadir}/spotify/ || true


%files
%{_bindir}/spotify
%{_datadir}/spotify/
%{_datadir}/applications/spotify.desktop
%{_datadir}/icons/hicolor/scalable/apps/spotify-client.svg
%{_datadir}/icons/hicolor/*/apps/spotify-client.png
%{_datadir}/appdata/spotify.appdata.xml
%{_mandir}/man1/spotify.1*

%changelog
* $(date +"%a %b %d %Y") Automated Build <${GPG_EMAIL:-builder@localhost}> - ${spotify_version}-1
- Automated build of Spotify client ${spotify_version}
SPEC
