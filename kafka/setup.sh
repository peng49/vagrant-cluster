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

HOST_IP=$(ip address |  grep 'global.*eth1' | awk '{print $2}' | sed -e 's/\/24//')

sudo yum install -y java-11-openjdk

# shellcheck disable=SC2039
# shellcheck disable=SC2086
if [ ${HOSTNAME} == 'kafka01' ];then

# install kafka
# https://www.orchome.com/6
# https://segmentfault.com/a/1190000038755877
curl -L https://dlcdn.apache.org/kafka/3.1.0/kafka_2.13-3.1.0.tgz -o kafka_2.13-3.0.1.tgz
sudo tar -zxvf kafka_2.13-3.0.1.tgz -C /usr/local/ && sudo mv /usr/local/kafka_2.13-3.0.1 /usr/local/kafka

# 放开 #listeners=PLAINTEXT://:9092 前的注释
#sudo sed -ie 's/#listeners/listeners/' /usr/local/kafka/config/server.properties
#sudo sed -ie 's/broker.id=0/broker.id=1/' /usr/local/kafka/config/server.properties
#sudo sed -ie "s/#advertised.listeners=PLAINTEXT:\/\/your.host.name:9092/advertised.listeners=PLAINTEXT:\/\/${HOST_IP}:9092/" /usr/local/kafka/config/server.properties
#sudo /usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties

#Kafka Raft模式启动【不依赖zookeeper】
# 设置node.id
id=$(echo "${HOSTNAME}" | sed -e 's/kafka0//g')
sudo sed -ie "s/node.id=.*/node.id=${id}/" /usr/local/kafka/config/kraft/server.properties
# 设置投票节点
sudo sed -ie "s/controller.quorum.voters=.*/controller.quorum.voters=1@192.165.34.91:9093,2@192.165.34.92:9093,3@192.165.34.93:9093/" /usr/local/kafka/config/kraft/server.properties

# https://www.orchome.com/10533
sudo sed -ie "s/^listeners=.*/listeners=PLAINTEXT:\/\/${HOST_IP}:9092,CONTROLLER:\/\/${HOST_IP}:9093/" /usr/local/kafka/config/kraft/server.properties

sudo sed -ie "s/advertised.listeners=.*/advertised.listeners=PLAINTEXT:\/\/${HOST_IP}:9092/" /usr/local/kafka/config/kraft/server.properties

uuid=$(sudo /usr/local/kafka/bin/kafka-storage.sh random-uuid)
sudo /usr/local/kafka/bin/kafka-storage.sh format -t ${uuid} -c /usr/local/kafka/config/kraft/server.properties

#sudo /usr/local/kafka/bin/kafka-server-start.sh  /usr/local/kafka/config/kraft/server.properties




#
## 使用 docker安装mysql, logiKM需要
#sudo yum install -y yum-utils
#sudo yum-config-manager \
#    --add-repo \
#    https://download.docker.com/linux/centos/docker-ce.repo
#sudo yum install -y docker-ce docker-ce-cli containerd.io
#sudo systemctl start docker
#sudo systemctl enable docker
#
## docker 安装 logiKM
## https://github.com/didi/LogiKM/blob/master/docs/install_guide/install_guide_docker_cn.md
#sudo docker run --name mysql -p 3306:3306 --restart always -d registry.cn-hangzhou.aliyuncs.com/zqqq/logikm-mysql:5.7.37
#sudo docker run --name logikm -p 8090:8080 --restart always --link mysql -d registry.cn-hangzhou.aliyuncs.com/zqqq/logikm:2.6.0
#
## 安装包 logiKM
## curl -L https://github.com/didi/LogiKM/releases/download/2.6.0/kafka-manager-2.6.0.tar.gz -o kafka-manager-2.6.0.tar.gz
#
#
## 安装 eagle https://www.kafka-eagle.org/articles/docs/installation/linux-macos.html
#curl -L https://github.com/smartloli/kafka-eagle-bin/archive/v2.1.0.tar.gz -o kafka-eagle-bin-2.1.0.tar.gz && \
#  sudo tar -zxvf kafka-eagle-bin-2.1.0.tar.gz && \
#  sudo tar -zxvf kafka-eagle-bin-2.1.0/efak-web-2.1.0-bin.tar.gz -C /usr/local && \
#  sudo mv /usr/local/efak-web-2.1.0 /usr/local/efak
#
#sudo bash -c 'cat <<EOF >> /etc/profile
#
#export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.322.b06-1.el7_9.x86_64
#export KE_HOME=/usr/local/efak
#export PATH=\$PATH:\$KE_HOME/bin
#EOF'
#
#source /etc/profile
#sudo mkdir -p /opt/kafka-eagle/db/
#sudo chmod +x /usr/local/efak/bin/ke.sh
#sudo cp /vagrant/system-config.properties /usr/local/efak/conf/system-config.properties

