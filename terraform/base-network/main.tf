# state file stored in S3
terraform {
  backend "s3" {
    bucket = "librehealth-terraform-state-files"
    key    = "basic-network-setup.tfstate"
  }
}

provider "openstack" {
  auth_url = "${var.rax_url}"
  alias    = "rax"
}
