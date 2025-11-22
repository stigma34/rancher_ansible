#!/usr/bin/env bash
set -euo pipefail

# This script is expected to live at: prairie/tools/ansible_init.sh
# and be run from the repo root as: ./prairie/tools/ansible_init.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

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

# ---------------------------------------------------------------------------
# OS detection + package install
# ---------------------------------------------------------------------------

if command -v dnf >/dev/null 2>&1; then
  PKG_MGR="dnf"
elif command -v apt-get >/dev/null 2>&1; then
  PKG_MGR="apt"
else
  echo "[prairie-init] ERROR: Neither dnf nor apt-get found. Unsupported platform." >&2
  exit 1
fi

echo "[+] Detected package manager: ${PKG_MGR}"

if [[ "${PKG_MGR}" == "dnf" ]]; then
  echo "[+] Updating system packages (dnf)..."
  dnf -y update

  echo "[+] Installing required system packages (dnf)..."
  dnf -y install \
    python3 \
    python3-pip \
    python3-devel \
    python3-virtualenv \
    gcc \
    openssl-devel \
    kernel-modules-extra

elif [[ "${PKG_MGR}" == "apt" ]]; then
  echo "[+] Updating system packages (apt)..."
  apt-get update -y

  echo "[+] Installing required system packages (apt)..."
  # python3-venv is important here so `python3 -m venv` actually works
  apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential \
    libssl-dev
fi

# ---------------------------------------------------------------------------
# Python virtualenv + Ansible
# ---------------------------------------------------------------------------

echo "[+] Creating Ansible virtual environment..."
python3 -m venv ~/ansible-venv

echo "[+] Activating virtual environment..."
# shellcheck disable=SC1090
source ~/ansible-venv/bin/activate

echo "[+] Upgrading pip and installing Ansible..."
pip install --upgrade pip wheel
pip install ansible ansible-lint

echo "[+] Installing Ansible collections from requirements.yml..."
ansible-galaxy collection install -r "${PROJECT_ROOT}/collections/requirements.yml"

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

# ---------------------------------------------------------------------------
# Vault setup
# ---------------------------------------------------------------------------

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
