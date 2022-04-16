#! /bin/sh
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

# shellcheck disable=SC2039
# shellcheck disable=SC2086
if [ ${HOSTNAME} == 'kafka01' ];then
# install java, zookeeper依赖java
sudo yum install -y java-1.8.0-openjdk

# install zookeeper
curl -L https://dlcdn.apache.org/zookeeper/zookeeper-3.7.0/apache-zookeeper-3.7.0-bin.tar.gz -o apache-zookeeper-3.7.0-bin.tar.gz
sudo tar -zxvf apache-zookeeper-3.7.0-bin.tar.gz -C /usr/local && sudo mv /usr/local/apache-zookeeper-3.7.0-bin /usr/local/zookeeper
sudo cp /usr/local/zookeeper/conf/zoo_sample.cfg /usr/local/zookeeper/conf/zoo.cfg
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

# install kafka
# https://www.orchome.com/6
# https://segmentfault.com/a/1190000038755877
curl -L https://archive.apache.org/dist/kafka/3.0.1/kafka_2.13-3.0.1.tgz -o kafka_2.13-3.0.1.tgz
sudo tar -zxvf kafka_2.13-3.0.1.tgz -C /usr/local/ && sudo mv /usr/local/kafka_2.13-3.0.1 /usr/local/kafka

sudo /usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties &


# 使用 docker安装mysql, logiKM需要
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker

# docker 安装 logiKM
# https://github.com/didi/LogiKM/blob/master/docs/install_guide/install_guide_docker_cn.md
sudo docker run --name mysql -p 3306:3306 --restart always -d registry.cn-hangzhou.aliyuncs.com/zqqq/logikm-mysql:5.7.37
sudo docker run --name logikm -p 8090:8080 --restart always --link mysql -d registry.cn-hangzhou.aliyuncs.com/zqqq/logikm:2.6.0

# 安装包 logiKM
# curl -L https://github.com/didi/LogiKM/releases/download/2.6.0/kafka-manager-2.6.0.tar.gz -o kafka-manager-2.6.0.tar.gz


# 安装 eagle https://www.kafka-eagle.org/articles/docs/installation/linux-macos.html
curl -L https://github.com/smartloli/kafka-eagle-bin/archive/v2.1.0.tar.gz -o kafka-eagle-bin-2.1.0.tar.gz
fi