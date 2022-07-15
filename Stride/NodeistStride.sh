#!/bin/bash
echo "=================================================="
echo "   _  ______  ___  __________________";
echo "  / |/ / __ \/ _ \/ __/  _/ __/_  __/";
echo " /    / /_/ / // / _/_/ /_\ \  / /   ";
echo "/_/|_/\____/____/___/___/___/ /_/    ";
echo -e "\e[0m"
echo "=================================================="                                     


sleep 2

# DEGISKENLER by Nodeist
STRD_WALLET=wallet
STRD=strided
STRD_ID=STRIDE-1
STRD_PORT=44
STRD_FOLDER=.stride
STRD_FOLDER2=stride
STRD_VER=c53f6c562d9d3e098aab5c27303f41ee055572cb
STRD_REPO=https://github.com/Stride-Labs/stride.git
STRD_GENESIS=https://raw.githubusercontent.com/Stride-Labs/testnet/main/poolparty/genesis.json
STRD_ADDRBOOK=
STRD_MIN_GAS=0
STRD_DENOM=ustrd
STRD_SEEDS=baee9ccc2496c2e3bebd54d369c3b788f9473be9@seedv1.poolparty.stridenet.co:26656
STRD_PEERS=b11187784240586475422b132a3dcbc970a996dd@stride-node1.poolparty.stridenet.co:26656,2312417b613c44164bf167cb232795e7d8815be7@65.108.76.44:11523,84ff28824a911409e2c24f2f5ede87ae1b859b5f@5.189.178.222:46656

sleep 1

echo "export STRD_WALLET=${STRD_WALLET}" >> $HOME/.bash_profile
echo "export STRD=${STRD}" >> $HOME/.bash_profile
echo "export STRD_ID=${STRD_ID}" >> $HOME/.bash_profile
echo "export STRD_PORT=${STRD_PORT}" >> $HOME/.bash_profile
echo "export STRD_FOLDER=${STRD_FOLDER}" >> $HOME/.bash_profile
echo "export STRD_FOLDER2=${STRD_FOLDER2}" >> $HOME/.bash_profile
echo "export STRD_VER=${STRD_VER}" >> $HOME/.bash_profile
echo "export STRD_REPO=${STRD_REPO}" >> $HOME/.bash_profile
echo "export STRD_GENESIS=${STRD_GENESIS}" >> $HOME/.bash_profile
echo "export STRD_PEERS=${STRD_PEERS}" >> $HOME/.bash_profile
echo "export STRD_SEED=${STRD_SEED}" >> $HOME/.bash_profile
echo "export STRD_MIN_GAS=${STRD_MIN_GAS}" >> $HOME/.bash_profile
echo "export STRD_MIN_GAS=${STRD_DENOM}" >> $HOME/.bash_profile
source $HOME/.bash_profile

sleep 1

if [ ! $STRD_NODENAME ]; then
  read -p "NODE ISMI YAZINIZ: " STRD_NODENAME
  echo 'export STRD_NODENAME='$STRD_NODENAME >> $HOME/.bash_profile
fi

echo -e "NODE ISMINIZ: \e[1m\e[32m$STRD_NODENAME\e[0m"
echo -e "CUZDAN ISMINIZ: \e[1m\e[32m$STRD_WALLET\e[0m"
echo -e "CHAIN ISMI: \e[1m\e[32m$STRD_ID\e[0m"
echo -e "PORT NUMARANIZ: \e[1m\e[32m$STRD_PORT\e[0m"
echo '================================================='

sleep 2


# GUNCELLEMELER by Nodeist
echo -e "\e[1m\e[32m1. GUNCELLEMELER YUKLENIYOR... \e[0m" && sleep 1
sudo apt update && sudo apt upgrade -y


# GEREKLI PAKETLER by Nodeist
echo -e "\e[1m\e[32m2. GEREKLILIKLER YUKLENIYOR... \e[0m" && sleep 1
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y

# GO KURULUMU by Nodeist
echo -e "\e[1m\e[32m1. GO KURULUYOR... \e[0m" && sleep 1
ver="1.18.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

sleep 1

# KUTUPHANE KURULUMU by Nodeist
echo -e "\e[1m\e[32m1. REPO YUKLENIYOR... \e[0m" && sleep 1
cd $HOME
git clone $STRD_REPO
cd $STRD_FOLDER2
git checkout $STRD_VER
sh ./scripts-local/build.sh -s $HOME/go/bin


sleep 1

# KONFIGURASYON by Nodeist
echo -e "\e[1m\e[32m1. KONFIGURASYONLAR AYARLANIYOR... \e[0m" && sleep 1
$STRD config chain-id $STRD_ID
$STRD config keyring-backend file
$STRD init $STRD_NODENAME --chain-id $STRD_ID

# ADDRBOOK ve GENESIS by Nodeist
wget $STRD_GENESIS -O $HOME/$STRD_FOLDER/config/genesis.json
wget $STRD_ADDRBOOK -O $HOME/$STRD_FOLDER/config/addrbook.json

# EŞLER VE TOHUMLAR by Nodeist
SEEDS="$STRD_SEEDS"
PEERS="$STRD_PEERS"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/$STRD_FOLDER/config/config.toml

sleep 1


# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$STRD_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$STRD_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$STRD_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$STRD_FOLDER/config/app.toml


# ÖZELLEŞTİRİLMİŞ PORTLAR by Nodeist
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${STRD_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${STRD_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${STRD_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${STRD_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${STRD_PORT}660\"%" $HOME/$STRD_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${STRD_PORT}317\"%; s%^address = \":8080\"%address = \":${STRD_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${STRD_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${STRD_PORT}091\"%" $HOME/$STRD_FOLDER/config/app.toml
sed -i.bak -e "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:${STRD_PORT}657\"%" $HOME/$STRD_FOLDER/config/client.toml

# PROMETHEUS AKTIVASYON by Nodeist
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/$STRD_FOLDER/config/config.toml

# MINIMUM GAS AYARI by Nodeist
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.00125$STRD_DENOM\"/" $HOME/$STRD_FOLDER/config/app.toml

# INDEXER AYARI by Nodeist
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/$STRD_FOLDER/config/config.toml

# RESET by Nodeist
$STRD tendermint unsafe-reset-all --home $HOME/$STRD_FOLDER

echo -e "\e[1m\e[32m4. SERVIS BASLATILIYOR... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/$STRD.service > /dev/null <<EOF
[Unit]
Description=$STRD
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which $STRD) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF


# SERVISLERI BASLAT by Nodeist
sudo systemctl daemon-reload
sudo systemctl enable $STRD
sudo systemctl restart $STRD

echo '=============== KURULUM TAMAM! by Nodeist ==================='
echo -e 'LOGLARI KONTROL ET: \e[1m\e[32mjournalctl -f $STRD\e[0m'
echo -e "SENKRONIZASYONU KONTROL ET: \e[1m\e[32mcurl -s localhost:${STRD_PORT}657/status | jq .result.sync_info\e[0m"

source $HOME/.bash_profile
