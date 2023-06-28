#! /bin/bash

# 设置时区
sudo timedatectl set-timezone Asia/Shanghai

sudo curl -L -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#https://www.jianshu.com/p/2206cb265247
sudo sed -ri 's/cloud.aliyuncs/aliyun/g' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -ri 's/aliyuncs.com/aliyun.com/g' /etc/yum.repos.d/CentOS-Base.repo

sudo yum install -y epel-release
sudo yum clean all && sudo yum makecache

# ssh允许密码登录
sudo sed -ri 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# 允许root用户ssh登录
sudo sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

# install clickhouse
sudo yum-config-manager --add-repo https://packages.clickhouse.com/rpm/clickhouse.repo
sudo yum install -y clickhouse-server clickhouse-client

#sudo cp /etc/clickhouse-server/config.xml config.xml
sudo chmod 600 /etc/clickhouse-server/config.xml
sudo sed -i 's/<!-- <listen_host>0.0.0.0<\/listen_host> -->/<listen_host>0.0.0.0<\/listen_host>/' /etc/clickhouse-server/config.xml
#sudo curl https://raw.githubusercontent.com/ClickHouse/ClickHouse/master/programs/server/users.xml -o users.xml
sudo systemctl start clickhouse-server.service
sudo systemctl enable clickhouse-server.service
