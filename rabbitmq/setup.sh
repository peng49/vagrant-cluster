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


# 可用插件设置,增加 rabbitmq_auth_backend_ldap 使用ldap认证
sudo mkdir /opt/rabbitmq/etc -p
sudo cp -rf /vagrant/etc/* /opt/rabbitmq/etc/

# 启动rabbitmq
sudo docker run -it -d \
    --name rabbitmq \
    --restart always \
    -p 5672:5672 \
    -p 15672:15672 \
    -e RABBITMQ_DEFAULT_USER=guest \
    -e RABBITMQ_DEFAULT_PASS=guest \
    -v /opt/rabbitmq/etc/rabbitmq:/etc/rabbitmq \
    rabbitmq:3.9-management

# 暂停10秒执行,确保rabbitmq服务已启动
sudo sleep 10

# 添加vhost
sudo docker exec rabbitmq rabbitmqctl add_vhost 'vhost'
# 添加新用户test,密码设置为test
sudo docker exec rabbitmq rabbitmqctl add_user 'test' 'test'
# 为test 设置vhost的可配置，可读，可写权限
sudo docker exec rabbitmq rabbitmqctl set_permissions --vhost 'vhost' 'test' '.*' '.*' '.*'