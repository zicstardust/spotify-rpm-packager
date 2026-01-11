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

# Flags to improve compatibility
exec /usr/share/spotify/spotify \\
    --disable-gpu-sandbox \\
    --disable-seccomp-filter-sandbox \\
    --no-zygote \\
    "\$@"
EXEC
chmod +x ${destine_dir}/spotify
