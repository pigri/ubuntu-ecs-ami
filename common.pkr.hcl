locals {
  default_tags = {
    os_version          = "Ubuntu 24.04"
    source_image_name   = "{{ .SourceAMIName }}"
    ecs_runtime_version = "Docker version ${var.docker_version_ubuntu2404}"
    ecs_agent_version   = "${var.ecs_agent_version}"
    ami_type            = "common"
  }
  merged_tags = merge(local.default_tags, var.tags)
}
