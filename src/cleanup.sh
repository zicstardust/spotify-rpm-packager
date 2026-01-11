#!/usr/bin/env bash

SPOTIFY_BRANCH=$1

echo "cleanup..."
#rm -f /tmp/spotify-client.${SPOTIFY_BRANCH}.Version
rm -f /tmp/spotify-client.${SPOTIFY_BRANCH}.Version.old
mv /tmp/spotify-client.${SPOTIFY_BRANCH}.Version /tmp/spotify-client.${SPOTIFY_BRANCH}.Version.old
rm -Rf /tmp/spotify*.deb
rm -Rf /tmp/spotify*.tar.gz
rm -Rf /tpm/spotify-client*
rm -f /tmp/data.tar.gz
rm -f /tmp/control.tar.gz
rm -f /tmp/debian-binary
rm -Rf /tmp/usr
rm -f /tmp/ffmpeg_libs.tar.gz

rm -Rf /home/spotify/rpmbuild/BUILD/*
rm -Rf /home/spotify/rpmbuild/RPMS/*
rm -Rf /home/spotify/rpmbuild/SOURCES/spotify-client-*.tar.gz
rm -Rf /home/spotify/rpmbuild/SPECS/*
rm -Rf /home/spotify/rpmbuild/SRPMS/*


#rm -Rf /var/lib/mock/*
