## Triển khai K8s trên libvirt bằng Terraform + Ansible

**Yêu Cầu**
- Terraform >= 1.6, Ansible >= 2.13
- Máy chủ libvirt (qemu:///system), pool lưu trữ tồn tại (`variables.tf:29`)
- Ubuntu cloud image (mặc định `variables.tf:35`) và mạng NAT khả dụng
- SSH tới user `ubuntu` (cloud-init đã thêm key và/hoặc mật khẩu)

**Bước 1: Provision bằng Terraform**
- Khởi tạo và áp dụng:
  - `terraform init`
  - `terraform apply`
- Biến đáng chú ý:
  - `control_plane_count`: số node control-plane đầu tiên (`variables.tf:111`)
  - `ubuntu_password`: mật khẩu user ubuntu (nhạy cảm; xem `templates/cloud-init-userdata.yaml.tmpl:1`)
- IP tĩnh được gán theo `ip_start` (ví dụ `.11, .12, .13`) và match theo MAC (netplan template `templates/cloud-init-network.yaml.tmpl:1`).

**Bước 2: Tạo inventory cho Ansible**
- Sinh inventory từ Terraform output:
  - `terraform output -raw ansible_inventory > ansible/inventory.ini`
- Kiểm tra SSH:
  - `ansible -i ansible/inventory.ini all -m ping`
  - Nếu cần chỉ định key: `ansible -i ansible/inventory.ini all -m ping -u ubuntu --private-key ~/.ssh/id_rsa`

**Bước 3: Triển khai K8s bằng Ansible**
- Playbook chính (đã tách roles) nằm tại `ansible/site.yml:1`:
  - `ansible-playbook -i ansible/inventory.ini ansible/site.yml`
- Các giai đoạn (tags) để chạy lại có kiểm soát:
  - Bootstrap nodes: `--tags bootstrap`
  - Init control-plane đầu: `--tags init`
  - Join control-planes còn lại: `--tags join_cp`
  - Join workers: `--tags join_worker`
  - Cài Dashboard (UI): `--tags dashboard`
  - Ví dụ: `ansible-playbook -i ansible/inventory.ini ansible/site.yml --tags join_worker`
- Chạy giới hạn một vài host:
  - `--limit demo-2,demo-3` hoặc `--limit kube_node`

**Bước 4: Kiểm tra sức khỏe cụm**
- Playbook healthcheck: `ansible/k8s-healthcheck.yml:1`
  - `ansible-playbook -i ansible/inventory.ini ansible/k8s-healthcheck.yml`
- Kubeconfig trên control-plane đầu (`demo-1`): `/home/ubuntu/.kube/config`
  - Sao chép về máy quản trị: `scp ubuntu@demo-1:/home/ubuntu/.kube/config ~/.kube/demo.config`
  - `export KUBECONFIG=~/.kube/demo.config && kubectl get nodes -o wide`

**Dashboard (UI)**
- Được cài bởi role `k8s_dashboard` (gọi trong `ansible/site.yml:12`).
- URL: `https://<IP bất kỳ của node>:30080/`
- Token đăng nhập: trên `demo-1`, file `/home/ubuntu/dashboard-token.txt` (đã tạo khi cài đặt).

**Chạy Lại Ansible An Toàn**
- Playbook có cơ chế “run lock” nhẹ bằng `flock` để tránh chạy trùng (bật qua `ansible/group_vars/all.yml:1`).
- Các tác vụ đã idempotent (sử dụng `kubectl apply`, `apt`, `creates`, `changed_when: false`).
- Resume theo giai đoạn bằng tags (xem Bước 3).

**Sự Cố Thường Gặp và Cách Khắc Phục**
- IP tĩnh không áp dụng:
  - Kiểm tra `macaddress` đã được quote trong `templates/cloud-init-network.yaml.tmpl:4` và khớp với MAC đã set trong `domains.tf:9`.
  - VM đã tạo trước đó có thể cần recreate để cloud-init áp dụng lại: `terraform taint libvirt_domain.vm["1"]` rồi `terraform apply`.
- Hết dung lượng root khi cài đặt gói:
  - Tăng `os_disk_size_gb` (`variables.tf:41`) và apply lại; cloud-init có `resize_rootfs: true` (`templates/cloud-init-disk.yaml.tmpl:11`).
- Lỗi repo Kubernetes NO_PUBKEY/GPG:
  - Đã xử lý qua dearmored key và `signed-by` trong role `kubernetes` (`ansible/roles/kubernetes/tasks/main.yml:1`).
- Thay đổi cloud-init (user-data/network):
  - Cloud-init thường chỉ chạy lần đầu; để áp dụng thay đổi, nên taint/recreate VM.

**Cấu Trúc Thư Mục Quan Trọng**
- Terraform:
  - `locals.tf`, `network.tf`, `volumes.tf`, `cloudinit.tf`, `domains.tf`, `variables.tf`, `outputs.tf`, `provider.tf`
- Ansible:
  - `ansible/site.yml`, `ansible/inventory.ini`
  - Roles: `common`, `containerd`, `kubernetes`, `control_plane_init`, `join_control_plane`, `join_worker`, `k8s_dashboard`
  - Healthcheck: `ansible/k8s-healthcheck.yml`

**Mẹo**
- Tắt lock nếu muốn: sửa `ansible/group_vars/all.yml:2` thành `enable_run_lock: false`.
- Điều chỉnh số control-plane: cập nhật `control_plane_count` trong `terraform.tfvars:1` rồi `terraform apply`.

