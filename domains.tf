# 4) VM
resource "libvirt_domain" "manager" {
  for_each = local.idx_manager

  name   = local.hn_manager[each.key]
  vcpu   = var.vcpus
  memory = var.memory_mb   # MiB

  network_interface {
    network_id = libvirt_network.net.id
    mac        = format("52:54:00:00:00:%02x", 10 + tonumber(each.key))
  }

  disk { volume_id = libvirt_volume.os_manager[each.key].id }
  disk { volume_id = libvirt_volume.data_manager[each.key].id }

  cloudinit = libvirt_cloudinit_disk.cidata_manager[each.key].id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  autostart  = true
  depends_on = [libvirt_network.net]
}

resource "libvirt_domain" "cp" {
  for_each = local.idx_cp

  name   = local.hn_cp[each.key]
  vcpu   = var.vcpus
  memory = var.memory_mb

  network_interface {
    network_id = libvirt_network.net.id
    mac        = format("52:54:00:00:00:%02x", 30 + tonumber(each.key))
  }

  disk { volume_id = libvirt_volume.os_cp[each.key].id }
  disk { volume_id = libvirt_volume.data_cp[each.key].id }

  cloudinit = libvirt_cloudinit_disk.cidata_cp[each.key].id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  autostart  = true
  depends_on = [libvirt_network.net]
}

resource "libvirt_domain" "worker" {
  for_each = local.idx_worker

  name   = local.hn_worker[each.key]
  vcpu   = var.vcpus
  memory = var.memory_mb

  network_interface {
    network_id = libvirt_network.net.id
    mac        = format("52:54:00:00:00:%02x", 50 + tonumber(each.key))
  }

  disk { volume_id = libvirt_volume.os_worker[each.key].id }
  disk { volume_id = libvirt_volume.data_worker[each.key].id }

  cloudinit = libvirt_cloudinit_disk.cidata_worker[each.key].id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  autostart  = true
  depends_on = [libvirt_network.net]
}
