# Spotify RPM Packager

A lightweight tool that automates the creation of RPM packages for Spotify. It downloads the latest Spotify release, applies necessary adjustments for system compatibility, and bundles everything into a clean RPM package ready for installation on RPM-based Linux distributions such as Fedora and RHEL derivatives.

Designed for simplicity and reliability, this generator helps users maintain up-to-date Spotify installations without relying on unofficial or outdated repositories.


[GitHub](https://github.com/zicstardust/spotify-rpm-packager)


## Container
### Tags

| Tag | Architecture | Description |
| :----: | :----: |--- |
| [`latest`, `fc43`](https://github.com/zicstardust/spotify-rpm-packager/blob/main/dockerfile) | amd64 | Create a Spotify package for the latest stable version of Fedora. |
| [`fc-previous`, `fc42`](https://github.com/zicstardust/spotify-rpm-packager/blob/main/dockerfile-fc-previous) | amd64 | Create a Spotify package for the previous stable version of Fedora. |
| [`fc-beta`,`fc44`](https://github.com/zicstardust/spotify-rpm-packager/blob/main/dockerfile-fc-beta) | amd64 | Create a Spotify package for Fedora Beta. |
| [`rawhide`](https://github.com/zicstardust/spotify-rpm-packager/blob/main/dockerfile-fc-rawhide) | amd64 | Create a Spotify package for Fedora Rawhide. |
| [`el8`](https://github.com/zicstardust/spotify-rpm-packager/blob/main/dockerfile-el8) | amd64 | Create a Spotify package for RHEL 8 derivatives |
| [`el9`](https://github.com/zicstardust/spotify-rpm-packager/blob/main/dockerfile-el9) | amd64 | Create a Spotify package for RHEL 9 derivatives |
| [`el`, `el10`](https://github.com/zicstardust/spotify-rpm-packager/blob/main/dockerfile-el10) | amd64 | Create a Spotify package for RHEL 10 derivatives |


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
    environment:
      TZ: America/New_York
    ports:
      - 80:80
    volumes:
      - <path to RPMs output>:/data
      - <path to GPG key>:/gpg-key #Required to backup generate GPG key
```

## Environment variables

| variables | Function | Default |
| :----: | --- | --- |
| `TZ` | Set Timezone | |
| `PUID` | Set UID | 1000 |
| `PGID` | Set GID | 1000 |
| `INTERVAL` | Set the interval to check for updates and generate the next RPM. | `1d` |
| `DISABLE_WEB_SERVER` | Set `1` to disable web server repository | `0` |



### GPG Sign
Environment variables required to use GPG
| variables | Function | Default |
| :----: | --- | --- |
| `GPG_NAME` | Your Name | |
| `GPG_EMAIL` | Your E-mail | |



## Repository Web Server

## On client

Exemple `/etc/yum.repos.d/spotify.repo` file

### without GPG
```
[spotify]
name=Spotify - $releasever
baseurl=http://127.0.0.1/$releasever/$basearch/stable
enabled=1
gpgcheck=0
```

### with GPG
```
[spotify]
name=Spotify - $releasever
baseurl=http://127.0.0.1/$releasever/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=http://127.0.0.1/gpg
```
### Install:
```
sudo dnf install spotify-client
```

## Multiple release repository
Example of repository with a single web server for FC stable, previous stable, beta, rawhide and EL 10.
```
services:
  stable:
    container_name: spotify-fedora-stable-releases
    image: zicstardust/spotify-rpm-packager:latest
    environment:
      GPG_NAME: Exemple
      GPG_EMAIL: me@exemple.com
    ports:
      - 80:80
    volumes:
      - <path to RPMs output>:/data
      - <path to GPG key>:/gpg-key
  previous:
    container_name: spotify-fedora-previous-releases
    image: zicstardust/spotify-rpm-packager:fc-previous
    environment:
      DISABLE_WEB_SERVER: 1
    volumes:
      - <same path to RPMs output>:/data
  beta:
    container_name: spotify-fedora-beta-releases
    image: zicstardust/spotify-rpm-packager:fc-beta
    environment:
      DISABLE_WEB_SERVER: 1
    volumes:
      - <same path to RPMs output>:/data
  rawhide:
    container_name: spotify-rawhide-releases
    image: zicstardust/spotify-rpm-packager:rawhide
    environment:
      DISABLE_WEB_SERVER: 1
    volumes:
      - <same path to RPMs output>:/data
  el10:
    container_name: spotify-el10-releases
    image: zicstardust/spotify-rpm-packager:el10
    environment:
      DISABLE_WEB_SERVER: 1
    volumes:
      - <same path to RPMs output>:/data
```


## License

This project is a packaging script. Spotify is proprietary software owned by Spotify AB.