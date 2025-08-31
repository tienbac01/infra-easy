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

