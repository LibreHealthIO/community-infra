output "backup_access_key_id" {
  value = "${aws_iam_access_key.backup-user-key.id}"
}

output "backup_access_key_secret" {
  value = "${aws_iam_access_key.backup-user-key.secret}"
}
