# Spotify RPM Packager

A tool that automates the creation of RPM packages for Spotify. It downloads the latest Spotify release from debian repository, applies necessary adjustments for system compatibility, and bundles everything into a clean RPM package ready for installation on RPM-based Linux distributions such as Fedora and RHEL derivatives.

Includes a repository web server for automatic Spotify updates.

This package includes enhancements and fixes compared to the official .DEB:
- Built-in FFMPEG libraries for playing local files
- Persistent flags configuration file
- Scalable desktop icon
- Defaults Flags to improve Fedora/RHEL compatibility


[GitHub](https://github.com/zicstardust/spotify-rpm-packager)

## Help Section
- #### If you don't want to run a repository web server, [just directly install the generated RPMs](https://github.com/zicstardust/spotify-rpm-packager/releases)

- #### [Common Issues](#common-issues)

- #### [Making flags persistent](#making-flags-persistent)

## Container info and usage

<details>
<summary> See more </summary>

## Container

### Tags

| Tag | Description |
| :----: |--- |
| [`latest`](https://github.com/zicstardust/spotify-rpm-packager/blob/main/dockerfile) | Default Tag |


### Registries
| Registry | Full image name | Description |
| :----: | :----: | :----: |
| [`docker.io`](https://hub.docker.com/r/zicstardust/spotify-rpm-packager) | `docker.io/zicstardust/spotify-rpm-packager` | Docker Hub |
| [`ghcr.io`](https://github.com/zicstardust/spotify-rpm-packager/pkgs/container/spotify-rpm-packager) | `ghcr.io/zicstardust/spotify-rpm-packager` | GitHub |


### Supported Architectures
Attention: The container supports others architectures, but the generated RPM is only for amd64.
| Architecture | Available | Tag |
| :----: | :----: | ---- |
| amd64 | ✅ | latest |
| arm64 | ✅ | latest |
| ppc64le | ✅ | latest |
| s390x | ✅ | latest |

## Usage
### Compose
``` yml
services:
  spotify-rpm:
    container_name: spotify-rpm-packager
    image: docker.io/zicstardust/spotify-rpm-packager:latest
    restart: unless-stopped
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
| `DISABLE_WEB_SERVER` | Disable web server repository | `false` | |
| `KEEP_VERSIONS` | Number of RPM versions saved. If value is `0`, keep all | `0` | |
| `BUILD` | Set for which distros the RPM will be generated. Separated by `,` | `fc43` | [Look at the set BUILD section](#set-build) |
| `GPG_NAME` | Your GPG key Name | | [Look at the GPG Sign section](#gpg-sign) |
| `GPG_EMAIL` | Your GPG key E-mail | | [Look at the GPG Sign section](#gpg-sign) |
| `STABLE_BUILDS` | RPM Spotify Stable builds | `true` | |
| `TESTING_BUILDS` | RPM Spotify Testing builds | `false` | |
| `SRPMS_BUILDS` | SRPMS builds | `false` | |
| `BUILTIN_FFMPEG` | Built-in FFMPEG Libraries | `true` | |
| `PORT` | Repository Web Server Port  | `80` | |


#### Set BUILD
| Value | Function | 
| :----: | --- | 
| `fc42` | Generate RPM for fedora 42 |
| `fc43` | Generate RPM for fedora 43 |
| `fc44` | Generate RPM for fedora 44 |
| `rawhide` | Generate RPM for fedora rawhide |
| `el10` | Generate RPM for RHEL 10 like |


#### GPG Sign
To sign RPMs, it is necessary to set `GPG_NAME` and `GPG_EMAIL` environment variables.

The key will be imported from `/gpg-key/private.pgp` and `/gpg-key/public.pgp`.

If they do not exist, a new key will be created and exported to the `/gpg-key/private.pgp` and `/gpg-key/public.pgp`.

</details>

## Usage Repository Web Server

<details>
<summary> See more </summary>

Recommended to use a proxy with https.

### .repo File Exemple (with GPG)

#### `/etc/yum.repos.d/spotify.repo`
``` conf
[spotify]
name=Spotify Unofficial Repository - Stable - $basearch
baseurl=http://127.0.0.1/$releasever/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=http://127.0.0.1/gpg

[spotify-testing]
name=Spotify Unofficial Repository - Testing - $basearch
baseurl=http://127.0.0.1/$releasever/$basearch/testing
enabled=0
gpgcheck=1
gpgkey=http://127.0.0.1/gpg

[spotify-source]
name=Spotify Unofficial Repository - Stable - Source
baseurl=http://127.0.0.1/$releasever/source/stable
enabled=0
gpgcheck=1
gpgkey=http://127.0.0.1/gpg


[spotify-testing-source]
name=Spotify Unofficial Repository - Testing - Source
baseurl=http://127.0.0.1/$releasever/source/testing
enabled=0
gpgcheck=1
gpgkey=http://127.0.0.1/gpg
```

### Install from repostory:

```bash
sudo dnf install spotify-client
```

</details>

## Making flags persistent

Flag file `~/.config/spotify/spotify-flags.conf`

Below is an example spotify-flags.conf file that defines the flags --force-device-scale-factor:
```conf

~/.config/spotify/spotify-flags.conf

# This line will be ignored.
--force-device-scale-factor=1.5
```

## Common Issues

### Dependencies not found in EL 10 (RHEL, Almalinux, Oracle Linux, Rocky Linux, etc)

<details>

It is necessary to activate the EPEL repository.

```sh
sudo dnf install epel-release
```
</details>

### Local files don't play

<details>

Enable built-in FFMPEG Libraries on RPM build (`BUILTIN_FFMPEG`=true)

<details>
<summary> Or alternative: </summary>


- Enable [rpmfusion-free](https://rpmfusion.org/Configuration)
- Install compat-ffmpeg4 and ffmpeg-libs:
```sh
sudo dnf install compat-ffmpeg4 ffmpeg-libs --allowerasing
```
</details>

</details>

### Incorrect device scaling factor

<details>

Add `--force-device-scale-factor` to the flags file in `~/.config/spotify/spotify-flags.conf`.

Default value is `1`.
```conf
#exemple scale factor 1.5
--force-device-scale-factor=1.5
```
</details>

## License

This project is a packaging script. Spotify is proprietary software owned by Spotify AB.