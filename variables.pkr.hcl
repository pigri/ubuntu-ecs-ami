packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  packages_ubuntu2404 = "gnupg2 ca-certificates curl nfs-common stunnel4 apparmor-utils apparmor-profiles"
}

variable "ami_name_prefix_ubuntu2404" {
  type        = string
  description = "Outputted AMI name prefix."
  default     = "openshield-community-ubuntu2404-ami-ecs"
}

variable "ami_version_ubuntu2404" {
  type        = string
  description = "Outputted AMI version."
}

variable "region" {
  type        = string
  description = "Region to build the AMI in."
}

variable "block_device_size_gb" {
  type        = number
  description = "Size of the root block device."
  default     = 30
}

variable "ecs_agent_version" {
  type        = string
  description = "ECS agent version to build AMI with."
  default     = "1.89.2"
}

variable "ecs_init_rev" {
  type        = string
  description = "ecs-init package version rev"
  default     = "1"
}

variable "docker_version" {
  type        = string
  description = "Docker version to build AMI with."
  default     = "25.0.6"
}

variable "containerd_version" {
  type        = string
  description = "Containerd version to build AMI with."
  default     = "1.7.20"
}

variable "runc_version" {
  type        = string
  description = "Runc version to build AMI with."
  default     = "1.1.14"
}

variable "docker_version_ubuntu2404" {
  type        = string
  description = "Docker version to build Ubuntu2404 AMI with."
  default     = "25.0.6"
}

variable "containerd_version_ubuntu2404" {
  type        = string
  description = "Containerd version to build Ubuntu2404 AMI with."
  default     = "1.7.20"
}

variable "runc_version_ubuntu2404" {
  type        = string
  description = "Runc version to build Ubuntu2404 AMI with."
  default     = "1.1.14"
}

variable "exec_ssm_version" {
  type        = string
  description = "SSM binary version to build ECS exec support with."
  default     = "3.3.859.0"
}

variable "source_ami_ubuntu2404" {
  type        = string
  description = "Ubuntu 24.04 source AMI to build from."
}

variable "source_ami_ubuntu2404arm" {
  type        = string
  description = "Ubuntu 24.04 ARM source AMI to build from."
}

variable "distribution_release_ubuntu2404" {
  type        = string
  description = "Ubuntu 24.04 distribution release."
}

variable "air_gapped" {
  type        = string
  description = "If this build is for an air-gapped region, set to 'true'"
  default     = ""
}

variable "ecs_init_url_ubuntu2404" {
  type        = string
  description = "Specify a particular ECS init URL for Ubuntu2404 to install. If empty it will use the standard path."
  default     = ""
}

variable "ecs_init_local_override" {
  type        = string
  description = "Specify a local init rpm under /additional-packages to be used for building AL2 and AL2023 AMIs. If empty it will use ecs_init_url if specified, otherwise the standard path"
  default     = ""
}

variable "general_purpose_instance_types" {
  type        = list(string)
  description = "List of available in-region instance types for general-purpose platform"
  default     = ["c5.large"]
}

variable "gpu_instance_types" {
  type        = list(string)
  description = "List of available in-region instance types for GPU platform"
  default     = ["g4dn.xlarge"]
}

variable "arm_instance_types" {
  type        = list(string)
  description = "List of available in-region instance types for ARM platform"
  default     = ["m6g.xlarge"]
}

variable "arm_gpu_instance_types" {
  type        = list(string)
  description = "List of available in-region instance types for ARM GPU platform"
  default     = ["g5g.xlarge"]
}

variable "managed_daemon_base_url" {
  type        = string
  description = "Base URL (minus file name) to download managed daemons from."
  default     = ""
}

variable "ebs_csi_driver_version" {
  type        = string
  description = "EBS CSI driver version to build AMI with."
  default     = ""
}

variable "ami_ou_arns" {
  type        = list(string)
  description = "A list of Amazon Resource Names (ARN) of AWS Organizations organizational units (OU) that have access to launch the resulting AMI(s)."
  default     = []
}

variable "ami_org_arns" {
  type        = list(string)
  description = "A list of Amazon Resource Names (ARN) of AWS Organizations that have access to launch the resulting AMI(s)."
  default     = []
}

variable "ami_users" {
  type        = list(string)
  description = "A list of account IDs that have access to launch the resulting AMI(s)."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the built AMI."
  default     = {}
}

variable "run_tags" {
  type        = map(string)
  description = "Tags to apply to resources (key-pair, SG, IAM, snapshot, interfaces and instance) used when building the AMI."
  default     = {}
}

variable "efs_utils_version" {
  type        = string
  description = "EFS utils version to build AMI with."
}
