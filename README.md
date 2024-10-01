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
```

## 🛠️ Node Installation

Set up the ZetaChain node by cloning the project repository and building the binary:

```bash
# Clone the ZetaChain project repository
cd && rm -rf node
git clone https://github.com/zeta-chain/node
cd node

# Checkout the specified version
git checkout v20.0.0

# Build the binary
make install
```

## ⚙️ Node Configuration
After building the binary, configure your node for running as a validator on the ZetaChain network:
```bash
# Prepare cosmovisor directories
mkdir -p $HOME/.zetacored/cosmovisor/genesis/bin
sudo ln -s $HOME/.zetacored/cosmovisor/genesis $HOME/.zetacored/cosmovisor/current -f
sudo ln -s $HOME/.zetacored/cosmovisor/current/bin/zetacored /usr/local/bin/zetacored -f

# Move the binary to cosmovisor directory
mv $(which zetacored) $HOME/.zetacored/cosmovisor/genesis/bin

# Set up CLI configuration
zetacored config chain-id zetachain_7000-1
zetacored config keyring-backend file
zetacored config node tcp://localhost:22557

# Initialize the node
zetacored init "Vixy" --chain-id zetachain_7000-1
```
## 🌐 Download Genesis and Addrbook Files
To sync with the ZetaChain network, download the genesis and addrbook files:
```bash
# Download genesis file
curl -L https://snapshots.nodejumper.io/zetachain/genesis.json > $HOME/.zetacored/config/genesis.json

# Download addrbook file
curl -L https://snapshots.nodejumper.io/zetachain/addrbook.json > $HOME/.zetacored/config/addrbook.json
```


