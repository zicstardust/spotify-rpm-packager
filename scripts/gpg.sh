#!/bin/bash

#GPG Key
if [ "$GPG_NAME" ] && [ "$GPG_EMAIL" ]; then
    echo "GPG key enabled!"
    echo "Importing GPG key..."

    gpg --import /gpg-key/private.pgp
    gpg --import /gpg-key/public.pgp
    

    cat > "/home/spotify/.rpmmacros" << RPMMACROS
%_signature gpg
%_gpg_name ${GPG_NAME}
%_gpgbin /usr/bin/gpg
RPMMACROS
    #rpm --import /gpg-key/public.pgp
    gpg --export -a "${GPG_EMAIL}" > /data/gpg

fi


