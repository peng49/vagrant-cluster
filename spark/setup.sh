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

sudo yum install -y java-11-openjdk-devel vim wget sshpass

cat <<EOF | tee -a /etc/hosts
192.168.35.11 name01
192.168.35.12 name02
192.168.35.13 data01
192.168.35.14 data02
192.168.35.15 data03
EOF

#设置HADOOP_HOME JAVA_HOME
JAVA_HOME=$(realpath /usr/bin/java | sed 's/bin\/java//')
HADOOP_HOME=/usr/local/hadoop

cat <<EOF | sudo tee -a /etc/bashrc
export JAVA_HOME=${JAVA_HOME}
export HADOOP_HOME=${HADOOP_HOME}
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin
EOF

sudo sed -i 's/\r//' /vagrant/"$(hostname -f)".sh
sudo bash /vagrant/"$(hostname -f)".sh
