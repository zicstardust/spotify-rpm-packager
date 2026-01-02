#!/usr/bin/env bash

destine_dir=$1
version=$2

mkdir -p ${destine_dir}
cat > ${destine_dir}/spotify.desktop <<DESKTOP
[Desktop Entry]
Type=Application
Name=Spotify
Version=${version}
GenericName=Music Player
Comment=Spotify streaming music client
Icon=spotify
Exec=spotify %U
Terminal=false
MimeType=x-scheme-handler/spotify;
Categories=Audio;Music;Player;AudioVideo;
StartupWMClass=spotify
DESKTOP