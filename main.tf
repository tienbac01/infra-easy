locals {
  # dùng set(string) cho for_each: "1","2","3",...
  indices = toset([for i in range(1, var.vm_count + 1) : tostring(i)])

  prefix_len     = tonumber(split("/", var.subnet_cidr)[1])
  data_disk_size = 300 * 1024 * 1024 * 1024

  # tách snippet disk ra biến local để nhúng vào user_data
  disk_block = templatefile("${path.module}/templates/cloud-init-disk.yaml.tmpl", {
    data_disk_device = var.data_disk_device
    data_fs          = var.data_fs
    data_mountpoint  = var.data_mountpoint
    data_label       = var.data_label
  })
}

# 1) Network NAT, tắt DHCP để dùng IP tĩnh từ cloud-init
resource "libvirt_network" "net" {
  name      = var.network_name
  mode      = "nat"
  addresses = [var.subnet_cidr]

  dhcp { enabled = false }
  autostart = true
}

# 2) Clone OS disk từ base image cho từng VM
resource "libvirt_volume" "disk" {
  for_each = local.indices

  name   = "${var.vm_prefix}-${each.key}.qcow2"
  pool   = var.pool
  source = var.base_image_path
  format = "qcow2"  # clone qcow2 (thin)
}

# 2b) Data disk 300GB (thin) cho từng VM — DÙNG for_each để khớp key
resource "libvirt_volume" "data" {
  for_each = local.indices

  name   = "${var.vm_prefix}-${each.key}-data.qcow2"
  pool   = var.pool
  size   = local.data_disk_size
  format = "qcow2"  # thin provisioning
}

# 3) Cloud-init ISO (user-data + network-config) cho từng VM
resource "libvirt_cloudinit_disk" "cidata" {
  for_each = local.indices

  name = "${var.vm_prefix}-${each.key}-cidata.iso"
  pool = var.pool

  user_data = templatefile("${path.module}/templates/cloud-init-userdata.yaml.tmpl", {
    hostname   = "${var.vm_prefix}-${each.key}"
    ssh_keys   = var.ssh_authorized_keys
    disk_block = local.disk_block
  })

  network_config = templatefile("${path.module}/templates/cloud-init-network.yaml.tmpl", {
    ip_addr  = cidrhost(var.subnet_cidr, var.ip_start + tonumber(each.key))
    prefix   = local.prefix_len
    gateway  = var.gateway_ip
    dns_list = var.dns_servers
    iface    = "ens3"
  })
}

# 4) VM
resource "libvirt_domain" "vm" {
  for_each = local.indices

  name   = "${var.vm_prefix}-${each.key}"
  vcpu   = var.vcpus
  memory = var.memory_mb   # MiB

  network_interface {
    network_id = libvirt_network.net.id
    # wait_for_lease = true  # nếu muốn chờ DHCP/lease (không cần khi static IP)
  }

  # OS disk
  disk {
    volume_id = libvirt_volume.disk[each.key].id
  }

  # Data disk 300GB
  disk {
    volume_id = libvirt_volume.data[each.key].id
    # target  = "vdb"   # có thể cố định nếu bạn muốn khớp cloud-init
  }

  cloudinit = libvirt_cloudinit_disk.cidata[each.key].id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  autostart  = true
  depends_on = [libvirt_network.net]
}
