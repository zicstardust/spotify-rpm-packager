#!/usr/bin/env bash

source_dir=$1
destine_dir=$2


for i in 8 16 22 24 32 36 44 48 64 72 96 128 144 150 192 256 310 512 1024; do
    if [ -f "${source_dir}/spotify-linux-${i}.png" ]; then
        mkdir -p ${destine_dir}/hicolor/${i}x${i}/apps
        cp ${source_dir}/spotify-linux-${i}.png  ${destine_dir}/hicolor/${i}x${i}/apps/spotify-client.png
    fi
done


