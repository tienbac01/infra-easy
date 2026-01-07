locals {
  # Chỉ số cho từng nhóm
  idx_manager = toset([for i in range(1, var.manager_count + 1) : tostring(i)])
  idx_cp      = toset([for i in range(1, var.control_plane_count + 1) : tostring(i)])
  idx_worker  = toset([for i in range(1, var.worker_count + 1) : tostring(i)])

  prefix_len     = tonumber(split("/", var.subnet_cidr)[1])
  data_disk_size = 300 * 1024 * 1024 * 1024

  # tách snippet disk ra biến local để nhúng vào user_data
  disk_block = templatefile("${path.module}/templates/cloud-init-disk.yaml.tmpl", {
    data_disk_device = var.data_disk_device
    data_fs          = var.data_fs
    data_mountpoint  = var.data_mountpoint
    data_label       = var.data_label
    admin_username   = var.admin_username
  })

  # Tạo hostname FQDN cho từng nhóm
  hn_manager = {
    for k in local.idx_manager :
    k => format("%s%s.%s",
      var.manager_prefix,
      var.manager_count > 1 ? format("%02d", tonumber(k)) : "",
      var.domain_suffix
    )
  }

  hn_cp = {
    for k in local.idx_cp :
    k => format("%s%s.%s",
      var.control_plane_prefix,
      var.control_plane_count > 1 ? format("%02d", tonumber(k)) : "",
      var.domain_suffix
    )
  }

  hn_worker = {
    for k in local.idx_worker :
    k => format("%s%02d.%s",
      var.worker_prefix,
      tonumber(k),
      var.domain_suffix
    )
  }
}
