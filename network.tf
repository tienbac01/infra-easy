# 1) Network NAT, tắt DHCP để dùng IP tĩnh từ cloud-init
resource "libvirt_network" "net" {
  name      = var.network_name
  mode      = "nat"
  addresses = [var.subnet_cidr]

  dhcp { enabled = false }
  autostart = true
}

