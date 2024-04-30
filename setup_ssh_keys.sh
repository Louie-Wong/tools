#!/bin/bash

# 设置SSH配置文件路径
ssh_config="/etc/ssh/sshd_config"

# 公钥内容
public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDmlK..."

# 确保脚本以root身份运行
if [[ $EUID -ne 0 ]]; then
   echo "请以root身份运行此脚本" 
   exit 1
fi

# 备份原始配置文件
cp $ssh_config $ssh_config.bak

# 设置SSH密钥认证并确保PermitRootLogin为without-password
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' $ssh_config
sed -i 's/^PermitRootLogin yes/PermitRootLogin without-password/' $ssh_config

# 设置RSAAuthentication为yes
if ! grep -q "^RSAAuthentication" $ssh_config; then
    echo "RSAAuthentication yes" >> $ssh_config
else
    sed -i 's/^RSAAuthentication .*/RSAAuthentication yes/' $ssh_config
fi

# 确保PubkeyAuthentication为yes
if ! grep -q "^PubkeyAuthentication" $ssh_config; then
    echo "PubkeyAuthentication yes" >> $ssh_config
else
    sed -i 's/^PubkeyAuthentication .*/PubkeyAuthentication yes/' $ssh_config
fi

# 重启SSH服务
service ssh restart

# 添加指定的公钥到root账户的authorized_keys文件
mkdir -p /root/.ssh
# 检查公钥是否已经存在于文件中
if ! grep -qFx "$public_key" /root/.ssh/authorized_keys; then
    echo "$public_key" >> /root/.ssh/authorized_keys
fi

echo "SSH配置已更新, 密码登录已禁用, root账户已设置为使用密钥登录, 并且指定的公钥已经添加到root账户的authorized_keys文件中。"
