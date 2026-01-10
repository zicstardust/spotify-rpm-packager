#!/usr/bin/env bash

source_dir=$1
destine_dir=$2


#Scalable icon
mkdir -p ${destine_dir}/hicolor/scalable/apps
curl -fSL "https://raw.githubusercontent.com/flathub/com.spotify.Client/refs/heads/master/com.spotify.Client.svg" -o ${destine_dir}/hicolor/scalable/apps/spotify-client.svg


# Tradicional icons
for i in 16 22 24 32 48 64 128 256 512; do
    if [ -f "${source_dir}/spotify-linux-${i}.png" ]; then
        mkdir -p ${destine_dir}/hicolor/${i}x${i}/apps
        cp ${source_dir}/spotify-linux-${i}.png  ${destine_dir}/hicolor/${i}x${i}/apps/spotify-client.png
    fi
done


