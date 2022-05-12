#! /bin/bash
# 设置时区
sudo timedatectl set-timezone Asia/Shanghai

sudo curl -L -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#https://www.jianshu.com/p/2206cb265247
sudo sed -ri 's/cloud.aliyuncs/aliyun/g' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -ri 's/aliyuncs.com/aliyun.com/g' /etc/yum.repos.d/CentOS-Base.repo

sudo yum clean all && sudo yum makecache

# ssh允许密码登录
sudo sed -ri 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# 允许root用户ssh登录
sudo sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

# 安装 shasum 命令对应的库
sudo yum install perl-Digest-SHA -y


sudo mkdir /etc/elasticsearch/config -p

sudo sed -i 's/\r//' /vagrant/"$(hostname -f)".sh
sudo bash /vagrant/"$(hostname -f)".sh

sudo rsync -av rsyn001@192.168.34.11::downloads /home/vagrant/downloads --password-file=/opt/sync.pass || :

# 复制文件到指定目录
sudo cp /home/vagrant/downloads/elastic-certificates.p12 /etc/elasticsearch/config/
sudo cp /home/vagrant/downloads/elastic-stack-ca.p12 /etc/elasticsearch/config/

# 开启x-pack功能，并指定证书位置
cat <<EOF | sudo tee -a /etc/elasticsearch/elasticsearch.yml

xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
# https://elasticsearch.cn/?/question/7776
# xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.verification_mode: none
xpack.security.transport.ssl.keystore.path: config/elastic-certificates.p12
xpack.security.transport.ssl.truststore.path: config/elastic-certificates.p12
EOF

# 为每个节点添加密码
echo "" | sudo /usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password
echo "" | sudo /usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password

sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch
