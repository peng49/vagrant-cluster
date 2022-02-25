#/bin/sh
sudo curl -L -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#https://www.jianshu.com/p/2206cb265247
sudo sed -ri 's/cloud.aliyuncs/aliyun/g' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -ri 's/aliyuncs.com/aliyun.com/g' /etc/yum.repos.d/CentOS-Base.repo

sudo yum clean all && sudo yum makecache

# 安装openldap
sudo yum -y install openldap*

sudo systemctl start slapd
sudo systemctl enable slapd


# 初始化数据
sudo ldapmodify -Y EXTERNAL  -H ldapi:/// -f /vagrant/data/db.ldif

# 设置ldap数据库
sudo cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
sudo chown ldap:ldap /var/lib/ldap/*

# Add the cosine and nis LDAP schemas.
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

# 添加测试数据
sudo ldapadd -x -D "cn=ldapadm,dc=fly-develop,dc=com" -w ldap@admin -f  /vagrant/data/base.ldif


