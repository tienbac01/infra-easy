# 3) Cloud-init ISO (user-data + network-config) cho từng VM
resource "libvirt_cloudinit_disk" "cidata_manager" {
  for_each = local.idx_manager

  name = "${var.manager_prefix}-${each.key}-cidata.iso"
  pool = var.pool

  user_data = templatefile("${path.module}/templates/cloud-init-userdata.yaml.tmpl", {
    hostname        = local.hn_manager[each.key]
    ssh_keys        = var.ssh_authorized_keys
    disk_block      = local.disk_block
    admin_username  = var.admin_username
    admin_password  = coalesce(var.admin_password, var.ubuntu_password)
  })

  network_config = templatefile("${path.module}/templates/cloud-init-network.yaml.tmpl", {
    ip_addr = cidrhost(var.subnet_cidr, var.manager_ip_start + tonumber(each.key) - 1)
    prefix  = local.prefix_len
    gateway = var.gateway_ip
    dns_list = var.dns_servers
    mac     = format("52:54:00:00:00:%02x", 10 + tonumber(each.key))
  })
}

resource "libvirt_cloudinit_disk" "cidata_cp" {
  for_each = local.idx_cp

  name = "${var.control_plane_prefix}-${each.key}-cidata.iso"
  pool = var.pool

  user_data = templatefile("${path.module}/templates/cloud-init-userdata.yaml.tmpl", {
    hostname        = local.hn_cp[each.key]
    ssh_keys        = var.ssh_authorized_keys
    disk_block      = local.disk_block
    admin_username  = var.admin_username
    admin_password  = coalesce(var.admin_password, var.ubuntu_password)
  })

  network_config = templatefile("${path.module}/templates/cloud-init-network.yaml.tmpl", {
    ip_addr = cidrhost(var.subnet_cidr, var.control_plane_ip_start + tonumber(each.key) - 1)
    prefix  = local.prefix_len
    gateway = var.gateway_ip
    dns_list = var.dns_servers
    mac     = format("52:54:00:00:00:%02x", 30 + tonumber(each.key))
  })
}

resource "libvirt_cloudinit_disk" "cidata_worker" {
  for_each = local.idx_worker

  name = "${var.worker_prefix}-${each.key}-cidata.iso"
  pool = var.pool

  user_data = templatefile("${path.module}/templates/cloud-init-userdata.yaml.tmpl", {
    hostname        = local.hn_worker[each.key]
    ssh_keys        = var.ssh_authorized_keys
    disk_block      = local.disk_block
    admin_username  = var.admin_username
    admin_password  = coalesce(var.admin_password, var.ubuntu_password)
  })

  network_config = templatefile("${path.module}/templates/cloud-init-network.yaml.tmpl", {
    ip_addr = cidrhost(var.subnet_cidr, var.worker_ip_start + tonumber(each.key) - 1)
    prefix  = local.prefix_len
    gateway = var.gateway_ip
    dns_list = var.dns_servers
    mac     = format("52:54:00:00:00:%02x", 50 + tonumber(each.key))
  })
}
