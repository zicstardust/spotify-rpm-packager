#!/usr/bin/env bash

echo "cleanup..."

rm -Rf /tmp/*

rm -Rf /home/spotify/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}/*

#rm -Rf /var/lib/mock/*
