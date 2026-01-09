#!/usr/bin/env bash
set -e

: "${PUID:=1000}"
: "${PGID:=1000}"
: "${DISABLE_WEB_SERVER:=false}"

if ! getent group spotify >/dev/null; then
    groupadd -g "$PGID" spotify
fi

if ! id -u spotify >/dev/null 2>&1; then
    useradd -m -u "$PUID" -g "$PGID" -s /sbin/nologin spotify
fi

usermod -a -G mock spotify


mkdir -p /data /home/spotify /gpg-key

mkdir -p /home/spotify/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

mv /SOURCES/*.sh  /home/spotify/rpmbuild/SOURCES/

rm -Rf /SOURCES

if [[ "$DISABLE_WEB_SERVER" =~ ^(0|false|False|n|N)$ ]]; then
    httpd &> /dev/null
fi

if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
    if [ ! -f /gpg-key/private.pgp ] && [ ! -f /gpg-key/public.pgp ]; then
        generate_gpg.sh
    fi
    rpm --import /gpg-key/public.pgp
fi

chown -R spotify:spotify /data /home/spotify /gpg-key

exec runuser -u spotify -- "$@"