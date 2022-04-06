#/bin/sh
sudo curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#https://www.jianshu.com/p/2206cb265247
sudo sed -ri 's/cloud.aliyuncs/aliyun/g' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -ri 's/aliyuncs.com/aliyun.com/g' /etc/yum.repos.d/CentOS-Base.repo

# ssh允许密码登录
sudo sed -ri 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# 允许root用户ssh登录
sudo sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd


# https://stackoverflow.com/questions/70993613/unable-to-install-mysql-on-centos7
sudo yum remove mysql80-community-release.noarch
sudo yum clean all --verbose

sudo rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-5.noarch.rpm

sudo sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/mysql-community.repo

sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022

sudo yum --enablerepo=mysql80-community install -y mysql-community-server

sudo systemctl start mysqld.service
sudo systemctl enable mysqld.service

sudo grep "password" /var/log/mysqld.log

# 重置密码为 Acm@123$
password=$(sudo grep "password" /var/log/mysqld.log | sed -e 's/^.*: //g')
echo "alter user 'root'@'localhost' identified with mysql_native_password by 'Acm@123$';" > reset.sql
# 添加 || : 表示执行失败也继续执行
mysql -uroot -p${password} --connect-expired-password mysql < reset.sql || :
