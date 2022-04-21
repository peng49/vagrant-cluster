#! /bin/bash
# 设置时区
sudo timedatectl set-timezone Asia/Shanghai

sudo curl -L -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#https://www.jianshu.com/p/2206cb265247
sudo sed -ri 's/cloud.aliyuncs/aliyun/g' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -ri 's/aliyuncs.com/aliyun.com/g' /etc/yum.repos.d/CentOS-Base.repo

sudo bash -c 'cat <<EOF > /etc/yum.repos.d/mongodb-org-4.4.repo
[mongodb-org-4.4]
name=MongoDB Repository
baseurl=https://mirrors.tuna.tsinghua.edu.cn/mongodb/yum/el\$releasever-4.4/
gpgcheck=0
enabled=1
EOF'

sudo yum clean all && sudo yum makecache

#sudo bash -c 'cat <<EOF > /etc/yum.repos.d/mongodb-org-4.4.repo
#[mongodb-org-4.4]
#name=MongoDB Repository
#baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/4.4/x86_64/
#gpgcheck=1
#enabled=1
#gpgkey=https://www.mongodb.org/static/pgp/server-4.4.asc
#EOF'



sudo yum install -y mongodb-org

# https://tongblog.us/blogs/0013
# 允许远程访问
sudo sed -ri 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf

sudo systemctl enable mongod

sudo systemctl stop firewalld
sudo systemctl disable firewalld




