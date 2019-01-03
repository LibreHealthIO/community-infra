# any resources from the base stack
data "terraform_remote_state" "base" {
    backend = "s3"
    config {
        bucket = "librehealth-terraform-state-files"
        key    = "basic-network-setup.tfstate"
    }
}
