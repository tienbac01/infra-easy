# 4) VM
resource "libvirt_domain" "vm" {
  for_each = local.indices

  name   = "${var.vm_prefix}-${each.key}"
  vcpu   = var.vcpus
  memory = var.memory_mb   # MiB

  network_interface {
    network_id = libvirt_network.net.id
    mac        = format("52:54:00:00:00:%02x", tonumber(each.key))
  }

  # OS disk
  disk {
    volume_id = libvirt_volume.os[each.key].id
  }

  # Data disk 300GB
  disk {
    volume_id = libvirt_volume.data[each.key].id
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

