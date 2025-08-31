output "vm_ips" {
  description = "Danh sách IP tĩnh của các VM"
  value = {
    for k in local.indices :
    "${var.vm_prefix}-${k}" => cidrhost(var.subnet_cidr, var.ip_start + tonumber(k) - 1)
  }
}

output "ansible_inventory" {
  description = "Nội dung inventory Ansible (ini) cho cụm K8s"
  value = join(
    "\n",
    concat(
      [
        "[kube_control_plane]"
      ],
      [
        for k in local.indices :
        format(
          "%s-%s ansible_host=%s ansible_user=ubuntu",
          var.vm_prefix,
          k,
          cidrhost(var.subnet_cidr, var.ip_start + tonumber(k) - 1)
        ) if tonumber(k) <= var.control_plane_count
      ],
      [
        "",
        "[kube_node]"
      ],
      [
        for k in local.indices :
        format(
          "%s-%s ansible_host=%s ansible_user=ubuntu",
          var.vm_prefix,
          k,
          cidrhost(var.subnet_cidr, var.ip_start + tonumber(k) - 1)
        ) if tonumber(k) > var.control_plane_count
      ],
      [
        "",
        "[all:vars]",
        "ansible_python_interpreter=/usr/bin/python3"
      ]
    )
  )
}
