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
IMAGE_NAME="amazonlinux"
CONTAINER_NAME="serviceconnect-build"
PLATFORM_ARG="linux/$ARCH"

# Create and start the container
sudo docker pull --platform=$PLATFORM_ARG $IMAGE_NAME
sudo docker run -itd --name $CONTAINER_NAME $IMAGE_NAME bash

# Install ecs-service-connect-agent
sudo docker exec $CONTAINER_NAME yum install -y ecs-service-connect-agent

# Copy the built .tar file to the current directory on the host
sudo docker cp $CONTAINER_NAME:/var/lib/ecs/deps/serviceconnect/ecs-service-connect-agent.interface-v1.tar /tmp/

# Stop the container but do not remove it
sudo docker stop $CONTAINER_NAME

# Remove the container
sudo docker rm -f $CONTAINER_NAME

# Create the serviceconnect directory if it doesn't exist
sudo mkdir -p /var/lib/ecs/deps/serviceconnect

# Rename the .tar file to ecs-service-connect-agent.tar
sudo mv /tmp/ecs-service-connect-agent.interface-v1.tar /var/lib/ecs/deps/serviceconnect/ecs-service-connect-agent.interface-v1.tar

# Create a symlink to ecs-service-connect-agent.tar
sudo ln -s /var/lib/ecs/deps/serviceconnect/ecs-service-connect-agent.interface-v1.tar /var/lib/ecs/deps/serviceconnect/ecs-service-connect-agent.tar
