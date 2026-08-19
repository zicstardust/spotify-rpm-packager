#!/usr/bin/bash

set -e

: "${REPO_FILE_ENABLE_STABLE:=1}"
: "${REPO_FILE_ENABLE_TESTING:=0}"
: "${REPO_FILE_ENABLE_SOURCE_STABLE:=0}"
: "${REPO_FILE_ENABLE_SOURCE_TESTING:=0}"


file_output="/data/spotify-unofficial.repo"


if [[ "$REPO_FILE_ENABLE_STABLE" =~ ^(1|true|True|y|Y)$ ]]; then
    REPO_FILE_ENABLE_STABLE=1
else
    REPO_FILE_ENABLE_STABLE=0
fi

if [[ "$REPO_FILE_ENABLE_TESTING" =~ ^(1|true|True|y|Y)$ ]]; then
    REPO_FILE_ENABLE_TESTING=1
else
    REPO_FILE_ENABLE_TESTING=0
fi

if [[ "$REPO_FILE_ENABLE_SOURCE_STABLE" =~ ^(1|true|True|y|Y)$ ]]; then
    REPO_FILE_ENABLE_SOURCE_STABLE=1
else
    REPO_FILE_ENABLE_SOURCE_STABLE=0
fi

if [[ "$REPO_FILE_ENABLE_SOURCE_TESTING" =~ ^(1|true|True|y|Y)$ ]]; then
    REPO_FILE_ENABLE_SOURCE_TESTING=1
else
    REPO_FILE_ENABLE_SOURCE_TESTING=0
fi



if [ "$REPO_AUTHENTICATION_USER" ] && [ "$REPO_AUTHENTICATION_PASSWORD" ]; then
    autentication=$(cat <<EOF
username=$REPO_AUTHENTICATION_USER
password=$REPO_AUTHENTICATION_PASSWORD
EOF
)
else
    autentication=$(cat <<EOF
#username=
#password=
EOF
)
fi


if [ "$REPO_AUTHENTICATION_USER" ] && [ "$REPO_AUTHENTICATION_PASSWORD" ] && [[ "$REPO_AUTHENTICATION_GPG_FILE" =~ ^(1|true|True|y|Y)$ ]]; then
    gpg_url=$(echo "$REPO_FILE_URL" | sed -E "s|(https?://)|\1${REPO_AUTHENTICATION_USER}:${REPO_AUTHENTICATION_PASSWORD}@|g")
else
    gpg_url="${REPO_FILE_URL}/gpg"
fi


if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
    gpg=$(cat <<EOF
gpgcheck=1
gpgkey=${gpg_url}
EOF
)
else
    gpg=$(cat <<EOF
gpgcheck=0
#gpgkey=${gpg_url}
EOF
)
fi




cat > $file_output <<EOF
[spotify]
name=Spotify Unofficial Repository - Stable - x86_64
baseurl=${REPO_FILE_URL}/\$releasever/x86_64/stable
$autentication
enabled=$REPO_FILE_ENABLE_STABLE
$gpg

[spotify-testing]
name=Spotify Unofficial Repository - Testing - x86_64
baseurl=${REPO_FILE_URL}/\$releasever/x86_64/testing
$autentication
enabled=$REPO_FILE_ENABLE_TESTING
$gpg

[spotify-source]
name=Spotify Unofficial Repository - Stable - Source
baseurl=${REPO_FILE_URL}/\$releasever/source/stable
$autentication
enabled=$REPO_FILE_ENABLE_SOURCE_STABLE
$gpg


[spotify-testing-source]
name=Spotify Unofficial Repository - Testing - Source
baseurl=${REPO_FILE_URL}/\$releasever/source/testing
$autentication
enabled=$REPO_FILE_ENABLE_SOURCE_TESTING
$gpg
EOF