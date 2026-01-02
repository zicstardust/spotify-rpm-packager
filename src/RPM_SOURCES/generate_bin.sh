#!/usr/bin/env bash

destine_dir=$1


mkdir -p ${destine_dir}
cat > ${destine_dir}/spotify <<"EXEC"
#!/usr/bin/bash
# Spotify launcher with Fedora fixes

# Disable hardware acceleration that causes black screen
export SPOTIFY_CLEAN_CACHE=1

# Flags to improve compatibility
exec /usr/share/spotify/spotify \
    --disable-gpu-sandbox \
    --disable-seccomp-filter-sandbox \
    --no-zygote \
    "$@"
EXEC
chmod +x ${destine_dir}/spotify
