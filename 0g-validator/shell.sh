#!/bin/bash

# 变量初始化
projectName=${PRJECT_NAME-"0g-validator"}
workDir="/$HOME/satea/$projectName"
dataDir="$HOME/satea/$projectName/data"
orderId=${ORDER_ID-"0"}
moniker=${MONIKER-"Test"}
walletName=${WALLET_NAME-"wallet"}
GO_VERSION="1.22.0"
PROJECT_VERSION="v0.2.5"

ALL_SATEA_VARS=("projectName" "moniker" "walletName")

mkdir -p $dataDir
cd $workDir

# 定义要检查的包列表
packages=(
    jq
    curl
    wget
)

# 检查并获取架构
ARCH=$(uname -m)

# 设置 Go 的版本

# 根据架构设置下载 URL
case $ARCH in
x86_64)
    PLATFORM="amd64"
    ;;
armv7l)
    PLATFORM="armv6l"
    ;;
aarch64)
    PLATFORM="arm64"
    ;;
arm64)
    PLATFORM="arm64"
    ;;
*)
    echo "不支持的架构: $ARCH"
    exit 1
    ;;
esac

function checkVars() {
    # 循环遍历数组
    for var_name in "${ALL_SATEA_VARS[@]}"; do
        # 动态读取变量的值
        value=$(eval echo \$$var_name)
        if [ -z "$value" ]; then
            # 如果为空，输出错误提示
            echo "Error: Variable $var_name is not set!"
            exit 1
        else
            # 如果不为空，输出变量名及其值
            echo "Variable $var_name value is $value"
        fi
    done
}

#手动模式下 解析并填入变量的函数
function readVariables() {
    >.env.sh
    chmod +x .env.sh
    for var_name in "${ALL_SATEA_VARS[@]}"; do
        read -p "Please input $var_name: " read_value
        echo "$var_name=$read_value" >>.env.sh
    done
}

# 检查并安装每个包
function checkPackages() {
    echo "check packages ..."
    for pkg in "${packages[@]}"; do
        if dpkg-query -W "$pkg" >/dev/null 2>&1; then
            echo "$pkg installed,skip"
        else
            echo "install  $pkg..."
            sudo apt update
            sudo apt install -y "$pkg"
        fi
    done
    go verison
}

function install() {

    if command -v go &>/dev/null; then
        INSTALLED_GO_VERSION=$(go version | awk '{print $3}' | cut -d "o" -f 2)
    else
        INSTALLED_GO_VERSION=""
    fi
    echo $INSTALLED_GO_VERSION
    if [ -z "$INSTALLED_GO_VERSION" ] || [ "$INSTALLED_GO_VERSION" != "$GO_VERSION" ]; then
        curl -L https://go.dev/dl/go$GO_VERSION.linux-$PLATFORM.tar.gz | tar -xzf - -C /usr/local
        echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >>$HOME/.bash_profile
        source $HOME/.bash_profile
        go version
    else
        echo "Go 环境已安装"
    fi
    git clone https://github.com/0glabs/0g-chain
    cd 0g-chain
    git checkout $PROJECT_VERSION

    # Build binary
    make install
    ln -s $HOME/go/bin/0gchaind /usr/local/go/bin
    # Set node CLI configuration
    0gchaind --home $dataDir config chain-id zgtendermint_16600-2
    0gchaind --home $dataDir config keyring-backend test
    0gchaind --home $dataDir config node tcp://localhost:27657

    # Initialize the node
    0gchaind --home $dataDir init "$moniker" --chain-id zgtendermint_16600-2

    # Download genesis and addrbook files
    curl -L https://snapshots-testnet.nodejumper.io/0g-testnet/genesis.json >$dataDir/config/genesis.json
    curl -L https://snapshots-testnet.nodejumper.io/0g-testnet/addrbook.json >$dataDir/config/addrbook.json

    # Set seeds
    sed -i -e 's|^seeds *=.*|seeds = "81987895a11f6689ada254c6b57932ab7ed909b6@54.241.167.190:26656,010fb4de28667725a4fef26cdc7f9452cc34b16d@54.176.175.48:26656,e9b4bc203197b62cc7e6a80a64742e752f4210d5@54.193.250.204:26656,68b9145889e7576b652ca68d985826abd46ad660@18.166.164.232:26656"|' $dataDir/config/config.toml

    # Set minimum gas price
    sed -i -e 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.0025ua0gi"|' $dataDir/config/app.toml

    # Set pruning
    sed -i \
        -e 's|^pruning *=.*|pruning = "custom"|' \
        -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
        -e 's|^pruning-interval *=.*|pruning-interval = "17"|' \
        $HOME/.0gchain/config/app.toml
    source $HOME/.bash_profile
}

function restart() {
    echo "restart ..."
    source $HOME/.bash_profile
    stop
    start
}

function start() {
    echo "start ..."
    source $HOME/.bash_profile
    checkVars
    # 按需添加脚本
    # 使用 PM2 启动节点进程
    pm2-runtime start --name "0gchaind" "0gchaind --home $dataDir start"
}

function stop() {
    echo "stop ..."
    source $HOME/.bash_profile
    # 按需添加脚本
    pm2 stop 0gchaind
}

