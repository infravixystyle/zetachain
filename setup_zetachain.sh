#!/bin/bash

# Set variables
NODE_NAME="Vixy"
CHAIN_ID="zetachain_7000-1"
NODE_DIR="$HOME/.zetacored"
GO_VERSION="1.22.7"

# Update and install dependencies
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt install -y curl git jq lz4 build-essential

# Install Go
echo "Installing Go $GO_VERSION..."
sudo rm -rf /usr/local/go
curl -L https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.profile
source $HOME/.profile

# Clone the ZetaChain repository and build
echo "Cloning ZetaChain repository and building the node..."
cd $HOME && rm -rf node
git clone https://github.com/zeta-chain/node
cd node
git checkout v20.0.0
make install

# Set up cosmovisor directories
echo "Setting up Cosmovisor directories..."
mkdir -p $NODE_DIR/cosmovisor/genesis/bin
sudo ln -s $NODE_DIR/cosmovisor/genesis $NODE_DIR/cosmovisor/current -f
sudo ln -s $NODE_DIR/cosmovisor/current/bin/zetacored /usr/local/bin/zetacored -f
mv $(which zetacored) $NODE_DIR/cosmovisor/genesis/bin

# Configure node
echo "Configuring node..."
zetacored config chain-id $CHAIN_ID
zetacored config keyring-backend file
zetacored config node tcp://localhost:22557
zetacored init "$NODE_NAME" --chain-id $CHAIN_ID

# Download genesis and addrbook using wget
echo "Downloading genesis and addrbook files..."
wget https://raw.githubusercontent.com/zeta-chain/network-config/main/mainnet/genesis.json -O $NODE_DIR/config/genesis.json
wget https://raw.githubusercontent.com/zeta-chain/network-config/main/mainnet/addrbook.json -O $NODE_DIR/config/addrbook.json

# Set seeds and other configurations
echo "Configuring seeds, gas prices, pruning, and ports..."
sed -i -e 's|^seeds *=.*|seeds = "20e1000e88125698264454a884812746c2eb4807@seeds.lavenderfive.com:22556,1d41d344d3370d2ba54332de4967baa5cbd70a06@rpc.zetachain.nodestake.org:666,ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@seeds.polkachu.com:22556,8d93468c6022fb3b263963bdea46b0a131d247cd@34.28.196.79:26656,637077d431f618181597706810a65c826524fd74@zetachain.rpc.nodeshub.online:22556"|' $NODE_DIR/config/config.toml
sed -i -e 's|^minimum-gas-prices *=.*|minimum-gas-prices = "20000000000azeta"|' $NODE_DIR/config/app.toml
sed -i -e 's|^pruning *=.*|pruning = "custom"|' \
       -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
       -e 's|^pruning-interval *=.*|pruning-interval = "17"|' \
       $NODE_DIR/config/app.toml
sed -i -e "s%:1317%:22517%; s%:8080%:22580%; s%:9090%:22590%; s%:9091%:22591%; s%:8545%:22545%; s%:8546%:22546%; s%:6065%:22565%" $NODE_DIR/config/app.toml
sed -i -e "s%:26658%:22558%; s%:26657%:22557%; s%:6060%:22560%; s%:26656%:22556%; s%:26660%:22561%" $NODE_DIR/config/config.toml

# Install Cosmovisor
echo "Installing Cosmovisor..."
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.6.0

# Create systemd service for the node
echo "Creating systemd service for ZetaChain node..."
sudo tee /etc/systemd/system/zetachain.service > /dev/null << EOF
[Unit]
Description=ZetaChain node service
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$NODE_DIR
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
Environment="DAEMON_HOME=$NODE_DIR"
Environment="DAEMON_NAME=zetacored"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable zetachain.service
sudo systemctl start zetachain.service

# Monitor the service logs
echo "Node is set up and running. Monitoring logs..."
sudo journalctl -u zetachain.service -f --no-hostname -o cat
