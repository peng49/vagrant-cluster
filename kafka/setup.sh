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

HOST_IP=$(ip address |  grep 'global.*eth1' | awk '{print $2}' | sed -e 's/\/24//')

sudo yum install -y java-11-openjdk vim

sudo sed -i 's/\r//' /vagrant/"$(hostname -f)".sh

sudo bash /vagrant/"$(hostname -f)".sh

# Kafka Raft模式启动【不依赖zookeeper】

# https://github.com/apache/kafka/blob/trunk/config/kraft/README.md
# 设置node.id
# shellcheck disable=SC2039

id=${HOSTNAME//kafka0/}
sudo sed -ie "s/node.id=.*/node.id=${id}/" /usr/local/kafka/config/kraft/server.properties
# 设置投票节点
sudo sed -ie "s/controller.quorum.voters=.*/controller.quorum.voters=1@192.165.34.91:9093,2@192.165.34.92:9093,3@192.165.34.93:9093/" /usr/local/kafka/config/kraft/server.properties

# https://www.orchome.com/10533
# listeners 设置内网访问的端口号
# sudo sed -ie "s/^listeners=.*/listeners=PLAINTEXT:\/\/:9092,CONTROLLER:\/\/:9093/" /usr/local/kafka/config/kraft/server.properties

sudo sed -ie "s/advertised.listeners=.*/advertised.listeners=PLAINTEXT:\/\/${HOST_IP}:9092/" /usr/local/kafka/config/kraft/server.properties

uuid=$(cat /home/vagrant/uuid.txt)
sudo /usr/local/kafka/bin/kafka-storage.sh format -t "${uuid}" -c /usr/local/kafka/config/kraft/server.properties

#sudo /usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/kraft/server.properties

cat <<EOF | sudo tee /etc/systemd/system/kafka.service
[Unit]
Description=kafka Service
After=network-online.target
Requires=network-online.target

[Service]
Type=simple
Restart=on-failure
ExecStart=/usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/kraft/server.properties
ExecStop=/usr/local/kafka/bin/kafka-server-stop.sh /usr/local/kafka/config/kraft/server.properties

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable kafka
sudo systemctl start kafka