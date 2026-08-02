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

BuildRequires:  tar
BuildRequires:  bash


Requires:       bash
Requires:       grep
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
mkdir -p %{buildroot}/
cp -ar * %{buildroot}/
chmod -R +x %{buildroot}/usr/share/spotify/*.so
chmod +x %{buildroot}/usr/share/spotify/generate_flags_file.sh
chmod +x %{buildroot}/usr/share/spotify/generate_envs_file.sh
chmod +x %{buildroot}/usr/bin/spotify

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
