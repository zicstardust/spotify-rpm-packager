# Spotify RPM Packager

A tool that automates the creation of RPM packages for Spotify. It downloads the latest Spotify release from debian repository, applies necessary adjustments for system compatibility, and bundles everything into a clean RPM package ready for installation on RPM-based Linux distributions such as Fedora and RHEL derivatives.

Designed for simplicity and reliability, this generator helps users maintain up-to-date Spotify installations without relying on outdated repositories.


[GitHub](https://github.com/zicstardust/spotify-rpm-packager)


## Container
### Tags

| Tag | Architecture | Description |
| :----: | :----: |--- |
| [`latest`](https://github.com/zicstardust/spotify-rpm-packager/blob/main/dockerfile) | amd64 | Default Tag |


### Registries
| Registry | Full image name | Description |
| :----: | :----: | :----: |
| [`docker.io`](https://hub.docker.com/r/zicstardust/spotify-rpm-packager) | `docker.io/zicstardust/spotify-rpm-packager` | Docker Hub |
| [`ghcr.io`](https://github.com/zicstardust/spotify-rpm-packager/pkgs/container/spotify-rpm-packager) | `ghcr.io/zicstardust/spotify-rpm-packager` | GitHub |

## Usage
### Compose
```
services:
  spotify-rpm:
    container_name: spotify-rpm-packager
    image: docker.io/zicstardust/spotify-rpm-packager:latest
    privileged: True
    environment:
      TZ: America/New_York
    ports:
      - 80:80
    volumes:
      - <path to Repository/RPMs output>:/data
      - <path to GPG key>:/gpg-key #Required to backup generate GPG key
```

### Environment variables

| variables | Function | Default | Exemple |
| :----: | --- | --- | --- |
| `TZ` | Set Timezone | | |
| `PUID` | Set UID | 1000 | |
| `PGID` | Set GID | 1000 | |
| `INTERVAL` | Set the interval to check for updates and generate the next RPM. | `1d` | `1d - 1 day`<br/>`10m - 10 minutes`<br/>`1w - 1 week`<br/>`65s - 65 seconds` |
| `DISABLE_WEB_SERVER` | Set `1` to disable web server repository | `0` | |
| `BUILD` | Set for which distros the RPM will be generated. Separated by `,` | `fc43` | `fc43,el10,rawhide` |


### Set BUILD
| Value | Function | 
| :----: | --- | 
| `fc42` | Generate RPM for fedora 42 |
| `fc43` | Generate RPM for fedora 43 |
| `fc44` | Generate RPM for fedora 44 |
| `rawhide` | Generate RPM for fedora rawhide |
| `el8` | Generate RPM for RHEL 8 like |
| `el9` | Generate RPM for RHEL 9 like |
| `el10` | Generate RPM for RHEL 10 like |


### GPG Sign
Environment variables required to use GPG
| variables | Function | Default |
| :----: | --- | --- |
| `GPG_NAME` | Your Name | |
| `GPG_EMAIL` | Your E-mail | |



## Repository Web Server
Recommended to use a proxy with https.

If you don't want to use the repository, just directly install the generated RPM

### On client

Exemple `/etc/yum.repos.d/spotify.repo` file

### without GPG
```
[spotify]
name=Spotify - $releasever - $basearch
baseurl=http://127.0.0.1/$releasever/$basearch/stable
enabled=1
gpgcheck=0

[spotify-source]
name=Spotify - Source
baseurl=http://127.0.0.1/$releasever/source/SRPMS
enabled=0
gpgcheck=0
```

### with GPG
```
[spotify]
name=Spotify - $releasever - $basearch
baseurl=http://127.0.0.1/$releasever/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=http://127.0.0.1/gpg

[spotify-source]
name=Spotify - Source
baseurl=http://127.0.0.1/$releasever/source/SRPMS
enabled=0
gpgcheck=1
gpgkey=http://127.0.0.1/gpg
```
### Install:
```
sudo dnf install spotify-client
```


## License

This project is a packaging script. Spotify is proprietary software owned by Spotify AB.