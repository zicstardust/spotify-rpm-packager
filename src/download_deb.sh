#!/usr/bin/env bash

SPOTIFY_BRANCH=$1

spotify_version=$(cat /tmp/spotify-client.${SPOTIFY_BRANCH}.Version)
deb_file="/tmp/spotify-client_${spotify_version}_amd64.deb"

echo "Downloading .deb, latest ${SPOTIFY_BRANCH} version: $spotify_version"

curl -fSL "https://repository.spotify.com/pool/non-free/s/spotify-client/spotify-client_${spotify_version}_amd64.deb" -o "$deb_file" &> /dev/null
