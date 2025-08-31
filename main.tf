// Terraform được tách cấu trúc theo chuẩn:
// - locals.tf: biến local
// - network.tf: mạng libvirt
// - volumes.tf: volumes OS/data
// - cloudinit.tf: cloud-init ISO
// - domains.tf: định nghĩa VM
// Giữ provider.tf, variables.tf, outputs.tf như cũ.
