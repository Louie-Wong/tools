#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

function install_path() {
    cd $HOME
    mkdir swan
    
    # 设置变量
    PARENT_PATH="/root/swan"
    FIL_PROOFS_PARAMETER_CACHE="$PARENT_PATH"
    RUST_GPU_TOOLS_CUSTOM_GPU="GeForce RTX 4090:16384"

    # 设置.bashrc文件路径
    bashrc_file="$HOME/.bashrc"

    # 检查变量是否已经存在于.bashrc文件中
    if ! grep -q "export PARENT_PATH=\"\$PARENT_PATH\"" $bashrc_file; then
        echo "export PARENT_PATH=\"$PARENT_PATH\"" >> $bashrc_file
    fi

    if ! grep -q "export FIL_PROOFS_PARAMETER_CACHE=\"\$PARENT_PATH\"" $bashrc_file; then
        echo "export FIL_PROOFS_PARAMETER_CACHE=\"$PARENT_PATH\"" >> $bashrc_file
    fi

    if ! grep -q "export RUST_GPU_TOOLS_CUSTOM_GPU=\"GeForce RTX 4090:16384\"" $bashrc_file; then
        echo "export RUST_GPU_TOOLS_CUSTOM_GPU=\"GeForce RTX 4090:16384\"" >> $bashrc_file
    fi

    echo "Ctrl + C 退出后执行  source ~/.bashrc, 然后再次执行 ./Swan.sh 开始安装节点"
}

function install_node() {
    curl -fsSL https://raw.githubusercontent.com/swanchain/go-computing-provider/releases/ubi/setup.sh | bash

    echo "选择需要安装的版本 1->512MiB 2->32GiB, 输入1或者2"
    read -r -p "请确认: " ver_response

    rm -rf ~/swan/fetch.lock
    
    case "$ver_response" in
        [1]) 
            echo "开始下载 512MiB 版本..."
            curl -fsSL https://raw.githubusercontent.com/swanchain/go-computing-provider/releases/ubi/fetch-param-512.sh | bash
            echo "数据下载完成。"
            ;;
        [2]) 
            echo "开始下载 32GiB 版本..."
            curl -fsSL https://raw.githubusercontent.com/swanchain/go-computing-provider/releases/ubi/fetch-param-32.sh | bash
            echo "数据下载完成。"
            ;;
        *)
            echo "取消下载"
            ;;
    esac

    cd $HOME
    wget -O computing-provider https://github.com/swanchain/go-computing-provider/releases/download/v0.4.6/computing-provider
    chmod +x computing-provider

    echo "节点数据下载完成"
}

function init_node() {
    cd $HOME

    echo "请输入公网IP地址"
    read -r -p "IP: " host_ip
    echo "请输入公网端口"
    read -r -p "Port: " host_port
     echo "请给节点起个名字 eg. swan001"
    read -r -p "Node Name: " node_name

    ./computing-provider init --multi-address=/ip4/$host_ip/tcp/$host_port --node-name=$node_name

    echo "节点信息初始化完成"
}

function create_wallet() {
    cd $HOME

    ./computing-provider wallet new

    echo "钱包创建完成，请妥善保存"
}

function import_wallet() {
    cd $HOME

    echo "功能待更新"
}

function run_node() {
    cd $HOME
    echo "请确保钱包中有水!!!"
    echo "请输入钱包地址"
    read -r -p "addr: " wallet_addr

    ./computing-provider account create --ownerAddress $wallet_addr --ubi-flag=true

    nohup ./computing-provider ubi daemon >> cp.log 2>&1 &
    
    echo "节点运行成功"
}

# 主菜单
function main_menu() {
    while true; do
        clear
        echo "脚本以及教程由推特用户　小白日记|FACET @WHITECRPT 编写，免费开源"
        echo "=======================SWAN节点功能================================"
        echo "退出脚本，请按键盘ctrl c退出即可"
        echo "请选择要执行的操作:"
        echo "1. 配置环境变量"
        echo "2. 安装节点"
        echo "3. 初始化节点"
        echo "4. 创建钱包"
        echo "5. 导入钱包"
        echo "6. 运行节点"

        read -p "请输入选项（1-6）: " OPTION

        case $OPTION in
        1) install_path ;;
        2) install_node ;;
        3) init_node ;;
        4) create_wallet ;;
        5) import_wallet ;;
        6) run_node ;;
        *) echo "无效选项。" ;;
        esac
        echo "按任意键返回主菜单..."
        read -n 1
    done
    
}

# 显示主菜单
main_menu