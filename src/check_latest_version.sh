#!/usr/bin/env bash

INFO_FILE="/tmp/spotify.info"


parse_deb_control_file() {
    awk '
        BEGIN { RS=""; FS="\n" }
        {
            for (i=1; i<=NF; i++) {
                if ($i ~ /^Version: /) {
                    sub(/^Version: /, "", $i)
                    gsub(/^1:/, "", $i)
                    version=$i
                }
            }
        }
        END {
            print version "|" filename
        }
    ' "$INFO_FILE"
}

# Main
echo "Checking new version..."

#download deb control file
curl -fsSL "https://repository.spotify.com/dists/testing/non-free/binary-amd64/Packages" -o "$INFO_FILE"

IFS="|" read -r SPOTIFY_VERSION < <(parse_deb_control_file)

echo "$SPOTIFY_VERSION" > /tmp/spotify.version

rm -f $INFO_FILE