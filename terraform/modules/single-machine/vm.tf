resource "openstack_compute_floatingip_v2" "ip" {
  pool = "${var.pool}"
}

resource "openstack_compute_instance_v2" "vm" {
  name        = "${var.project_name}-${var.hostname}"
  image_id    = "${var.image}"
  flavor_name = "${var.flavor}"
  key_pair    = "${data.terraform_remote_state.base.key-pair-name}"

  network {
    uuid = "00000000-0000-0000-0000-000000000000"
    name = "public"
  }

  network {
    uuid = "11111111-1111-1111-1111-111111111111"
    name = "private"
  }
}

resource "openstack_compute_floatingip_associate_v2" "fip_vm" {
  floating_ip = "${openstack_compute_floatingip_v2.ip.address}"
  instance_id = "${openstack_compute_instance_v2.vm.id}"
}

resource "openstack_blockstorage_volume_v2" "data_volume" {
  count = "${var.has_data_volume}"
  name  = "${var.project_name}-data_volume"
  size  = "${var.data_volume_size}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_compute_volume_attach_v2" "attach_data_volume" {
  count       = "${var.has_data_volume}"
  depends_on  = ["openstack_blockstorage_volume_v2.data_volume", "openstack_compute_instance_v2.vm"]
  instance_id = "${openstack_compute_instance_v2.vm.id}"
  volume_id   = "${openstack_blockstorage_volume_v2.data_volume.id}"
}

resource "null_resource" "mount_data_volume" {
  count      = "${var.has_data_volume}"
  depends_on = ["openstack_compute_floatingip_associate_v2.fip_vm", "openstack_compute_volume_attach_v2.attach_data_volume"]

  connection {
    user        = "${var.ssh_username}"
    private_key = "${file(var.ssh_key_file)}"
    host        = "${openstack_compute_floatingip_v2.ip.address}"
  }

  provisioner "file" {
    source      = "../conf/provisioning/data_volume.sh"
    destination = "/tmp/data_volume.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "set -u",
      "set -x",
      "chmod a+x /tmp/data_volume.sh",
      "sudo /tmp/data_volume.sh",
    ]
  }
}

resource "null_resource" "setup-dns" {
  depends_on = ["null_resource.mount_data_volume"]

  connection {
    user        = "${var.ssh_username}"
    private_key = "${file(var.ssh_key_file)}"
    host        = "${openstack_compute_floatingip_v2.ip.address}"
  }

  provisioner "file" {
    source      = "../conf/provisioning/configure-dns.sh"
    destination = "/tmp/configure-dns.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "set -u",
      "set -x",
      "chmod a+x /tmp/configure-dns.sh",
      "sudo /tmp/configure-dns.sh",
    ]
  }
}

resource "null_resource" "upgrade" {
  count      = "${var.update_os}"
  depends_on = ["null_resource.setup-dns"]

  connection {
    user        = "${var.ssh_username}"
    private_key = "${file(var.ssh_key_file)}"
    host        = "${openstack_compute_floatingip_v2.ip.address}"
  }

  provisioner "file" {
    source      = "../conf/provisioning/upgrade.sh"
    destination = "/tmp/upgrade.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "set -u",
      "set -x",
      "chmod a+x /tmp/upgrade.sh",
      "sudo /tmp/upgrade.sh",
    ]
  }
}

data "template_file" "provisioning_file" {
  template = "${file("${path.module}/templates/provisioning_facts.tpl")}"

  vars {
    ansible_inventory = "${var.ansible_inventory}"
    region            = "${var.region}"
    has_backup        = "${var.has_backup}"
  }
}

resource "null_resource" "copy_facts" {
  count      = "${var.copy_ansible_facts}"
  depends_on = ["null_resource.upgrade"]

  connection {
    user        = "${var.ssh_username}"
    private_key = "${file(var.ssh_key_file)}"
    host        = "${openstack_compute_floatingip_v2.ip.address}"
  }

  provisioner "file" {
    content     = "${data.template_file.provisioning_file.rendered}"
    destination = "/tmp/provisioning.fact"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "set -u",
      "set -x",
      "sudo mkdir -p /etc/ansible/facts.d/",
      "sudo mv /tmp/provisioning.fact /etc/ansible/facts.d/",
      "sudo chown -R root:root /etc/ansible/facts.d/",
    ]
  }
}

data "template_file" "provisioning_file_backup" {
  count    = "${var.has_backup}"
  template = "${file("${path.module}/templates/provisioning_aws_facts.tpl")}"

  vars {
    aws_access_key_id     = "${aws_iam_access_key.backup-user-key.id}"
    aws_secret_access_key = "${aws_iam_access_key.backup-user-key.secret}"
  }
}

resource "null_resource" "copy_facts_backups" {
  count      = "${var.has_backup}"
  depends_on = ["null_resource.copy_facts"]

  connection {
    user        = "${var.ssh_username}"
    private_key = "${file(var.ssh_key_file)}"
    host        = "${openstack_compute_floatingip_v2.ip.address}"
  }

  provisioner "file" {
    content     = "${data.template_file.provisioning_file_backup.rendered}"
    destination = "/tmp/aws.fact"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "set -u",
      "set -x",
      "sudo mv /tmp/aws.fact /etc/ansible/facts.d/",
      "sudo chown -R root:root /etc/ansible/facts.d/",
    ]
  }
}

# ssh/scp from terraform stops working after this step
# global-variables need to use personal creds instead
resource "null_resource" "ansible" {
  count = "${var.use_ansible}"

  connection {
    user        = "${var.ssh_username}"
    private_key = "${file(var.ssh_key_file)}"
    host        = "${openstack_compute_floatingip_v2.ip.address}"
  }

  provisioner "file" {
    source      = "../conf/provisioning/ansible.sh"
    destination = "/tmp/ansible.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "set -u",
      "set -x",
      "chmod a+x /tmp/ansible.sh",
      "/tmp/ansible.sh \"${var.ansible_repo}\" ${var.ansible_inventory} ${var.hostname}",
    ]
  }
}
