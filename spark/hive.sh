#! /bin/bash

sudo useradd hadoop
echo 'hadoop' | sudo passwd hadoop --stdin
#sudo chown hadoop:hadoop -R /usr/local/hive

# 设置 hadoop 用户可以使用sudo
sudo sed -i '100a hadoop  ALL=(ALL) NOPASSWD:ALL' /etc/sudoers


# hive --auxpath /usr/local/hive/lib/hive-hbase-handler-3.1.3.jar,/usr/local/hive/lib/hbase-client-2.0.0-alpha4.jar,/usr/local/hive/lib/zookeeper-3.4.6.jar,/usr/local/hive/lib/guava-19.0.jar --hiveconf hbase.master=192.168.35.16:60000


# https://blog.csdn.net/qq_34834325/article/details/79037845 Hive部署和3种搭建模式
cat <<EOF | tee /usr/local/hive/conf/hive-site.xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:mysql://192.168.168.149:3310/hive?createDatabaseIfNotExist=true</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionDriverName</name>
    <value>com.mysql.cj.jdbc.Driver</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionUserName</name>
    <value>root</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionPassword</name>
    <value>Admin@123</value>
  </property>

  <property>
    <name>hive.metastore.warehouse.dir</name>
    <value>/usr/local/hive/warehouse</value>
  </property>
  <property>
    <name>hive.metastore.local</name>
    <value>false</value>
  </property>
  <property>
    <name>hive.metastore.uris</name>
    <value>thrift://localhost:9083</value>
  </property>
</configuration>
EOF


cat <<EOF | sudo tee -a /etc/bashrc
export HIVE_HOME=/usr/local/hive
export PATH=\$PATH:\$HIVE_HOME/bin
EOF

wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.25/mysql-connector-java-8.0.25.jar -O /usr/local/hive/lib/mysql-connector-java-8.0.25.jar

# hive 初始化mysql设置,创建数据库并且初始化表结构
# schematool -dbType mysql -initSchema

# 启动
# hive --service metastore
