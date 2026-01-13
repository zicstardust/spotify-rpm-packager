#!/usr/bin/env bash

destine_dir=$1
BUILTIN_FFMPEG=$2

if [[ "$BUILTIN_FFMPEG" =~ ^(1|true|True|y|Y)$ ]]; then
    EXPORT_FFMPEG="export LD_LIBRARY_PATH=/usr/share/spotify/ffmpeg\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
else
    EXPORT_FFMPEG=""
fi


mkdir -p ${destine_dir}
cat > ${destine_dir}/spotify <<EXEC
#!/usr/bin/bash

$EXPORT_FFMPEG

# Disable hardware acceleration that causes black screen
export SPOTIFY_CLEAN_CACHE=1


if [ ! -f \${HOME}/.config/spotify/spotify-flags.conf ]; then
    mkdir -p \${HOME}/.config/spotify
    cat > \${HOME}/.config/spotify/spotify-flags.conf <<"FLAGS"
#If delete this file, it will be recreated with the default flags the next time you run Spotify.

#Defaults Flags to improve Fedora/RHEL compatibility
--disable-gpu-sandbox
--disable-seccomp-filter-sandbox
--no-zygote

#Flags exemples:
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

fi

mapfile -t FLAGS <<< "\$(grep -v '^#' "\${HOME}/.config/spotify/spotify-flags.conf")"

exec /usr/share/spotify/spotify \\
    "\${FLAGS[@]}" \\
    "\$@"
EXEC
chmod +x ${destine_dir}/spotify
