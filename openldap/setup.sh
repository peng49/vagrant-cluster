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

# 禁止匿名用户访问
sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: cn=config
changetype: modify
add: olcDisallows
olcDisallows: bind_anon
EOF

sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={-1}frontend,cn=config
changetype: modify
add: olcRequires
olcRequires: authc
EOF


# 查看加载的module
# sudo ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b  cn=config -LLL | grep -i module

# 查看数据库
# sudo ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b  cn=config olcDatabase | grep db

# 添加 memberOf 配置
sudo ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /vagrant/data/memberof.ldif
sudo ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /vagrant/data/refint.ldif


# 验证新增的用户是否存在memberOf属性
# sudo slapcat | grep member

# 添加测试数据
sudo ldapadd -x -D "cn=ldapadm,dc=fly-develop,dc=com" -w ldap@admin -f  /vagrant/data/base.ldif
sudo ldapadd -x -D "cn=ldapadm,dc=fly-develop,dc=com" -w ldap@admin -f  /vagrant/data/groups.ldif

# groupOfURLs 支持 https://github.com/osixia/docker-openldap/issues/355
sudo ldapadd -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: cn=dyngroup,cn=schema,cn=config
objectClass: olcSchemaConfig
cn: dyngroup
olcObjectIdentifier: {0}NetscapeRoot 2.16.840.1.113730
olcObjectIdentifier: {1}NetscapeLDAP NetscapeRoot:3
olcObjectIdentifier: {2}NetscapeLDAPattributeType NetscapeLDAP:1
olcObjectIdentifier: {3}NetscapeLDAPobjectClass NetscapeLDAP:2
olcObjectIdentifier: {4}OpenLDAPExp11 1.3.6.1.4.1.4203.666.11
olcObjectIdentifier: {5}DynGroupBase OpenLDAPExp11:8
olcObjectIdentifier: {6}DynGroupAttr DynGroupBase:1
olcObjectIdentifier: {7}DynGroupOC DynGroupBase:2
olcAttributeTypes: {0}( NetscapeLDAPattributeType:198 NAME 'memberURL' DESC 'I
 dentifies an URL associated with each member of a group. Any type of labeled
 URL can be used.' SUP labeledURI )
olcAttributeTypes: {1}( DynGroupAttr:1 NAME 'dgIdentity' DESC 'Identity to use
  when processing the memberURL' SUP distinguishedName SINGLE-VALUE )
olcAttributeTypes: {2}( DynGroupAttr:2 NAME 'dgAuthz' DESC 'Optional authoriza
 tion rules that determine who is allowed to assume the dgIdentity' EQUALITY a
 uthzMatch SYNTAX 1.3.6.1.4.1.4203.666.2.7 X-ORDERED 'VALUES' )
olcObjectClasses: {0}( NetscapeLDAPobjectClass:33 NAME 'groupOfURLs' SUP top S
 TRUCTURAL MUST cn MAY ( memberURL $ businessCategory $ description $ o $ ou $
  owner $ seeAlso ) )
olcObjectClasses: {1}( DynGroupOC:1 NAME 'dgIdentityAux' SUP top AUXILIARY MAY
  ( dgIdentity $ dgAuthz ) )
EOF

# 测试 groupOfURLs
sudo ldapadd -x -D "cn=ldapadm,dc=fly-develop,dc=com" -w ldap@admin <<EOF
dn: cn=group_of_urls_example,ou=groups,dc=fly-develop,dc=com
objectClass: groupOfURLs
cn: group_of_urls_example
description: Dynamic admins.
memberURL: ldap:///ou=users,dc=fly-develop,dc=com??sub?(objectClass=inetOrgPerson)
EOF
