#! /bin/sh
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


# 设置时区并同步网络时间 https://www.cnblogs.com/ifme/p/12856236.html
sudo yum install -y ntp && \
  sudo systemctl enable ntpd && \
  sudo systemctl start ntpd && \
  sudo timedatectl set-timezone Asia/Shanghai && \
  sudo timedatectl set-ntp yes



if [ ${HOSTNAME} == 'zabbix' ];
then
  # 安装最新版本的docker,harbor 依赖docker构建

#  sudo yum remove -y docker \
#                    docker-client \
#                    docker-client-latest \
#                    docker-common \
#                    docker-latest \
#                    docker-latest-logrotate \
#                    docker-logrotate \
#                    docker-engine

  sudo yum install -y yum-utils
  sudo yum-config-manager \
      --add-repo \
      https://download.docker.com/linux/centos/docker-ce.repo

  sudo yum install -y docker-ce docker-ce-cli containerd.io


  sudo systemctl start docker
  sudo systemctl enable docker

  # 设置daemon.json文件
  sudo touch /etc/docker/daemon.json
  sudo bash -c 'cat <<EOF > /etc/docker/daemon.json
  {
          "registry-mirrors": [
                  "https://ustc-edu-cn.mirror.aliyuncs.com",
                  "https://xx4bwyg2.mirror.aliyuncs.com",
                  "http://hub-mirror.c.163.com"
          ]
  }
  EOF'
  sudo systemctl restart docker

  # create network
  sudo docker network create zabbix-net

  # mysql-server
  sudo docker run --name mysql-server \
    --network zabbix-net \
    -e MYSQL_ROOT_PASSWORD=Admin@123 \
    -e MYSQL_DATABASE="zabbix" \
    -p 3306:3306 \
    --restart always \
    -d mysql:8.0.27 \
    --character-set-server=utf8 --collation-server=utf8_bin

  # 启动 Zabbix Java 网关实例
  sudo docker run --name zabbix-java-gateway -t \
          --network=zabbix-net \
          --restart unless-stopped \
          -p 10052:10052 \
          -d zabbix/zabbix-java-gateway:6.0-ubuntu-latest

  # zabbix-server
  sudo docker run --name zabbix-server-mysql -t \
        -e DB_SERVER_HOST="mysql-server" \
        -e MYSQL_DATABASE="zabbix" \
        -e MYSQL_USER="root" \
        -e MYSQL_PASSWORD="Admin@123" \
        -e MYSQL_ROOT_PASSWORD="Admin@123" \
        -e ZBX_JAVAGATEWAY="zabbix-java-gateway" \
        --network=zabbix-net \
        -p 10051:10051 \
        --restart unless-stopped \
        -d zabbix/zabbix-server-mysql:6.0-ubuntu-latest

  # zabbix-web
  sudo docker run --name zabbix-web-nginx-mysql \
    --network zabbix-net \
    --restart unless-stopped \
    -e DB_SERVER_HOST="mysql-server" \
    -e MYSQL_USER="root" \
    -e MYSQL_PASSWORD="Admin@123" \
    -e MYSQL_DATABASE="zabbix" \
    -e ZBX_SERVER_HOST="zabbix-server-mysql" \
    -e PHP_TZ="Asia/Shanghai" \
    -p 8080:8080 \
    -p 8443:8443 \
    -d zabbix/zabbix-web-nginx-mysql:6.0-ubuntu-latest
fi


