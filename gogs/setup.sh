#! /bin/bash
# 设置时区
sudo timedatectl set-timezone Asia/Shanghai

sudo curl -L -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#https://www.jianshu.com/p/2206cb265247
sudo sed -ri 's/cloud.aliyuncs/aliyun/g' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -ri 's/aliyuncs.com/aliyun.com/g' /etc/yum.repos.d/CentOS-Base.repo

sudo yum clean all && sudo yum makecache

# 环境准备
sudo yum install -y git

# https://gogs.io/docs/installation/install_from_binary
# 二进制安装gogs
sudo curl -L https://dl.gogs.io/0.12.4/gogs_0.12.4_linux_amd64.tar.gz -o gogs.tar.gz \
  && sudo tar -xzvf gogs.tar.gz -C /usr/local

sudo useradd git
sudo chown -R git:git /usr/local/gogs/

sudo cp /vagrant/gogs.service /usr/lib/systemd/system/

sudo systemctl start gogs
sudo systemctl enable gogs


