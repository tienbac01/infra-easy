## Deprecated (giữ để tương thích nhưng không còn dùng)
variable "vm_count" {
  type        = number
  description = "[DEPRECATED] Số lượng VM kiểu cũ"
  default     = 0
}

variable "vm_prefix" {
  type        = string
  description = "[DEPRECATED] Tiền tố tên VM kiểu cũ"
  default     = "vm"
}

variable "vcpus" {
  type        = number
  description = "Số vCPU mỗi VM"
  default     = 2
}

variable "memory_mb" {
  type        = number
  description = "RAM (MB) mỗi VM"
  default     = 4096
}

variable "pool" {
  type        = string
  description = "Libvirt storage pool"
  default     = "terraform"
}

variable "base_image_path" {
  type        = string
  description = "Đường dẫn Ubuntu cloud image (qcow2/img), bắt buộc."
  default     = "/mnt/data/terraform/images/ubuntu-24.04-server-cloudimg-amd64.img"
}

variable "os_disk_size_gb" {
  type        = number
  description = "Dung lượng disk mỗi VM (GB)"
  default     = 20
}

variable "network_name" {
  type        = string
  description = "Tên libvirt network"
  default     = "tf-net"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR mạng NAT (vd: 192.168.56.0/24)"
  default     = "192.168.56.0/24"
  validation {
    condition     = try(cidrhost(var.subnet_cidr, 0), null) != null
    error_message = "subnet_cidr phải hợp lệ."
  }
}

variable "ip_start" {
  type        = number
  description = "Host bắt đầu (vd 10 => .10, .11, ...)"
  default     = 10
}

variable "gateway_ip" {
  type        = string
  description = "Địa chỉ gateway trong cùng subnet"
  default     = "192.168.56.1"
}

variable "dns_servers" {
  type        = list(string)
  description = "Danh sách DNS"
  default     = ["8.8.8.8", "1.1.1.1"]
}

variable "ssh_authorized_keys" {
  type        = list(string)
  description = "Public SSH keys để inject vào VM"
  default     = []
}

variable "data_disk_device" {
  type        = string
  description = "Thiết bị data disk trong guest"
  default     = "/dev/vdb"
}

variable "data_fs" {
  type        = string
  description = "Filesystem cho data disk"
  default     = "ext4"
}

variable "data_mountpoint" {
  type        = string
  description = "Điểm mount data disk"
  default     = "/data"
}

variable "data_label" {
  type        = string
  description = "Nhãn filesystem"
  default     = "data"
}

variable "domain_suffix" {
  type        = string
  description = "Suffix FQDN ví dụ: srv.world"
  default     = "srv.world"
}

variable "manager_count" {
  type        = number
  description = "Số lượng Manager node"
  default     = 1
}

variable "control_plane_count" {
  type        = number
  description = "Số node control-plane"
  default     = 1
}

variable "worker_count" {
  type        = number
  description = "Số node worker"
  default     = 2
}

variable "manager_prefix" {
  type        = string
  description = "Tiền tố hostname cho Manager"
  default     = "ctrl"
}

variable "control_plane_prefix" {
  type        = string
  description = "Tiền tố hostname cho Control Plane"
  default     = "dlp"
}

variable "worker_prefix" {
  type        = string
  description = "Tiền tố hostname cho Worker"
  default     = "node"
}

variable "manager_ip_start" {
  type        = number
  description = "Host bắt đầu cho Manager (vd 25 => .25, .26, ...)"
  default     = 25
}

variable "control_plane_ip_start" {
  type        = number
  description = "Host bắt đầu cho Control Plane (vd 30 => .30, .31, ...)"
  default     = 30
}

variable "worker_ip_start" {
  type        = number
  description = "Host bắt đầu cho Worker (vd 51 => .51, .52, ...)"
  default     = 51
}

variable "admin_username" {
  type        = string
  description = "Tên user quản trị tạo bởi cloud-init"
  default     = "ubuntu"
}

variable "admin_password" {
  type        = string
  description = "Mật khẩu cho admin user (cloud-init)"
  sensitive   = true
  nullable    = true
  default     = null
}

# Deprecated: dùng để tương thích ngược. Ưu tiên dùng admin_password.
variable "ubuntu_password" {
  type        = string
  description = "[DEPRECATED] Mật khẩu cho user ubuntu (cloud-init)"
  sensitive   = true
  nullable    = true
  default     = null
}
