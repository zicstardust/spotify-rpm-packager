#!/usr/bin/env bash

echo "cleanup..."
#rm -f /tmp/spotify.info
#rm -f /tmp/spotify.version
rm -f /tmp/spotify.version.old
mv /tmp/spotify.version /tmp/spotify.version.old
rm -Rf /tmp/spotify*.deb
rm -Rf /tmp/spotify*.tar.gz
rm -Rf /tpm/spotify-client*
rm -f /tmp/data.tar.gz
rm -f /tmp/control.tar.gz
rm -f /tmp/debian-binary
rm -Rf /tmp/usr

rm -Rf /home/spotify/rpmbuild/BUILD/*
rm -Rf /home/spotify/rpmbuild/RPMS/*
rm -Rf /home/spotify/rpmbuild/SOURCES/spotify-client-*.tar.gz
rm -Rf /home/spotify/rpmbuild/SPECS/*
rm -Rf /home/spotify/rpmbuild/SRPMS/*


#rm -Rf /var/lib/mock/*
