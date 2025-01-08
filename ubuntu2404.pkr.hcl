locals {
  ami_name_ubuntu2404 = "${var.ami_name_prefix_ubuntu2404}-hvm-${var.ami_version_ubuntu2404}-x86_64"
}

source "amazon-ebs" "ubuntu2404" {
  ami_name        = "${local.ami_name_ubuntu2404}"
  ami_description = "Ubuntu 24.04.${var.ami_version_ubuntu2404} x86_64 ECS HVM EBS"
  instance_type   = var.general_purpose_instance_types[0]
  launch_block_device_mappings {
    volume_size           = var.block_device_size_gb
    delete_on_termination = true
    volume_type           = "gp3"
    device_name           = "/dev/sda1"
  }
  region = var.region
  source_ami_filter {
    filters = {
      name = "${var.source_ami_ubuntu2404}"
    }
    owners             = ["099720109477"]
    most_recent        = true
    include_deprecated = true
  }
  ami_ou_arns   = "${var.ami_ou_arns}"
  ami_org_arns  = "${var.ami_org_arns}"
  ami_users     = "${var.ami_users}"
  ssh_interface = "public_ip"
  ssh_username  = "ubuntu"
  tags          = "${local.merged_tags}"
  run_tags      = "${var.run_tags}"
}

build {
  sources = [
    "source.amazon-ebs.ubuntu2404",
    "source.amazon-ebs.ubuntu2404arm",
    "source.amazon-ebs.ubuntu2404gpu",
    "source.amazon-ebs.ubuntu2404armgpu"
  ]

  provisioner "file" {
    source      = "files/90_ecs.cfg.ubuntu2404"
    destination = "/tmp/90_ecs.cfg"
  }

  provisioner "shell" {
    inline_shebang = "/bin/sh -ex"
    inline = [
      "sudo echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo mv /tmp/90_ecs.cfg /etc/cloud/cloud.cfg.d/90_ecs.cfg",
      "sudo chown root:root /etc/cloud/cloud.cfg.d/90_ecs.cfg"
    ]
  }

  provisioner "shell" {
    script = "scripts/ubuntu2404/setup-motd.sh"
  }

  provisioner "shell" {
    inline_shebang = "/bin/sh -ex"
    inline = [
      "mkdir /tmp/additional-packages"
    ]
  }

  provisioner "shell" {
    inline_shebang = "/bin/sh -ex"
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get dist-upgrade -y"
    ]
  }

  provisioner "shell" {
    inline_shebang = "/bin/sh -ex"
    inline = [
      "sudo apt-get install -y ${local.packages_ubuntu2404}"
    ]
  }

  provisioner "shell" {
    script = "scripts/setup-ecs-config-dir.sh"
  }

  provisioner "shell" {
    script = "scripts/install-docker.sh"
    environment_vars = [
      "DOCKER_VERSION=${var.docker_version_ubuntu2404}",
      "CONTAINERD_VERSION=${var.containerd_version_ubuntu2404}",
      "RUNC_VERSION=${var.runc_version_ubuntu2404}",
      "AIR_GAPPED=${var.air_gapped}"
    ]
  }

  provisioner "shell" {
    script = "scripts/install-ecs-init.sh"
    environment_vars = [
      "REGION=${var.region}",
      "AGENT_VERSION=${var.ecs_agent_version}",
      "INIT_REV=${var.ecs_init_rev}",
      "ECS_INIT_URL=${var.ecs_init_url_ubuntu2404}",
      "AIR_GAPPED=${var.air_gapped}",
      "ECS_INIT_LOCAL_OVERRIDE=${var.ecs_init_local_override}"
    ]
  }

  provisioner "shell" {
    script = "scripts/install-managed-daemons.sh"
    environment_vars = [
      "REGION=${var.region}",
      "AGENT_VERSION=${var.ecs_agent_version}",
      "EBS_CSI_DRIVER_VERSION=${var.ebs_csi_driver_version}",
      "AIR_GAPPED=${var.air_gapped}",
      "MANAGED_DAEMON_BASE_URL=${var.managed_daemon_base_url}"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "PLATFORM=${source.name}",
      "VERSION=${var.efs_utils_version}",
      "UBUNTU_VERSION=${var.distribution_release_ubuntu2404}"
    ]
    script = "scripts/install-efs-utils.sh"
  }

  provisioner "file" {
    source      = "additional-packages/"
    destination = "/tmp/additional-packages"
  }

  provisioner "shell" {
    script = "scripts/install-iptables.sh"
  }


  provisioner "shell" {
    script = "scripts/install-additional-packages.sh"
  }

  provisioner "shell" {
    script = "scripts/append-efs-client-info.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "AMI_TYPE=${source.name}",
      "AIR_GAPPED=${var.air_gapped}"
    ]
    script = "scripts/enable-ecs-agent-gpu-support.sh"
  }

  provisioner "shell" {
    script = "scripts/install-service-connect-appnet.sh"
  }


  ### reboot worker instance to install kernel update. enable-ecs-agent-inferentia-support needs
  ### new kernel (if there is) to be installed.
  provisioner "shell" {
    inline_shebang    = "/bin/sh -ex"
    expect_disconnect = "true"
    inline = [
      "sudo reboot"
    ]
  }

  provisioner "shell" {
    inline_shebang = "/bin/sh -ex"
    inline = [
      "sudo usermod -a -G docker ubuntu",
      "sudo newgrp docker"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "AMI_TYPE=${source.name}",
    ]
    script = "scripts/check-gpu.sh"
  }

  provisioner "shell" {
    script = "scripts/enable-services.sh"
  }

  provisioner "shell" {
    script = "scripts/cleanup.sh"
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
