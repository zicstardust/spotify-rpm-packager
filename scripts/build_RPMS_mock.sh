#!/usr/bin/env bash

srpms_file=$1
spotify_version=$2


IFS="," read -ra distros <<< "$BUILD"


mock_config(){
    local config=$1
    local distro=$2

    if [ "$distro" == "fc42" ]; then
        mock_config_file="fedora-42-x86_64"
        repofolder="42"
    elif [ "$distro" == "fc43" ]; then
        mock_config_file="fedora-43-x86_64"
        repofolder="43"
    elif [ "$distro" == "fc44" ]; then
        mock_config_file="fedora-44-x86_64"
        repofolder="44"
    elif [ "$distro" == "rawhide" ]; then
        mock_config_file="fedora-rawhide-x86_64"
        repofolder="44"
    elif [ "$distro" == "el8" ]; then
        mock_config_file="alma+epel-8-x86_64"
        repofolder="8"
    elif [ "$distro" == "el9" ]; then
        mock_config_file="alma+epel-9-x86_64"
        repofolder="9"
    elif [ "$distro" == "el10" ]; then
        mock_config_file="alma+epel-10-x86_64"
        repofolder="10"
    else
        echo "BUILD: ${distro} invalid!"
        exit 1
    fi


    if [ "$config" == "mock_config_file" ]; then
        echo $mock_config_file
    elif [ "$config" == "releasever" ]; then
        echo $repofolder
    fi
}


for item in "${distros[@]}"; do
    mock -r $(mock_config mock_config_file $item) --rebuild $srpms_file

    if [[ -v $GPG_NAME ]] && [[ -v $GPG_EMAIL ]]; then
        echo "Sign RPMs files..."
        rpm --addsign /var/lib/mock/$(mock_config mock_config_file $item)/result/spotify-client-${spotify_version}*.x86_64.rpm
        rpm --addsign /var/lib/mock/$(mock_config mock_config_file $item)/result/spotify-client-${spotify_version}*.src.rpm
    fi


    mkdir -p /data/$(mock_config releasever $item)/x86_64/stable/Packages/
    cp /var/lib/mock/$(mock_config mock_config_file $item)/result/spotify-client-${spotify_version}*.x86_64.rpm /data/$(mock_config releasever $item)/x86_64/stable/Packages/

    createrepo /data/$(mock_config releasever $item)/x86_64/stable/


    mkdir -p /data/$(mock_config releasever $item)/source/SRPMS/Packages/
    cp /var/lib/mock/$(mock_config mock_config_file $item)/result/spotify-client-${spotify_version}*.src.rpm /data/$(mock_config releasever $item)/source/SRPMS/Packages/
    createrepo /data/$(mock_config releasever $item)/source/SRPMS/
done
