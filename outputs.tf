output "vm_ips" {
  description = "Danh sách IP tĩnh theo hostname"
  value = merge(
    { for k in local.idx_manager : local.hn_manager[k] => cidrhost(var.subnet_cidr, var.manager_ip_start + tonumber(k) - 1) },
    { for k in local.idx_cp      : local.hn_cp[k]      => cidrhost(var.subnet_cidr, var.control_plane_ip_start + tonumber(k) - 1) },
    { for k in local.idx_worker  : local.hn_worker[k]  => cidrhost(var.subnet_cidr, var.worker_ip_start + tonumber(k) - 1) }
  )
}

output "ansible_inventory" {
  description = "Nội dung inventory Ansible (ini) theo mô hình"
  value = join(
    "\n",
    concat(
      [
        "[manager]"
      ],
      [
        for k in local.idx_manager :
        format(
          "%s ansible_host=%s ansible_user=%s",
          local.hn_manager[k],
          cidrhost(var.subnet_cidr, var.manager_ip_start + tonumber(k) - 1),
          var.admin_username
        )
      ],
      [
        "",
        "[kube_control_plane]"
      ],
      [
        for k in local.idx_cp :
        format(
          "%s ansible_host=%s ansible_user=%s",
          local.hn_cp[k],
          cidrhost(var.subnet_cidr, var.control_plane_ip_start + tonumber(k) - 1),
          var.admin_username
        )
      ],
      [
        "",
        "[kube_node]"
      ],
      [
        for k in local.idx_worker :
        format(
          "%s ansible_host=%s ansible_user=%s",
          local.hn_worker[k],
          cidrhost(var.subnet_cidr, var.worker_ip_start + tonumber(k) - 1),
          var.admin_username
        )
      ],
      [
        "",
        "[all:vars]",
        "ansible_python_interpreter=/usr/bin/python3"
      ]
    )
  )
}
