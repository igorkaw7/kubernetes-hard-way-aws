#!/bin/bash

# ------------------------------------------------------------------------------
# Initial Setup Script
#
# This script automates the initial setup of the terraform.tfvars file.
#
# What it does:
# 1. Checks if terraform.tfvars already exists to prevent overwriting.
# 2. Creates 'ssh' directory for storing the keys.
# 3. Checks for existing SSH keys in the 'ssh' directory.
# 4. If there are no keys found, it generates a new RSA key pair.
# 5. Discovers user's public IP address.
# 6. Creates the terraform.tfvars file by copying the example file.
# 7. Replaces the placeholder values in terraform.tfvars with the
#    discovered IP and SSH key paths.
# ------------------------------------------------------------------------------

set -e

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

TFVARS_FILE="terraform.tfvars"
TFVARS_EXAMPLE_FILE="terraform.tfvars.example"
SSH_DIR="ssh"
PRIVATE_KEY_PATH="${SSH_DIR}/id_rsa"
PUBLIC_KEY_PATH="${SSH_DIR}/id_rsa.pub"

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

info() {
    echo "INFO: $1"
}

error() {
    echo "ERROR: $1" >&2
    exit 1
}

# ------------------------------------------------------------------------------
# Script
# ------------------------------------------------------------------------------

if [ -f "$TFVARS_FILE" ]; then
    info "'$TFVARS_FILE' already exists. Skipping setup."
    exit 0
fi

info "Starting project setup..."

mkdir -p "$SSH_DIR"
info "Ensured '$SSH_DIR' directory exists."

if [ -f "$PRIVATE_KEY_PATH" ]; then
    info "Existing SSH key found at '$PRIVATE_KEY_PATH'. Using it."
else
    info "No SSH key found. Generating a new 4096-bit RSA key pair..."
    ssh-keygen -t rsa -b 4096 -f "$PRIVATE_KEY_PATH" -N "" -C "k8s-hard-way-key-rsa"
    info "New SSH key created at '$PRIVATE_KEY_PATH'."
fi

info "Discovering your public IP address..."
PUBLIC_IP=$(curl -s ifconfig.me)
if [ -z "$PUBLIC_IP" ]; then
    error "Could not determine public IP address. Please check your internet connection."
fi
info "Discovered public IP: $PUBLIC_IP"

info "Creating '$TFVARS_FILE' from example..."
cp "$TFVARS_EXAMPLE_FILE" "$TFVARS_FILE"

info "Populating '$TFVARS_FILE' with discovered values..."

sed -i.bak "s|YOUR_PUBLIC_IP_ADDRESS|$PUBLIC_IP|" "$TFVARS_FILE"
sed -i.bak "s|PATH_TO_PRIVATE_KEY|$PRIVATE_KEY_PATH|" "$TFVARS_FILE"
sed -i.bak "s|PATH_TO_PUBLIC_KEY|$PUBLIC_KEY_PATH|" "$TFVARS_FILE"

rm "${TFVARS_FILE}.bak"

info "Setup complete! '$TFVARS_FILE' has been created."
echo "You can now run 'terraform init' and 'terraform apply'."
