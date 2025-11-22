#!/usr/bin/env bash
set -e

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

