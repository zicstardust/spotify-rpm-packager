#!/usr/bin/env bash

cat > "/home/spotify/.rpmmacros" << RPMMACROS
%_signature gpg
%_openpgp_sign_id $(gpg --list-signatures --with-colons | grep 'sig' | grep $GPG_NAME | head -n 1 | cut -d':' -f5)
%_gpgbin /usr/bin/gpg
RPMMACROS
