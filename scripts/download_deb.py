#!/usr/bin/env python3
from urllib import request


def download_deb_control_file(filename, output_path='/tmp'):
    request.urlretrieve("https://repository.spotify.com/dists/testing/non-free/binary-amd64/Packages", f'{output_path}/{filename}')
    return f'{output_path}/{filename}'



def parse_deb_control_file(path):
    data = {}
    
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            
            if ": " in line:
                key, value = line.split(": ", 1)

                if key in ("Depends", "Recommends", "Suggests"):
                    parts = [p.strip() for p in value.replace("|", ",").split(",")]
                    data[key] = [p for p in parts if p]
                elif key in ("Size",):
                    data[key] = int(value)
                else:
                    data[key] = value

    return data


def download_deb(url, output_path='/tmp'):
    deb_output = url.replace('pool/non-free/s/spotify-client/', f'{output_path}/')
    request.urlretrieve(f'https://repository.spotify.com/{url}', deb_output)


def spotify_version_file(version, output_file='/tmp/spotify.version'):
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(version)

if __name__ == "__main__":
    file = download_deb_control_file('spotify.info')
    result = parse_deb_control_file(file)
    spotify_version = result['Version'].replace('1:', '')
    spotify_version_file(spotify_version)
    print(f"Downloading .deb, latest version: {spotify_version}")
    download_deb(result['Filename'])
