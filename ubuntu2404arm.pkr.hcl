locals {
  ami_name_ubuntu2404arm = "${var.ami_name_prefix_ubuntu2404}-hvm-2024.0.${var.ami_version_ubuntu2404}-arm64"
}

source "amazon-ebs" "ubuntu2404arm" {
  ami_name        = "${local.ami_name_ubuntu2404arm}"
  ami_description = "Ubuntu 24.04.${var.ami_version_ubuntu2404} arm64 ECS HVM EBS"
  instance_type   = var.arm_instance_types[0]
  launch_block_device_mappings {
    volume_size           = var.block_device_size_gb
    delete_on_termination = true
    volume_type           = "gp3"
    device_name           = "/dev/sda1"
  }
  region = var.region
  source_ami_filter {
    filters = {
      name = "${var.source_ami_ubuntu2404arm}"
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
