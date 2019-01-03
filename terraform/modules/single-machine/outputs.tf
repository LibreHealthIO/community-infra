output "address" {
  value = "${openstack_compute_floatingip_v2.ip.address}"
}

output "private_address" {
  value = "${openstack_compute_instance_v2.vm.network.0.fixed_ip_v4}"
}

output "vm_name" {
  value = "${openstack_compute_instance_v2.vm.name}"
}

output "backup_access_key_id" {
  value = "${element(concat(aws_iam_access_key.backup-user-key.*.id, list("")), 0)}"
}

output "backup_access_key_secret" {
  value = "${element(concat(aws_iam_access_key.backup-user-key.*.secret, list("")), 0)}"
}

output "dns_entries" {
  value = ["${dme_record.hostname.name}","${dme_record.cnames.*.name}"]
}

output "private-dns" {
  value = "${element(concat(dme_record.private_hostname.*.name, list("")), 0)}"
}
