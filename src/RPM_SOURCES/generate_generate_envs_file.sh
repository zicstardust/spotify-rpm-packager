#!/usr/bin/bash

destine_dir=$1

cat > ${destine_dir}/generate_envs_file.sh <<"FILE"
#!/usr/bin/bash

mkdir -p ${HOME}/.config/spotify

cat > ${HOME}/.config/spotify/spotify.env <<"ENVS"
#If delete this file, it will be recreated with the default environment variables the next time you run Spotify.

#Defaults environment variables to improve Fedora/RHEL compatibility
# Disable hardware acceleration that causes black screen
SPOTIFY_CLEAN_CACHE=1

#Environment variables exemples:
#WAYLAND_DISPLAY=
ENVS

FILE
chmod +x ${destine_dir}/generate_envs_file.sh