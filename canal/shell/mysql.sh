#! /bin/sh

# https://stackoverflow.com/questions/70993613/unable-to-install-mysql-on-centos7
sudo yum remove -y mysql80-community-release.noarch
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