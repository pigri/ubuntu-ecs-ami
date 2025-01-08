#!/usr/bin/env bash
set -ex

ARCH=$(uname -m)

if [ "$ARCH" == "x86_64" ]; then
    ARCH="amd64"
fi

if [ "$ARCH" == "aarch64" ]; then
    ARCH="arm64"
fi

# Define image and container name
IMAGE_NAME="ubuntu:${UBUNTU_VERSION}"
CONTAINER_NAME="efs-utils-build"
PLATFORM_ARG="linux/$ARCH"

# Create and start the container
sudo docker pull --platform=$PLATFORM_ARG $IMAGE_NAME
sudo docker run -itd --name $CONTAINER_NAME $IMAGE_NAME bash

# Update repository information
sudo docker exec $CONTAINER_NAME apt-get update

# Install required packages
sudo docker exec $CONTAINER_NAME apt-get install -y curl binutils git rustc cargo pkg-config libssl-dev gettext

# Clone the repository
sudo docker exec $CONTAINER_NAME git clone https://github.com/aws/efs-utils /efs-utils

# Checkout specific tag
sudo docker exec $CONTAINER_NAME bash -c "cd /efs-utils && git checkout v$VERSION"

# Configure git to treat all directories as safe
sudo docker exec $CONTAINER_NAME bash -c "git config --global --add safe.directory /efs-utils"

# Build DEB package
sudo docker exec $CONTAINER_NAME bash -c "cd /efs-utils && ./build-deb.sh"

# Install the package
sudo docker exec $CONTAINER_NAME bash -c "cd /efs-utils && DEBIAN_FRONTEND=noninteractive apt-get install -y ./build/amazon-efs-utils*deb"

# Check if installed successfully
sudo docker exec $CONTAINER_NAME mount.efs --version

# Copy the built .deb package to the current directory on the host
sudo docker cp $CONTAINER_NAME:/efs-utils/build /tmp/

# Stop the container but do not remove it
sudo docker stop $CONTAINER_NAME

echo "Build process completed! The build directory is in your current directory."
echo

sudo dpkg -i /tmp/build/amazon-efs-utils*deb

sudo docker rm -f $CONTAINER_NAME
