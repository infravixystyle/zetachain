# 🚀 ZetaChain Node Setup Guide

This guide will help you set up and configure a ZetaChain validator node from scratch, including dependencies installation, building from source, and setting up a service using `cosmovisor`.

---

## 📋 **Dependencies Installation**

First, update your system and install the necessary dependencies for building the node from source:

```bash
# Update system packages
sudo apt update

# Install dependencies
sudo apt install -y curl git jq lz4 build-essential

# Remove any previous Go installation
sudo rm -rf /usr/local/go

# Download and install Go 1.22.7
curl -L https://go.dev/dl/go1.22.7.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local

# Add Go to your PATH
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.profile
source .profile
