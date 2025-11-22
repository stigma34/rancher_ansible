# Changelog

All notable changes to **Prairie** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),  
and this project aims to follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- TODO: Document upcoming changes here.

---

## [0.1.0] - 2025-11-22

### Added
- Initial public release of **Prairie**.
- Ansible playbook `seed_rancher.yml` for end-to-end Rancher deployment on Rocky Linux 10.
- `rancher` role with tasks for:
  - k3s installation via upstream installer script.
  - Helm installation via official Helm script.
  - Rancher deployment into the `cattle-system` namespace.
  - Ingress/TLS wiring using `vault_hostname`.
- `ansible_init.sh` bootstrap script to:
  - Bootstrap Ansible installation
  - Create `group_vars/cattle/vault.yml` with starter secrets.
  - Generate `.vault.key` and configure Ansible Vault usage.
- Support for both:
  - DigitalOcean Rocky Linux 10 images.
  - Minimal Rocky 10 ISOs / bare-metal installs.
- Documentation and Tactical Rancher dark theme for GitHub Pages.
