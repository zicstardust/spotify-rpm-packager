#!/usr/bin/env python3

import sys
from urllib import request
import os

def parse_packages(text: str):
    packages = []
    current = {}
    last_key = None

    for line in text.splitlines():
        if not line.strip():
            if current:
                packages.append(current)
                current = {}
                last_key = None
            continue

        if line.startswith(" ") and last_key:
            current[last_key] += "\n" + line.strip()
            continue

        key, value = line.split(":", 1)
        current[key] = value.strip()
        last_key = key

    if current:
        packages.append(current)

    return packages


def download_debian_control_file(SPOTIFY_BRANCH):
     request.urlretrieve(f"https://repository.spotify.com/dists/{SPOTIFY_BRANCH}/non-free/binary-amd64/Packages", '/tmp/spotify.info')


if __name__ == '__main__':

    SPOTIFY_BRANCH=sys.argv[1]
    package=sys.argv[2]
    value_return=sys.argv[3]
    info_file='/tmp/spotify.info'
    version_file=f'/tmp/{package}.{SPOTIFY_BRANCH}.{value_return}'

    download_debian_control_file(SPOTIFY_BRANCH)

    with open(info_file, "r", encoding="utf-8") as f:
        data = parse_packages(f.read())


    for i in data:
        if i["Package"] == package:
            value=(i[value_return])
            str(value)
            
            if value_return == "Version":
                value=value.replace('1:', '')

            with open(version_file, "w") as f:
                f.write(value)
        break
    
    os.remove(info_file)



#Usage:
#python.py stable spotify-client Version