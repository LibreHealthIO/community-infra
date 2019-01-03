resource "dme_record" "hostname" {
  domainid    = "${var.domain_dns["librehealth.org"]}"
  name        = "${var.hostname}"
  type        = "A"
  value       = "${openstack_compute_floatingip_v2.ip.address}"
  ttl         = 300
  gtdLocation = "DEFAULT"
}

resource "dme_record" "private_hostname" {
  count       = "${var.has_private_dns}"
  domainid    = "${var.domain_dns["librehealth.org"]}"
  name        = "${var.hostname}-internal"
  type        = "A"
  value       = "${openstack_compute_instance_v2.vm.network.0.fixed_ip_v4}"
  ttl         = 300
  gtdLocation = "DEFAULT"
}


resource "dme_record" "cnames" {
  count       = "${length(var.dns_cnames)}"
  domainid    = "${var.domain_dns["librehealth.org"]}"
  name        = "${element(var.dns_cnames, count.index)}"
  type        = "CNAME"
  value       = "${var.hostname}"
  ttl         = 3600
  gtdLocation = "DEFAULT"
}
