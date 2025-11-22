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

<div class="tactical-button-wrapper">
  <a class="tactical-button" href="https://github.com/stigma34/prairie" target="_blank">
    Proceed to the Repository <span>// Begin Deployment</span>
  </a>
</div>

<br />

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
     - `Rancher is available at: "https://{{ vault_hostname }}/"`

---

<div class="incoming-features-card">
  <h2>Incoming Features <span>(SitRep)</span></h2>

  <div class="features-grid">

    <div class="feature-item">
      <h3>Multi-Distro Compatibility Package</h3>
      <p>
        Cross-train Prairie to deploy flawlessly on Fedora, RHEL/Rocky, Debian, and Ubuntu.
        One playbook. Any AO.
      </p>
    </div>

    <div class="feature-item">
      <h3>Hardened TLS Integration</h3>
      <p>
        Cert-manager or certbot-driven LE certs. Zero warnings. Zero nonsense.
        Full green-lock readiness.
      </p>
    </div>

    <div class="feature-item">
      <h3>Cluster Force Multiplication</h3>
      <p>
        Promote Prairie from single-node Recon to full multi-node Operations.
        Controller + worker nodes deployed with precision.
      </p>
    </div>

    <div class="feature-item">
      <h3>Prairie Command Pod</h3>
      <p>
        An Ansible-loaded, Kubernetes-resident control unit.
        Fire off cluster expansions and updates straight from the inside—no external operator required.
      </p>
    </div>

    <div class="feature-item">
      <h3>Role-Oriented Architecture Overhaul</h3>
      <p>
        Clean separation of responsibilities. Base ops, K3s provisioning, Rancher deployment,
        and TLS all compartmentalized like proper mission modules.
      </p>
    </div>

    <div class="feature-item">
      <h3>Automated Node Enrollment</h3>
      <p>
        Drop a new server into the field and let Prairie pull tokens, push configs,
        and slot it into the cluster without human intervention.
      </p>
    </div>

    <div class="feature-item">
      <h3>Security Posture Enhancement</h3>
      <p>
        Unified firewall doctrine, SSH lockdown, sysctl hardening, and distro-specific
        quirks neutralized on contact.
      </p>
    </div>

  </div>
</div>


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