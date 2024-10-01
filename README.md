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
