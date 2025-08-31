# 2) Upload base image vào pool (một lần)
resource "libvirt_volume" "os_base" {
  name   = "${var.vm_prefix}-base.qcow2"
  pool   = var.pool
  source = var.base_image_path
  format = "qcow2"
}

# 2a) Clone OS disk từ base volume cho từng VM (có thể set size)
resource "libvirt_volume" "os" {
  for_each = local.indices

  name           = "${var.vm_prefix}-${each.key}.qcow2"
  pool           = var.pool
  base_volume_id = libvirt_volume.os_base.id
  size           = var.os_disk_size_gb * 1024 * 1024 * 1024
  format         = "qcow2"
}

# 2b) Data disk 300GB (thin) cho từng VM — DÙNG for_each để khớp key
resource "libvirt_volume" "data" {
  for_each = local.indices

  name   = "${var.vm_prefix}-${each.key}-data.qcow2"
  pool   = var.pool
  size   = local.data_disk_size
  format = "qcow2"
}

