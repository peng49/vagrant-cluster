#! /bin/bash
# install docker
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

# start docker
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

sudo docker run -it -d \
    --name mysql \
    -p 3306:3306 \
    -e MYSQL_ROOT_PASSWORD=root@123 \
    mysql:8.0.25

# my.cnf 配置
sudo docker exec -it mysql bash -c "echo 'server-id=1' >> /etc/mysql/my.cnf"
# 可省略，mysql8默认开启日志
sudo docker exec -it mysql bash -c "echo 'log-bin=/var/lib/mysql/binlog' >> /etc/mysql/my.cnf"
# 可省略，mysql8 默认就是ROW
sudo docker exec -it mysql bash -c "echo 'binlog-format=ROW' >> /etc/mysql/my.cnf"
sudo docker exec -it mysql bash -c "echo 'binlog-do-db=syncdb' >> /etc/mysql/my.cnf"

sudo docker exec -it mysql bash -c "mysql -uroot -proot@123 <<EOF
create user 'canal'@'%' identified with mysql_native_password by 'Canal@ass01';
grant replication slave,select on *.* to 'canal'@'%';
flush privileges;
create database syncdb;
EOF"

sudo systemctl restart docker

# 多行注释 方法一
: '

'

# 多行注释 方法二
:<<!
create user 'canal'@'%' identified with mysql_native_password by 'Canal@ass01';
grant replication slave,select on *.* to 'canal'@'%';
flush privileges;
!