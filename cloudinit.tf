# 3) Cloud-init ISO (user-data + network-config) cho từng VM
resource "libvirt_cloudinit_disk" "cidata" {
  for_each = local.indices

  name = "${var.vm_prefix}-${each.key}-cidata.iso"
  pool = var.pool

  user_data = templatefile("${path.module}/templates/cloud-init-userdata.yaml.tmpl", {
    hostname        = "${var.vm_prefix}-${each.key}"
    ssh_keys        = var.ssh_authorized_keys
    disk_block      = local.disk_block
    ubuntu_password = var.ubuntu_password
  })

  network_config = templatefile("${path.module}/templates/cloud-init-network.yaml.tmpl", {
    ip_addr = cidrhost(var.subnet_cidr, var.ip_start + tonumber(each.key) - 1)
    prefix  = local.prefix_len
    gateway = var.gateway_ip
    dns_list = var.dns_servers
    mac     = format("52:54:00:00:00:%02x", tonumber(each.key))
  })
}

