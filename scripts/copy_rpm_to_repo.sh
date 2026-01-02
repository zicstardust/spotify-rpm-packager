#!/usr/bin/env bash

releasever=$(python3 -c 'import dnf, json; db = dnf.dnf.Base(); data = json.loads(json.dumps(db.conf.substitutions, indent=2)); print(data["releasever"])')

mkdir -p /data/${releasever}/x86_64/stable/Packages

cp -Rf /home/spotify/rpmbuild/RPMS/x86_64/* /data/${releasever}/x86_64/stable/Packages/
