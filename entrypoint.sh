#!/usr/bin/env bash
set -e

: "${PUID:=1000}"
: "${PGID:=1000}"
: "${DISABLE_WEB_SERVER:=false}"

if [ "$(id -g spotify)" != "${PGID}" ]; then
    groupmod -o -g "${PGID}" spotify
fi


if [ "$(id -u spotify)" != "${PUID}" ]; then
    usermod -o -u "${PUID}" spotify
fi


if [ "$PORT" ]; then
    sed -i "s|80 default_server|${PORT} default_server|g" /etc/nginx/conf.d/{repo_server.conf,block_default_server.conf}
fi


if [ "$SERVER_NAME" ]; then
    sed -i "s|#include /etc/nginx/conf.d/block_default_server.conf;|include /etc/nginx/conf.d/block_default_server.conf;|" /etc/nginx/nginx.conf
    sed -i "s| default_server||g" /etc/nginx/conf.d/repo_server.conf
    sed -i "s|server_name _;|server_name ${SERVER_NAME};|g" /etc/nginx/conf.d/repo_server.conf
fi


if [[ "$DISABLE_WEB_SERVER" =~ ^(0|false|False|n|N)$ ]]; then
    nginx &> /dev/null
fi


if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
    if [ ! -f /gpg-key/private.pgp ] && [ ! -f /gpg-key/public.pgp ]; then
        generate_gpg.sh
    fi
    rpm --import /gpg-key/public.pgp
fi


mkdir -p /data /gpg-key /logs
mkdir -p /home/spotify/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
chown -R spotify:spotify /data /home/spotify /gpg-key /logs

exec runuser -u spotify -- "$@"