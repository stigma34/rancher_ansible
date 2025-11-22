# Prairie
## Automated Rancher deployer using Ansible [Work in Progress]

![Prairie Logo](assets/prairie.png)

### Important information

**Note:** This has been tested on Rocky Linux 10 (minimal ISO and Digital Ocean image) and assumes you are working with a fresh install.

**Note:** This currently only installs a single node - this is meant for spinning up a quick development environment essentially.  Work will be done over time to build this out into a full-fledged deployer of multi-node, etc.

**Note:** As of this writing, 11/22/2025, the version of Rancher that is being installed is - **v2.12.3**

### Pre-requisites

At this time, there really are none, the ansible_init.sh will pull down everything it needs for you.  I am leaving this section though for just in case something comes up in future releases.

### Installation

1.  Clone the repository to your target server - the one you want to become the single-node Rancher cluster.
2.  Run the **ansible_init.sh** script.  This will pull down all the necessary packages, setup your virtualenv, inject a vault for you to use, and encrypt it for you.

    ```bash
    ./prairie/tools/ansible_init.sh
    ```
    
    **Note:** You may need to reboot after this completes if `kernel-modules-extra` had to be installed or a new kernel, as you'll want everything as fresh as possible.

3.  Source your virtualenv to start working on it.

    ```bash
    source ~/ansible-venv/bin/activate
    ```

4.  Modify your vault values to be correct for your environment (The ansible.cfg is already configured to let you edit the vault without specifying the decryption file).

    ```bash
    cd prairie && ansible-vault edit group_vars/cattle/vault.yml
    ```

5.  Go ahead and run the playbook at this point.

    ```bash
    ansible-playbook site.yml
    ```

### Incoming Features (SitRep)

**Multi-Distro Compatibility Package**
Cross-train Prairie to deploy flawlessly on Fedora, RHEL/Rocky, Debian, and Ubuntu. One playbook. Any AO.

**Hardened TLS Integration**
Cert-manager or certbot-driven LE certs. Zero warnings. Zero nonsense. Full green-lock readiness.

**Cluster Force Multiplication**
Promote Prairie from single-node Recon to full multi-node Operations. Controller + worker nodes deployed with precision.

**Prairie Command Pod**
An Ansible-loaded, Kubernetes-resident control unit. Fire off cluster expansions and updates straight from the inside—no external operator required.

**Role-Oriented Architecture Overhaul**
Clean separation of responsibilities. Base ops, K3s provisioning, Rancher deployment, and TLS all compartmentalized like proper mission modules.

**Automated Node Enrollment**
Drop a new server into the field and let Prairie pull tokens, push configs, and slot it into the cluster without human intervention.

**Security Posture Enhancement**
Unified firewall doctrine, SSH lockdown, sysctl hardening, and distro-specific quirks neutralized on contact.