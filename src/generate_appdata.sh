#!/usr/bin/env bash

destine_dir=$1
spotify_version=$2

mkdir -p ${destine_dir}
cat > ${destine_dir}/spotify.appdata.xml <<APPDATA
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop">
  <id>spotify.desktop</id>
  <name>Spotify</name>
  <metadata_license>CC0-1.0</metadata_license>
  <project_license>LicenseRef-proprietary=https://www.spotify.com/us/legal/end-user-agreement/</project_license>
  <url type="homepage">https://www.spotify.com</url>
  <url type="help">https://community.spotify.com/t5/Desktop-Linux/bd-p/desktop_linux</url>
  <summary>Online music streaming service</summary>
  <description>
    <p>Access all of your favorite music, discover new songs, and share music online with your friends - all in one place. 
    Create shared playlists or share individual songs with your Facebook friends with just a click of a button. 
    Follow your favorite artists or friends to know what they are listening to, and then save the songs to your own playlists. 
      Spotify is the best way to have access to millions of songs, and all the latest hits.</p>
  </description>
    <screenshots>
    <screenshot type="default">
      <caption>Artist</caption>
      <image type="source" width="1920" height="1080">https://raw.githubusercontent.com/flathub/com.spotify.Client/master/screenshots/Artist.png</image>
    </screenshot>
    <screenshot>
      <caption>Playlist</caption>
      <image type="source" width="1920" height="1080">https://raw.githubusercontent.com/flathub/com.spotify.Client/master/screenshots/Playlist.png</image>
    </screenshot>
    <screenshot>
      <caption>Podcast</caption>
      <image type="source" width="1920" height="1080">https://raw.githubusercontent.com/flathub/com.spotify.Client/master/screenshots/Podcast.png</image>
    </screenshot>
    <screenshot>
      <caption>Fullscreen</caption>
      <image type="source" width="1920" height="1080">https://raw.githubusercontent.com/flathub/com.spotify.Client/master/screenshots/Fullscreen.png</image>
    </screenshot>
  </screenshots>
  <releases>
  <release version="${spotify_version}" date="$(date +"%Y-%M-%d")">
      <description></description>
    </release>
  </release>
</component>
APPDATA
