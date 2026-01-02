#!/usr/bin/env bash

echo "Generating GPG key..."

gpg --batch --gen-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Expire-Date: 0
Name-Real: $GPG_NAME
Name-Comment: Spotify Repository Signing Key
Name-Email: $GPG_EMAIL
EOF

mkdir -p /gpg-key

gpg --export -a "${GPG_EMAIL}" > /gpg-key/public.pgp
gpg --export-secret-keys -a "${GPG_EMAIL}" > /gpg-key/private.pgp