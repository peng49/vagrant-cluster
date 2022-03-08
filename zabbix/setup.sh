#/bin/sh
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



if [ ${HOSTNAME} == 'zabbix' ];
then
  # 安装最新版本的docker,harbor 依赖docker构建
  sudo yum remove docker \
                    docker-client \
                    docker-client-latest \
                    docker-common \
                    docker-latest \
                    docker-latest-logrotate \
                    docker-logrotate \
                    docker-engine

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

  sudo docker run -d --name zabbix-server -it zabbix/zabbix-web-nginx-mysql:latest
fi


