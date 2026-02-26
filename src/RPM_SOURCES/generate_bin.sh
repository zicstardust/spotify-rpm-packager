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

if [ ! -f \${HOME}/.config/spotify/spotify-envs.conf ]; then
    /usr/share/spotify/generate_envs_file.sh
fi


if [ ! -f \${HOME}/.config/spotify/spotify-flags.conf ]; then
    /usr/share/spotify/generate_flags_file.sh
fi

mapfile -t FLAGS <<< "\$(grep -v '^#' "\${HOME}/.config/spotify/spotify-flags.conf")"


mapfile -t ENVS <<< "\$(grep -v '^#' "\${HOME}/.config/spotify/spotify-envs.conf")"

exec env "\${ENVS[@]}" \\
    /usr/share/spotify/spotify \\
    "\${FLAGS[@]}" \\
    "\$@"
EXEC
chmod +x ${destine_dir}/spotify
