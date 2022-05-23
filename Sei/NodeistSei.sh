#!/bin/bash
echo "=================================================="
echo -e "\033[0;35m"
echo " | \ | |         | |    (_)   | |  ";
echo " |  \| | ___   __| | ___ _ ___| |_ ";
echo " |     |/ _ \ / _  |/ _ \ / __| __| ";
echo " | |\  | (_) | (_| |  __/ \__ \ |_ ";
echo " |_| \_|\___/ \__,_|\___|_|___/\__| ";
echo -e "\e[0m"
echo "=================================================="  

sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Node ismi yaziniz: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=sei-testnet-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo 'Node isminiz: ' $NODENAME
echo 'Cüzdan isminiz: ' $WALLET
echo 'Chain ismi: ' $CHAIN_ID
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Paketler güncelleniyor... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Bagliliklar yukleniyor... \e[0m" && sleep 1
# packages
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y

# install go
ver="1.17.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

echo -e "\e[1m\e[32m3. kutuphaneler indirilip yukleniyor... \e[0m" && sleep 1
# download binary
cd $HOME
git clone https://github.com/sei-protocol/sei-chain.git
cd sei-chain
git checkout 1.0.0beta
go build -o build/seid ./cmd/sei-chaind
chmod +x ./build/seid && mv ./build/seid /usr/local/bin/seid

# config
seid config chain-id $CHAIN_ID
seid config keyring-backend file

# init
seid init $NODENAME --chain-id $CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.sei-chain/config/genesis.json "https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-testnet-1/genesis.json"
wget -qO $HOME/.sei-chain/config/addrbook.json "https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-testnet-1/addrbook.json"

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0usei\"/" $HOME/.sei-chain/config/app.toml

# set peers and seeds
SEEDS=""
PEERS="27aab76f983cd7c6558f1dfc50b919daaef14555@3.22.112.181:26656,39c4bcaded0d1d886f2788ae955f1939406f3e7d@65.108.198.54:26696,2f2804434afda302c86eb89eca27503e49a8a260@65.21.131.215:26696,6f71bcbe347069fc4df9b607f6b843226e8deb71@95.217.221.201:26656,2f047e234cb8b99fe8b9fee0059a5bc45042bc97@95.216.84.188:26656,3cd0ccddaba6c662fb5f4836456f448f13653587@212.125.21.178:45656,9db58dba3b6354177fb428caccf5167c616ad4a1@167.235.28.18:26656,38b4d78c7d6582fb170f6c19330a7e37e6964212@194.163.189.114:46656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.sei-chain/config/config.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.sei-chain/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"

sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.sei-chain/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.sei-chain/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.sei-chain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.sei-chain/config/app.toml

# reset
seid unsafe-reset-all

echo -e "\e[1m\e[32m4. Servisler baslatiliyor... \e[0m" && sleep 1
# create service
tee $HOME/seid.service > /dev/null <<EOF
[Unit]
Description=seid
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which seid) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo mv $HOME/seid.service /etc/systemd/system/

# start service
sudo systemctl daemon-reload
sudo systemctl enable seid
sudo systemctl restart seid

echo '=============== KURULUM BASARIYLA TAMAMLANDI ==================='
echo -e 'Loglari kontrol et: \e[1m\e[32mjournalctl -ujournalctl -u seid -f -o cat\e[0m'
echo -e 'Senkronizasyon durumu kontrol et: \e[1m\e[32mcurl -s localhost:26657/status | jq .result.sync_info\e[0m'
