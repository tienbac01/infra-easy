# Ansible: Proxy + Squid Cert + Docker (Ubuntu)

This playbook configures a system-wide proxy, installs the Squid proxy certificate using the provided script, and installs Docker following the official Ubuntu guide.

## Files
- `ansible/playbooks/setup_proxy_and_docker.yml`: Main playbook with three tagged steps: `proxy`, `cert`, `docker`.
- `ansible/inventory.ini`: Sample inventory you can edit.
  
New in step 4: tag `images` to load offline Docker images from `/mnt/data`.

## Requirements
- Target hosts: Ubuntu (tested on 20.04/22.04/24.04).
- Ansible control machine can reach targets via SSH.

## Quick Start
1. Edit `ansible/inventory.ini` and add your hosts.
2. Run the full setup (all three steps):
   
   ```bash
   ansible-playbook -i ansible/inventory.ini ansible/playbooks/setup_proxy_and_docker.yml
   ```

3. Run a specific step with tags:
   - Proxy only:
     
     ```bash
     ansible-playbook -i ansible/inventory.ini ansible/playbooks/setup_proxy_and_docker.yml -t proxy
     ```
   - Install Squid cert (downloads and runs `install.sh add_cert`):
     
     ```bash
     ansible-playbook -i ansible/inventory.ini ansible/playbooks/setup_proxy_and_docker.yml -t cert
     ```
   - Install Docker (Ubuntu):
     
     ```bash
     ansible-playbook -i ansible/inventory.ini ansible/playbooks/setup_proxy_and_docker.yml -t docker
     ```

   - Load offline Docker images from `/mnt/data` (supports `.tar` and `.tar.gz`):
     
     ```bash
     ansible-playbook -i ansible/inventory.ini ansible/playbooks/setup_proxy_and_docker.yml -t images
     ```

## Variables
You can override variables at runtime with `-e` or via inventory/group vars.

- `proxy_url` (default `https://192.168.5.8:3128`)
- `no_proxy` (default covers localhost and RFC1918 ranges)
- `install_script_url` (default `https://192.168.5.8:3128/install.sh`)
- `offline_image_dir` (default `/mnt/data`)
- `offline_image_patterns` (default `['*.tar','*.tar.gz']`)

Examples:

```bash
ansible-playbook -i ansible/inventory.ini ansible/playbooks/setup_proxy_and_docker.yml \
  -e proxy_url=https://192.168.5.8:3128 \
  -e no_proxy="localhost,127.0.0.1,::1,192.168.0.0/16"
```

## Notes
- The playbook fetches the `install.sh` via HTTPS with `validate_certs: false` in case the proxy intercepts TLS before its CA is trusted. Adjust if your environment already trusts it.
- Docker repository setup follows the official docs: adds GPG key (dearmored), repository, then installs `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, `docker-compose-plugin`.
- A Docker systemd drop-in is created to pass proxy variables to the Docker service, then the service is enabled and started.
