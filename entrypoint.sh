#!/usr/bin/env bash
set -e

: "${PUID:=1000}"
: "${PGID:=1000}"

if ! getent group spotify >/dev/null; then
    groupadd -g "$PGID" spotify
fi

if ! id -u spotify >/dev/null 2>&1; then
    useradd -m -u "$PUID" -g "$PGID" -s /sbin/nologin spotify
fi

usermod -a -G mock spotify


if [ "$DISABLE_WEB_SERVER" != "1" ]; then
    httpd &> /dev/null
fi

if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
    if [ ! -f /gpg-key/private.pgp ] && [ ! -f /gpg-key/public.pgp ]; then
        gpg-gen.sh
    fi

    rpm --import /gpg-key/public.pgp
fi

mkdir -p /data /home/spotify /gpg-key

mkdir -p /home/spotify/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

mv /SOURCES/*.sh  /home/spotify/rpmbuild/SOURCES/

rm -Rf /SOURCES

chown -R spotify:spotify /data /home/spotify /gpg-key

exec runuser -u spotify -- "$@"