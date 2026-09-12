#!/usr/bin/env bash

cat > "/home/spotify/.rpmmacros" << RPMMACROS
%_signature gpg
%_openpgp_sign_id $(gpg --list-secret-keys --with-colons "${GPG_EMAIL}" | awk -F: '$1 == "fpr" { print $10; exit }')
%_gpg_name ${GPG_NAME}
%_gpgbin /usr/bin/gpg
RPMMACROS
