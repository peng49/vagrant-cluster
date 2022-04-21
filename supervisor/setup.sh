#! /bin/bash
# 设置时区
sudo timedatectl set-timezone Asia/Shanghai

sudo curl -L -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#https://www.jianshu.com/p/2206cb265247
sudo sed -ri 's/cloud.aliyuncs/aliyun/g' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -ri 's/aliyuncs.com/aliyun.com/g' /etc/yum.repos.d/CentOS-Base.repo

# ssh允许密码登录
sudo sed -ri 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# 允许root用户ssh登录
sudo sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

sudo yum clean all && sudo yum makecache

:<<!
# pip 安装 supervisor
sudo yum install -y python3-pip && sudo pip3 install supervisor

# 生成配置文件
sudo mkdir /etc/supervisor/
sudo bash -c '<<EOF > /etc/supervisor/supervisord.conf

EOF'

# 启动
!

# yum 安装 supervisor
sudo yum install -y epel-release && sudo yum install -y supervisor

