variable "image" {
  default = "13802433-11bd-4c3f-9e25-e36fa56fc166"
}

variable "ssh_key_file" {
  description = "SSH key used to provision VMs"
  default     = "../conf/provisioning/ssh/terraform-api.key"
}

variable "ansible_repo" {
  default = "https://gitlab.com/librehealth/lsc/community-infra.git"
}

variable "rax_url" {
  description = "Racksace auth url"
  default     = "https://identity.api.rackspacecloud.com/v2.0/"
}

variable "project_name" {
  description = "Project name for Rackspace"
  default     = "1024612"
}

variable "ssh_username" {
  default = "root"
}
