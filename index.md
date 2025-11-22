<link rel="stylesheet" href="prairie.css">

# Prairie

<!-- Prairie / Tactical Rancher Badges -->

<p align="left">

  <!-- Ansible -->
  <img src="https://img.shields.io/badge/Ansible-2.17+-30ba78?style=for-the-badge&logo=ansible&logoColor=white" />

  <!-- Rancher -->
  <img src="https://img.shields.io/badge/Rancher-2.9+-2453ff?style=for-the-badge&logo=rancher&logoColor=white" />

  <!-- k3s -->
  <img src="https://img.shields.io/badge/k3s-Latest-2453ff?style=for-the-badge&logo=kubernetes&logoColor=white" />

  <!-- Helm -->
  <img src="https://img.shields.io/badge/Helm-3+-192072?style=for-the-badge&logo=helm&logoColor=white" />

  <!-- Rocky Linux -->
  <img src="https://img.shields.io/badge/Rocky%20Linux-10-0c322c?style=for-the-badge&logo=rockylinux&logoColor=white" />

  <!-- DigitalOcean -->
  <img src="https://img.shields.io/badge/DigitalOcean-Supported-006aff?style=for-the-badge&logo=digitalocean&logoColor=white" />

  <!-- License -->
  <img src="https://img.shields.io/badge/License-Apache--2.0-30ba78?style=for-the-badge&logo=apache&logoColor=white" />



</p>


Prairie is a lightweight Ansible-driven deployer for standing up a fully functional Rancher environment on Rocky Linux 10.

It’s designed to take a clean Rocky 10 box (cloud image or bare-metal/VM), harden it just enough, install k3s, deploy Rancher via Helm, and leave you with a working Rancher UI at a known URL — without you having to click through a single web installer screen.

Prairie grew out of a real need: repeatable Rancher installs that work consistently across **DigitalOcean Rocky 10** images and **minimal ISOs**, and keep secrets out of logs.

---

## Goals

Prairie is built to:

- Automate **end-to-end Rancher deployment** on Rocky 10 using Ansible.
- Handle annoying platform differences (like missing `br_netfilter` on some cloud images).
- Keep sensitive data out of logs using **Ansible Vault** and `no_log: true`.
- Be **clone → init → run** simple for future-you and other operators.

---

## High-Level Flow

1. **Bootstrap secrets & vault**
   - Run:

     ```bash
     ./prairie/tools/ansible_init.sh
     ```

   - Script:
     - Creates `group_vars/cattle/vault.yml` with starter values.
     - Generates `.vault.key` (if missing) next to `ansible.cfg`.
     - Encrypts `vault.yml` with vault ID `default` via Ansible Vault.

2. **Prepare the host**
   - Ensure `br_netfilter` is present and loaded.
   - Configure it to load at boot for k3s/Rancher networking.
   - (Optional) Handle swap, basic hardening, etc.

3. **Install k3s**
   - Installs k3s using the recommended install script.
   - Ensures idempotency so reruns don’t break the cluster.

4. **Install Rancher via Helm**
   - Installs Helm (via the official Helm install script).
   - Adds required Helm repos.
   - Deploys Rancher into `cattle-system`.
   - Configures ingress/TLS based on your `vault_hostname`.

5. **Print the Rancher URL**
   - At the end of the Rancher role, Prairie prints:
     - `Rancher is available at: https://{{ vault_hostname }}/`

---

## Directory Layout

```text
prairie/
├── ansible.cfg
├── assets/
│   └── prairie.png          # Logo
├── group_vars/
│   └── cattle/
│       └── vault.yml        # Encrypted secrets (via ansible-vault)
├── inventory/
│   └── inventory.ini        # Your hosts/groups
├── roles/
│   └── rancher/
│       ├── defaults/
│       │   └── main.yml     # Rancher/k3s defaults
│       └── tasks/
│           ├── helm/        # Helm install, repos, charts
│           │   ├── build.yml
│           │   ├── install.yml
│           │   └── repos.yml
│           ├── k3s.yml      # k3s installation
│           ├── main.yml     # Entry point, includes others
│           └── swap.yml     # Swap handling (if needed)
├── seed_rancher.yml         # Main playbook (entrypoint)
└── tools/
    └── ansible_init.sh      # Vault/secret bootstrap script
```