output "key-pair-name" {
  value = "${openstack_compute_keypair_v2.default-key-tacc.name}"
}

output "backup-bucket-name" {
  value = "${aws_s3_bucket.automatic-backups.bucket}"
}

output "backup-bucket-arn" {
  value = "${aws_s3_bucket.automatic-backups.arn}"
}
