#!/usr/bin/env bash
set -euo pipefail

# This script is expected to live at: prairie/tools/ansible_init.sh
# and be run from the repo root as: ./prairie/tools/ansible_init.sh


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "[+] Installing Ansible collections from requirements.yml..."
ansible-galaxy collection install -r "${PROJECT_ROOT}/collections/requirements.yml"

# Walk up until we find ansible.cfg – that directory is our repo root
ROOT_DIR="${SCRIPT_DIR}"
while [[ "${ROOT_DIR}" != "/" && ! -f "${ROOT_DIR}/ansible.cfg" ]]; do
  ROOT_DIR="$(dirname "${ROOT_DIR}")"
done

if [[ ! -f "${ROOT_DIR}/ansible.cfg" ]]; then
  echo "[prairie-init] ERROR: Could not find ansible.cfg above ${SCRIPT_DIR}" >&2
  exit 1
fi

echo "[prairie-init] Using repo root: ${ROOT_DIR}"

VAULT_KEY="${ROOT_DIR}/.vault.key"
VAULT_DIR="${ROOT_DIR}/group_vars/cattle"
VAULT_FILE="${VAULT_DIR}/vault.yml"

echo "[+] Updating system packages..."
dnf -y update

echo "[+] Installing required system packages..."
dnf -y install python3 python3-pip python3-devel gcc openssl-devel kernel-modules-extra

echo "[+] Creating Ansible virtual environment..."
python3 -m venv ~/ansible-venv

echo "[+] Activating virtual environment..."
source ~/ansible-venv/bin/activate

echo "[+] Upgrading pip and installing Ansible..."
pip install --upgrade pip wheel
pip install ansible ansible-lint

echo ""
echo "[+] Ansible installation complete!"
echo "[+] To activate your Ansible environment in the future, run:"
echo "     source ~/ansible-venv/bin/activate"
echo ""
echo "[+] To deactivate:"
echo "     deactivate"
echo ""
echo "[+] Version check:"
ansible --version

echo "[+] Ensure group_vars/cattle directory exists"
echo "[prairie-init] Ensuring vault directory exists: ${VAULT_DIR}"
mkdir -p "${VAULT_DIR}"

echo "[+] Create vault.yml with defaults if it doesn't exist yet"
if [[ ! -f "${VAULT_FILE}" ]]; then
  echo "[prairie-init] Creating initial vault.yml at ${VAULT_FILE}"
  cat > "${VAULT_FILE}" << 'EOF'
vault_hostname: your.hostname.tld
vault_bootstrap_password: "SuperSecret123!"
EOF
else
  echo "[prairie-init] vault.yml already exists, not overwriting."
fi

echo "[+] Create .vault.key if it doesn't exist"
if [[ ! -f "${VAULT_KEY}" ]]; then
  echo "[prairie-init] Generating .vault.key at ${VAULT_KEY}"
  openssl rand -base64 32 > "${VAULT_KEY}"
  chmod 600 "${VAULT_KEY}"
else
  echo "[prairie-init] .vault.key already exists, leaving as-is."
fi

echo "[+] Encrypt vault.yml with vault-id 'default' if not already encrypted"
if grep -q '^\$ANSIBLE_VAULT;' "${VAULT_FILE}"; then
  echo "[prairie-init] vault.yml is already encrypted. Skipping encryption."
else
  echo "[prairie-init] Encrypting vault.yml with vault-id 'default'"
  ansible-vault encrypt \
    --vault-id default@"${VAULT_KEY}" \
    "${VAULT_FILE}"
fi

echo "[prairie-init] Done."
echo "[prairie-init] Remember to keep .vault.key out of version control. (Already set in .gitignore)"