# https://www.jianshu.com/p/bd3ae9d8069c
sudo mkdir /etc/rsync
#sudo touch /etc/rsync/rsyncd.conf
sudo touch /etc/rsync/rsyncd.secrets
sudo touch /etc/rsync/rsyncd.motd
# 权限必须600
sudo chmod 600 /etc/rsync/rsyncd.secrets
sudo bash -c "echo 'vagrant:123456' > /etc/rsync/rsyncd.secrets"

sudo bash -c "cat <<EOF > /etc/rsyncd.conf
uid = vagrant
gid = vagrant
use chroot = yes

#address = 192.165.34.91
#port = 873

# 是否只读,只读表示客户端不能上传文件
read only = yes
# 设置并发连接数，0代表无限制。超出并发数后，如果依然有客户端连接请求，则将会收到稍后重试的提示消息
max connections = 4
pid file = /var/run/rsyncd.pid

# 设置密码验证文件名称，注意该文件的权限要求为只读，建议权限为600，仅在设置 auth users 参数后有效
# 此处设置表示全局，也可在模块中单独设置
secrets file = /etc/rsync/rsyncd.secrets
# 连接成功提示信息,在motd文件中编写
motd file = /etc/rsync/rsyncd.motd
# 设置日志文件名称
log file = /var/log/rsync.log
# 设置锁文件名称
#lock file = /var/run/rsync.lock
# exclude = lost+found/
# 是否开启Rsync数据传输日志功能
# transfer logging = yes
timeout = 900
ignore nonreadable = yes
dont compress = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2

# 设置允许哪些主机可以同步数据，可以是单个IP，也可以是网段，多个IP与网段之间使用空格分隔
hosts allow=192.165.34.1/24
# 设置拒绝所有（除hosts allow定义的主机外）
hosts deny=*
# 模块，Rsync通过模块定义同步的目录，模块以[name]的形式定义，
# 这与Samba定义共享目录是一样的效果。在Rsync中也可以定义多个模块
[vagranthome]
        path = /home/vagrant
        #忽略一些IO错误
        ignore errors
        # comment定义注释说明字串
        comment = sync vagrant home
        # exclude可以指定例外的目录
        # exclude = test/
        # 设置允许连接服务器的账户，账户可以是系统中不存在的用户
        auth users = vagrant
        #客户端请求显示模块列表时，本模块名称是否显示，默认为true
        list = false
EOF"
# 指定启动配置文件

# 关闭 SELinux
# https://blog.51cto.com/bguncle/957315
sudo setenforce 0
sudo sed -ie "s/^SELINUX=.*/SELINUX=disabled/" /etc/selinux/config

sudo systemctl restart rsyncd

else :
  # 复制kafka01上的文件到本地
  sudo touch /opt/sync.pass
  sudo bash -c "echo '123456' > /opt/sync.pass"
  sudo chmod 600 /opt/sync.pass
  sudo rsync -av vagrant@192.165.34.91::vagranthome/kafka_2.13-3.0.1.tgz /home/vagrant --password-file=/opt/sync.pass || :

  sudo tar -zxvf kafka_2.13-3.0.1.tgz -C /usr/local/ && sudo mv /usr/local/kafka_2.13-3.0.1 /usr/local/kafka

  # https://github.com/apache/kafka/blob/trunk/config/kraft/README.md
  # 设置node.id
  id=$(echo "${HOSTNAME}" | sed -e 's/kafka0//g')
  sudo sed -ie "s/node.id=.*/node.id=${id}/" /usr/local/kafka/config/kraft/server.properties
  # 设置投票节点
  sudo sed -ie "s/controller.quorum.voters=.*/controller.quorum.voters=1@192.165.34.91:9093,2@192.165.34.92:9093,3@192.165.34.93:9093/" /usr/local/kafka/config/kraft/server.properties

  # https://www.orchome.com/10533
  sudo sed -ie "s/^listeners=.*/listeners=PLAINTEXT:\/\/${HOST_IP}:9092,CONTROLLER:\/\/${HOST_IP}:9093/" /usr/local/kafka/config/kraft/server.properties

  sudo sed -ie "s/advertised.listeners=.*/advertised.listeners=PLAINTEXT:\/\/${HOST_IP}:9092/" /usr/local/kafka/config/kraft/server.properties

  uuid=$(sudo /usr/local/kafka/bin/kafka-storage.sh random-uuid)
  sudo /usr/local/kafka/bin/kafka-storage.sh format -t ${uuid} -c /usr/local/kafka/config/kraft/server.properties

  # sudo /usr/local/kafka/bin/kafka-server-start.sh  /usr/local/kafka/config/kraft/server.properties
fi