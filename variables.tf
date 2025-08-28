variable "vm_count" {
  type        = number
  description = "Số lượng VM cần tạo"
  default     = 3
  validation {
    condition     = var.vm_count >= 1
    error_message = "vm_count phải >= 1."
  }
}

variable "vm_prefix" {
  type        = string
  description = "Tiền tố tên VM"
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