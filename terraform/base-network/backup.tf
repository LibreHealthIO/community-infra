resource "aws_s3_bucket" "automatic-backups" {
  bucket = "librehealth-backups"

  lifecycle_rule {
    id      = "archive-and-delete"
    prefix  = ""
    enabled = true

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 180
    }
  }

  versioning {
    enabled = true
  }

  logging {
    target_bucket = "${aws_s3_bucket.log_bucket.id}"
    target_prefix = "log/"
  }

  tags {
    Terraform = "base-network"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "librehealth-backups-logs"
  acl    = "log-delivery-write"

  tags {
    Terraform = "base-network"
  }
}

resource "aws_s3_bucket" "manual-backups" {
  bucket = "librehealth-manual-backup"

  versioning {
    enabled = true
  }

  tags {
    Terraform = "base-network"
  }

  lifecycle {
    prevent_destroy = true
  }
}
