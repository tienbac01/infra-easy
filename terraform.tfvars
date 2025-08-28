vm_count        = 3
vm_prefix       = "demo"
pool            = "terraform"
base_image_path = "/mnt/data/terraform/images/ubuntu-24.04-server-cloudimg-amd64.img"

network_name = "tf-net"
subnet_cidr  = "192.168.56.0/24"  
ip_start     = 10
gateway_ip   = "192.168.56.1"

ssh_authorized_keys = [
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDIrkSn3u1Z+Myot0XJdlwOaadcZCnAY+1ThAWcCcrnxeWa35vHj+lPx3M/i48/jwSP6+Df+zD4I5A/B2k8rviGuQDuwUJtTz7Yh1B82l0XuamSMGzmMu5i696MAb+NOU/4YcvCn+Wl8OUP6MbysrRmIoO7BBXLwTNt7iyg/5JL6FfHthLuGFcqKXsbzlqKTLC+NyiznBsv+fIscQEvQeoT1gLOK6nPC4RdVNhfRBqB0xwSDuNTCjxx3s+s3LIBBGE4juIeViCDeJUUKpkMexxXJ0HdBd50HBpFTrrEvnAGPAbMVqEwRcASmtIphQfk3zHydne147srwE6EmsW+mh+kvQw0sTVGlE/tvq/+9qTjr8TbaCChUhz3WQajS9G0zG5sKyGPtPL63yGM1JvXRWJ/CndmmS3TpVNgP/Bg3+wFlxKxj4X/WWxBgxbeMS+lG8t3CqgcIU1khzp7FkhllbYj1Q50BxQ9wKQSp2ergUrLKTnPVCT7JPl2T2Yif4o45B0= alex@alex"
]
