# 2) Upload base image vào pool (một lần)
resource "libvirt_volume" "os_base" {
  name   = "${var.vm_prefix}-base.qcow2"
  pool   = var.pool
  source = var.base_image_path
  format = "qcow2"
}

# 2a) Clone OS disk từ base volume cho từng VM (có thể set size)
resource "libvirt_volume" "os_manager" {
  for_each = local.idx_manager

  name           = "${var.manager_prefix}-${each.key}.qcow2"
  pool           = var.pool
  base_volume_id = libvirt_volume.os_base.id
  size           = var.os_disk_size_gb * 1024 * 1024 * 1024
  format         = "qcow2"
}

resource "libvirt_volume" "data_manager" {
  for_each = local.idx_manager

  name   = "${var.manager_prefix}-${each.key}-data.qcow2"
  pool   = var.pool
  size   = local.data_disk_size
  format = "qcow2"
}

resource "libvirt_volume" "os_cp" {
  for_each = local.idx_cp

  name           = "${var.control_plane_prefix}-${each.key}.qcow2"
  pool           = var.pool
  base_volume_id = libvirt_volume.os_base.id
  size           = var.os_disk_size_gb * 1024 * 1024 * 1024
  format         = "qcow2"
}

resource "libvirt_volume" "data_cp" {
  for_each = local.idx_cp

  name   = "${var.control_plane_prefix}-${each.key}-data.qcow2"
  pool   = var.pool
  size   = local.data_disk_size
  format = "qcow2"
}

resource "libvirt_volume" "os_worker" {
  for_each = local.idx_worker

  name           = "${var.worker_prefix}-${each.key}.qcow2"
  pool           = var.pool
  base_volume_id = libvirt_volume.os_base.id
  size           = var.os_disk_size_gb * 1024 * 1024 * 1024
  format         = "qcow2"
}

resource "libvirt_volume" "data_worker" {
  for_each = local.idx_worker

  name   = "${var.worker_prefix}-${each.key}-data.qcow2"
  pool   = var.pool
  size   = local.data_disk_size
  format = "qcow2"
}
