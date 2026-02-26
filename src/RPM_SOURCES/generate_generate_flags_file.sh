#!/usr/bin/bash

destine_dir=$1

cat > ${destine_dir}/generate_flags_file.sh <<"FILE"
#!/usr/bin/bash

mkdir -p ${HOME}/.config/spotify

cat > ${HOME}/.config/spotify/spotify-flags.conf <<"FLAGS"
#If delete this file, it will be recreated with the default flags the next time you run Spotify.

#Defaults Flags to improve Fedora/RHEL compatibility
--disable-gpu-sandbox
--disable-seccomp-filter-sandbox
--no-zygote

#Flags exemples:
#Disable Wayland and run XWayland
#--ozone-platform=x11
#--disable-features=UseOzonePlatform

#--disable-gpu
#--disable-gpu-shader-disk-cache
#--force-device-scale-factor=<value>
#--cache-path=<path>
#--debug-level=OFF|MAX|<value range 0-8>
#--uri=<spotify_uri>
#--mu=<value>
#--log-file=<path>
#--show-console
#--username=<username>
#--password=<password>
FLAGS

FILE
chmod +x ${destine_dir}/generate_flags_file.sh