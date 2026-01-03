#!/usr/bin/env bash

spotify_version=$(cat /tmp/spotify.version)
deb_file="/tmp/spotify-client_${spotify_version}_amd64.deb"

echo "Downloading .deb, latest version: $spotify_version"

curl -fSL "https://repository.spotify.com/pool/non-free/s/spotify-client/spotify-client_${spotify_version}_amd64.deb" -o "$deb_file" &> /dev/null
