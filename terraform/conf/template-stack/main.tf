# state file stored in S3
terraform {
  backend "s3" {
    bucket = "librehealth-terraform-state-files"
    key    = "STACK-NAME.tfstate"
  }
}

provider "openstack" {
  auth_url = "${var.rax_url}"
}

# Description of arguments can be found in
# ../modules/single-machine/variables.tf in this repository
module "single-machine" {
  source = "../modules/single-machine"

  # Change values in variables.tf file instead
  flavor            = "${var.flavor}"
  hostname          = "${var.hostname}"
  region            = "${var.region}"
  update_os         = "${var.update_os}"
  use_ansible       = "${var.use_ansible}"
  ansible_inventory = "${var.ansible_inventory}"
  has_data_volume   = "${var.has_data_volume}"
  data_volume_size  = "${var.data_volume_size}"
  has_backup        = "${var.has_backup}"
  dns_cnames        = "${var.dns_cnames}"

  # Global variables
  # Don't change values below
  image = "${var.image}"

  project_name = "${var.project_name}"
  ssh_username = "${var.ssh_username}"
  ssh_key_file = "${var.ssh_key_file}"
  domain_dns   = "${var.domain_dns}"
  ansible_repo = "${var.ansible_repo}"
}
