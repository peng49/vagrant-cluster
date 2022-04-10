#! /bin/sh
# 设置时区
sudo timedatectl set-timezone Asia/Shanghai

sudo curl -L -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#https://www.jianshu.com/p/2206cb265247
sudo sed -ri 's/cloud.aliyuncs/aliyun/g' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -ri 's/aliyuncs.com/aliyun.com/g' /etc/yum.repos.d/CentOS-Base.repo

# ssh允许密码登录
sudo sed -ri 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# 允许root用户ssh登录
sudo sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd


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

# 启动mysql
sudo docker run -it -d \
    --name mysql \
    --restart always \
    -p 3306:3306 \
    -e MYSQL_ROOT_PASSWORD=root@123 \
    mysql:8.0.27

# 生成mysql测试环境数据
sudo docker exec -it mysql bash -c "mysql -uroot -proot@123 <<EOF
create database datax;
use datax;
create table users (
  id int auto_increment primary key,
  name varchar(64) not null default '',
  username varchar(32) not null default '',
  created_at datetime not null default CURRENT_TIMESTAMP,
  updated_at datetime not null default CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
insert into users (name,username) values ('name01',substring(MD5(RAND()),1,20));
create table datax_users (
  datax_id int auto_increment primary key,
  datax_name varchar(64) not null default '',
  datax_username varchar(32) not null default '',
  created_at datetime not null default CURRENT_TIMESTAMP,
  updated_at datetime not null default CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
EOF"


# 启动elasticsearch
sudo docker run -d --name elasticsearch \
  -p 9200:9200 \
  -p 9300:9300 \
  -e "discovery.type=single-node" \
  -e "xpack.security.enabled=false" \
  elasticsearch:8.1.2

# 启动 mongodb

# datax 环境准备
# https://github.com/alibaba/datax
sudo yum install -y java-1.8.0-openjdk
#sudo yum install -y python
sudo curl -L http://datax-opensource.oss-cn-hangzhou.aliyuncs.com/datax.tar.gz -o datax.tar.gz
sudo tar -xzvf datax.tar.gz -C /usr/local
#sudo ln -s /usr/local/datax/bin/datax.py /usr/local/bin/datax

# https://www.icode9.com/content-4-1280493.html
# 删除多余的文件
sudo find /usr/local/datax/plugin/  | grep -E "\._" | xargs sudo rm -rf
# mysql8 替换 mysqlreader 和 mysqlwriter 的mysql链接驱动
cd /usr/local/datax/plugin/reader/mysqlreader/libs/ && ls | grep mysql-connector | xargs sudo rm -f
sudo curl https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.27/mysql-connector-java-8.0.27.jar -o /usr/local/datax/plugin/reader/mysqlreader/libs/mysql-connector-java-8.0.27.jar
cd /usr/local/datax/plugin/writer/mysqlwriter/libs/ && ls | grep mysql-connector | xargs sudo rm -f
sudo cp /usr/local/datax/plugin/reader/mysqlreader/libs/mysql-connector-java-8.0.27.jar /usr/local/datax/plugin/writer/mysqlwriter/libs/mysql-connector-java-8.0.27.jar



# 编译生成 elasticsearchwriter 插件
sudo yum install -y maven unzip
curl -L https://github.com/alibaba/DataX/archive/refs/heads/master.zip -o /home/vagrant/DataX.zip
cd /home/vagrant && unzip DataX.zip
#sed -i 's/<module>.*<\/module>//g' pom.xml
#sed -i 's/<modules>/<modules>\n<module>elasticsearchwriter<\/module>/g' pom.xml


