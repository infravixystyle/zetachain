# 🚀 ZetaChain Node Setup Guide

This guide will help you set up and configure a ZetaChain validator node from scratch, including dependencies installation, building from source, and setting up a service using `cosmovisor`.

---
## Automatic installation 
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
wget https://raw.githubusercontent.com/zeta-chain/network-config/main/mainnet/genesis.json -O ~/.zetacored/config/genesis.json

# Download addrbook file
wget https://raw.githubusercontent.com/zeta-chain/network-config/main/mainnet/addrbook.json -O ~/.zetacored/config/addrbook.json
```
## 🔧 Further Configuration
Apply further configurations to ensure the node is properly set up:
```bash
# Set seeds
sed -i -e 's|^seeds *=.*|seeds = "20e1000e88125698264454a884812746c2eb4807@seeds.lavenderfive.com:22556,1d41d344d3370d2ba54332de4967baa5cbd70a06@rpc.zetachain.nodestake.org:666,ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@seeds.polkachu.com:22556,8d93468c6022fb3b263963bdea46b0a131d247cd@34.28.196.79:26656,637077d431f618181597706810a65c826524fd74@zetachain.rpc.nodeshub.online:22556"|' $HOME/.zetacored/config/config.toml

# Set minimum gas price
sed -i -e 's|^minimum-gas-prices *=.*|minimum-gas-prices = "20000000000azeta"|' $HOME/.zetacored/config/app.toml

# Set pruning options
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "17"|' \
  $HOME/.zetacored/config/app.toml

# Change ports in configuration files
sed -i -e "s%:1317%:22517%; s%:8080%:22580%; s%:9090%:22590%; s%:9091%:22591%; s%:8545%:22545%; s%:8546%:22546%; s%:6065%:22565%" $HOME/.zetacored/config/app.toml
sed -i -e "s%:26658%:22558%; s%:26657%:22557%; s%:6060%:22560%; s%:26656%:22556%; s%:26660%:22561%" $HOME/.zetacored/config/config.toml
```
## 🛠️ Install Cosmovisor
```bash
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.6.0
```

## 🧑‍💻 Create a Systemd Service
To ensure that your node automatically starts on reboot and runs as a background service, create a systemd service:
```bash
sudo tee /etc/systemd/system/zetachain.service > /dev/null << EOF
[Unit]
Description=ZetaChain node service
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$HOME/.zetacored
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.zetacored"
Environment="DAEMON_NAME=zetacored"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable the service
sudo systemctl daemon-reload
sudo systemctl enable zetachain.service

# Start the service and check the logs
sudo systemctl start zetachain.service
sudo journalctl -u zetachain.service -f --no-hostname -o cat
```

## 🎉 Congratulations!
Your ZetaChain node is now installed and running.


