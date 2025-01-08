#!/usr/bin/env bash
set -ex

if [ $AMI_TYPE != "ubuntu2404gpu" ] && [ $AMI_TYPE != "ubuntu2404armgpu" ]; then
    echo "Skipping GPU support for $AMI_TYPE"
    exit 0
fi

sudo systemctl start docker

CUDA_SUPPORTED=$(sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi | grep 'CUDA Version' | wc -l)
if [ $CUDA_SUPPORTED -eq 0 ]; then
    echo "CUDA is not supported"
    exit 0
fi

sudo docker rmi -f ubuntu

echo "CUDA is supported"
