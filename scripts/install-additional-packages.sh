#!/usr/bin/env bash
set -ex

ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then
    ARCH="amd64"
fi

if [ "$ARCH" == "aarch64" ]; then
    ARCH="arm64"
fi

# install any deb packages from the additional-packages/ directory
if ls /tmp/additional-packages/*_"${ARCH}".deb; then
    echo "Found additional packages with architecture ${ARCH} to be installed"
    sudo dpkg -i /tmp/additional-packages/*_"${ARCH}".deb
else
    echo "No matching additional packages with architecture ${ARCH} found"
fi
