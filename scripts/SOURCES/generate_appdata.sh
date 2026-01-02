#!/usr/bin/env bash

destine_dir=$1

mkdir -p ${destine_dir}
cat > ${destine_dir}/spotify.xml <<APPDATA
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop">
  <id>spotify.desktop</id>
  <metadata_license>CC0-1.0</metadata_license>
  <project_license>LicenseRef-proprietary</project_license>
  <name>Spotify</name>
  <summary>Online music streaming service</summary>
  <description>
    <p>Spotify is a digital music service that gives you access to millions of songs.</p>
  </description>
  <url type="homepage">https://www.spotify.com/</url>
</component>
APPDATA
