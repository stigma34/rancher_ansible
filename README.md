# Prairie
## Automated Rancher deployer using Ansible [Work in Progress]

![Prairie Logo](assets/prairie.png)

### Important information

**Note:** This has been tested on Rocky Linux 10 (minimal ISO and Digital Ocean image)

**Note:** This currently only installs a single node - this is meant for spinning up a quick development environment essentially.  Work will be done over time to build this out into a full-fledged deployer of multi-node, etc.

**Note:** As of this writing, 11/22/2025, the version of Rancher that is being installed is - **v2.12.3**

### Pre-requisites

At this time, there really are none, the ansible_init.sh will pull down everything it needs for you.  I am leaving this section though for just in case something comes up in future releases.

### Installation

1.  Clone the repository to your target server - the one you want to become the single-node Rancher cluster.
2.  Run the **ansible_init.sh** script.  This will pull down all the necessary packages, setup your virtualenv, inject a vault for you to use, and encrypt it for you.  **Note:** You may need to reboot after this completes if `kernel-modules-extra` had to be installed or a new kernel, as you'll want everything as fresh as possible.

    ```bash
    ./prairie/tools/ansible_init.sh
    ```

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
    ansible-playbook seed_rancher.yml
    ```