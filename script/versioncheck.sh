#!/usr/bin/env bash

BUCKET_URL=${BUCKET_URL:-"https://sg.kuzco.xyz"}

download_and_extract_latest_version() {
    local TEMP_DIR=$(mktemp -d)
    local TIMESTAMP=$(date +%s)
    local VERSIONS_URL="$BUCKET_URL/cli-versions.json?t=$TIMESTAMP"

    curl --fail --show-error --location --progress-bar -o $TEMP_DIR/versions.json "$VERSIONS_URL"

    CLI_VERSION=$(awk -F'"' '/cli-latest/ {print $4}' $TEMP_DIR/versions.json)
    echo $CLI_VERSION

    rm -rf $TEMP_DIR
}

LATEST_VERSION=$(download_and_extract_latest_version)
echo "Latest Kuzco version: $LATEST_VERSION"

LOCAL_VERSION=$(kuzco --version | awk '/Kuzco CLI version/ {print $4}')
echo "Local Kuzco version: $LOCAL_VERSION"

if [ "$LATEST_VERSION" = "$LOCAL_VERSION" ]; then
    echo "You have the latest version of Kuzco installed."
    expect /root/script/kuzco_start.exp
else
    echo "Your Kuzco version is out of date. Latest version is $LATEST_VERSION."
    echo "Running the installation script to update Kuzco..."
    /root/script/install.sh
    expect /root/script/kuzco_start.exp
fi