function upgrade() {
    echo "upgrade ..."
    source $HOME/.bash_profile
    # 按需添加脚本
    rm -rf 0g-chain
    git clone -b $PROJECT_VERSION https://github.com/0glabs/0g-chain.git
    cd 0g-chain
    make install

    # update chain-id
    0gchaind --home $dataDir config chain-id zgtendermint_16600-2

    # download new genesis and addrbook
    curl -L https://snapshots-testnet.nodejumper.io/0g-testnet/genesis.json > $dataDir/config/genesis.json
    curl -L https://snapshots-testnet.nodejumper.io/0g-testnet/addrbook.json > $dataDir/config/addrbook.json

    # set new seeds
    sed -i -e 's|^seeds *=.*|seeds = "81987895a11f6689ada254c6b57932ab7ed909b6@54.241.167.190:26656,010fb4de28667725a4fef26cdc7f9452cc34b16d@54.176.175.48:26656,e9b4bc203197b62cc7e6a80a64742e752f4210d5@54.193.250.204:26656,68b9145889e7576b652ca68d985826abd46ad660@18.166.164.232:26656"|' $dataDir/config/config.toml

    # reset chain data
    0gchaind --home $dataDir tendermint unsafe-reset-all --keep-addr-book
}

function snapshot() {
    echo "snapshot ..."
    source $HOME/.bash_profile
    stop
    # 按需添加脚本
    sourceUrl=$1
    wget -c -O snapshot.tar.lz4 $sourceUrl
    cp $dataDir/data/priv_validator_state.json $dataDir/priv_validator_state.json.backup
    0gchaind --home $dataDir tendermint unsafe-reset-all --keep-addr-book
    lz4 -dc snapshot.tar.lz4 | tar -xf - -C "$dataDir"
    mv $HOME/.0gchain/priv_validator_state.json.backup $dataDir/data/priv_validator_state.json
    start
}

function check() {
    source $HOME/.bash_profile
    # 按需添加脚本
    officialNodeStatus=$(curl -s https://chainscan-newton.0g.ai/api/v2/stats)
    if [ "$officialNodeStatus" == "" ]; then
        cat <<EOF
        {
            "status": "Unknow",
            "pid": 0,
            "memory": 0,
            "cpu": 0,
            "blockDiff": 0
        }
EOF
    else
        total_blocks=$(echo $officialNodeStatus | jq .total_blocks | sed 's/^"\(.*\)"$/\1/')
        latest_block_height=$(0gchaind status | jq .sync_info.latest_block_height | sed 's/^"\(.*\)"$/\1/')
        blockDiff=$(expr $total_blocks - $latest_block_height)
        pm2Status=$(pm2 jlist)
        pid=$(echo $pm2Status | jq .[0].pid)
        memory=$(echo $pm2Status | jq .[0].monit.memory)
        cpu=$(echo $pm2Status | jq .[0].monit.cpu)
        cat <<EOF
        {
            "status": "Running",
            "orderId": $orderId,
            "pid": $pid,
            "memory": $memory,
            "cpu": $cpu,
            "synced_height": $latest_block_height,
            "block_diff": $blockDiff
        }
EOF
    fi

}

function clean() {
    echo "clean ...."
    # 按需添加脚本
    stop
    ########清理数据#########
    rm -rf $workDir
}

function logs() {
    echo "logs ...."
    # 按需添加脚本
    tail -f $dataDir/log/chain.log
}

function About() {
    echo '   _____    ___     ______   ______   ___
  / ___/   /   |   /_  __/  / ____/  /   |
  \__ \   / /| |    / /    / __/    / /| |
 ___/ /  / ___ |   / /    / /___   / ___ |
/____/  /_/  |_|  /_/    /_____/  /_/  |_|'

    echo
    echo -e "\xF0\x9F\x9A\x80 Satea Node Installer
Website: https://www.satea.io/
Twitter: https://x.com/SateaLabs
Discord: https://discord.com/invite/satea
Gitbook: https://satea.gitbook.io/satea
Version: V1.0.0
Introduction: Satea is a DePINFI aggregator dedicated to breaking down the traditional barriers that limits access to computing resources.  "
    echo""
}

case $1 in
pre-check)
    checkPackages
    ;;
install)
    if [ "$2" = "--auto" ]; then
        #这里使用自动模式下的 安装 函数
        install
    else
        #手动模式 使用Manual 获取用户输入的变量
        readVariables #获取用户输入的变量
        . .env.sh     #导入变量
        #其他安装函数
        install
    fi
    ;;
restart)
    #重新启动节点的函数
    restart
    ;;
start)
    #创建启动节点的函数
    start
    ;;
stop)
    #创建停止节点的函数
    stop
    ;;
upgrade)
    #创建升级节点的函数
    upgrade
    ;;
snapshot)
    #拉去快照数据
    snapshot $2
    ;;
check)
    #创建一些用于检查节点的函数
    check
    ;;
clean)
    #创建清除节点的函数
    clean
    ;;
logs)
    #打印节点信息
    logs
    ;;

**)

    #定义帮助信息 例子
    About
    echo "Flag:
  pre-check       Check basic installation package
  install              Install $projectName environment
  init                 Install Dependent packages
  restart               Restart the $projectName service
  start                Start the $projectName service
  stop                 Stop the $projectName service
  upgrade              Upgrade an existing installation of $projectName
  snapshot             Update $projectName snapshot data example: snapshot 'source url'
  check                Check $projectName service status
  clean                Remove the $projectName from your service, remove data!!! 
  logs                 Show the logs of the $projectName service"
    ;;
esac
