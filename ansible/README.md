# Ansible Structure (Best Practice)

This folder now follows a role-based structure with inventories and group vars.

## Layout

- `ansible.cfg`: points to `inventories/lab/hosts` and `roles/`
- `inventories/lab/hosts`: INI inventory for the lab environment
- `inventories/lab/group_vars/all.yml`: global variables for the lab
- `roles/`
  - `proxy/`: OS proxy + squid cert installer
  - `docker/`: Docker repository and packages
  - `images/`: Load offline Docker images
- `playbooks/`
  - `site.yml`: includes proxy, docker, images roles
  - `setup_proxy_and_docker.yml`: backward-compatible entry, now uses roles
- `inventory.ini`: kept for reference; prefer `inventories/lab/hosts`

## Run

Examples:

```bash
# Using default inventory configured in ansible.cfg
ansible-playbook playbooks/site.yml

# Or target specific roles via tags
ansible-playbook playbooks/setup_proxy_and_docker.yml --tags proxy,docker

# Using explicit inventory
ansible-playbook -i inventories/lab/hosts playbooks/site.yml
```

## Variables

Edit `inventories/lab/group_vars/all.yml` to change:

- `proxy_url`, `no_proxy`
- `install_script_url`, `install_script_path`
- `docker_repo_url`, `dpkg_arch_map`
- `offline_image_dir`, `offline_image_patterns`

## Notes

- Ubuntu-only targets are validated in `pre_tasks`.
