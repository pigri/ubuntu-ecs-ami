#!/usr/bin/env bash
set -ex

if [ $AMI_TYPE != "ubuntu2404gpu" ] && [ $AMI_TYPE != "ubuntu2404armgpu" ]; then
    echo "Skipping GPU support for $AMI_TYPE"
    exit 0
fi

DISTRO=$(
    . /etc/os-release
    echo $ID$VERSION_ID | sed -e 's/\.//g'
)
if (arch | grep -q x86); then
    ARCH=x86_64
else
    ARCH=sbsa
fi

cd /tmp
sudo apt-get install -y dkms linux-headers-aws linux-modules-extra-aws unzip gcc make libglvnd-dev pkg-config
curl -L -O https://developer.download.nvidia.com/compute/cuda/repos/$DISTRO/$ARCH/cuda-keyring_1.1-1_all.deb
sudo apt-get install -y ./cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get install -y cuda-drivers cuda-toolkit nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

mkdir -p /tmp/ecs
echo 'ECS_ENABLE_GPU_SUPPORT=true' >>/tmp/ecs/ecs.config
sudo mv /tmp/ecs/ecs.config /var/lib/ecs/ecs.config
