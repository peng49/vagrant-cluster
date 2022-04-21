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

# install java, zookeeper依赖java
sudo yum install -y java-1.8.0-openjdk

# install zookeeper
curl -L https://dlcdn.apache.org/zookeeper/zookeeper-3.7.0/apache-zookeeper-3.7.0-bin.tar.gz -o apache-zookeeper-3.7.0-bin.tar.gz
sudo tar -zxvf apache-zookeeper-3.7.0-bin.tar.gz -C /usr/local && sudo mv /usr/local/apache-zookeeper-3.7.0-bin /usr/local/zookeeper
sudo cp /usr/local/zookeeper/conf/zoo_sample.cfg /usr/local/zookeeper/conf/zoo.cfg

# 设置zookeeper数据存储路径
sudo mkdir -p /opt/data/zookeeper
sudo sed -ie 's/dataDir=\/tmp\/zookeeper/dataDir=\/opt\/data\/zookeeper/' /usr/local/zookeeper/conf/zoo.cfg

# 设置集群id
sudo touch /opt/data/zookeeper/myid

# shellcheck disable=SC2039
id=$(echo "${HOSTNAME}" | sed -e 's/zk0//g')
sudo bash -c "echo ${id} > /opt/data/zookeeper/myid"

# zoo.cfg添加集群配置
sudo bash -c 'cat <<EOF >> /usr/local/zookeeper/conf/zoo.cfg

server.1=192.165.34.21:2888:3888
server.2=192.165.34.22:2888:3888
server.3=192.165.34.23:2888:3888
EOF'


# 启动
# sudo /usr/local/zookeeper/bin/zkServer.sh start

# https://zhuanlan.zhihu.com/p/130265265
# zookeeper systemd 托管
sudo bash -c 'cat <<EOF > /usr/lib/systemd/system/zkServer.service
[Unit]
Description=Zookeeper server manager
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/zookeeper/bin/zkServer.sh start
ExecStop=/usr/local/zookeeper/bin/zkServer.sh stop
ExecReload=/usr/local/zookeeper/bin/zkServer.sh restart
Restart=always

[Install]
WantedBy=multi-user.target
EOF'
sudo systemctl start zkServer