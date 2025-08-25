output "vm_ips" {
  description = "Danh sách IP tĩnh của các VM"
  value = {
    for k in local.indices :
    "${var.vm_prefix}-${k}" => cidrhost(var.subnet_cidr, var.ip_start + tonumber(k))
  }
}
