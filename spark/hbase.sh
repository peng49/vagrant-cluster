#! /bin/bash

sudo useradd hadoop
echo 'hadoop' | sudo passwd hadoop --stdin
#sudo chown hadoop:hadoop -R /usr/local/hbase

# 设置 hadoop 用户可以使用sudo
sudo sed -i '100a hadoop  ALL=(ALL) NOPASSWD:ALL' /etc/sudoers

cat <<EOF | sudo tee /usr/local/hbase/conf/hbase-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>hbase.rootdir</name>
    <value>hdfs://name01:9000/hbase</value>
  </property>
  <property>
    <name>hbase.cluster.distributed</name>
    <value>true</value>
  </property>
  <property>
    <name>hbase.master.ipc.address</name>
    <value>0.0.0.0</value>
  </property>
  <property>
    <name>hbase.regionserver.ipc.address</name>
    <value>0.0.0.0</value>
  </property>
  <property>
    <name>hbase.master.info.port</name>
    <value>60010</value>
  </property>
  <property>
    <name>hbase.wal.provider</name>
    <value>filesystem</value>
  </property>
  <property>
    <name>hbase.unsafe.stream.capability.enforce</name>
    <value>false</value>
  </property>
</configuration>
EOF


cat <<EOF | sudo tee -a /etc/bashrc
export HBASE_HOME=/usr/local/hbase
export PATH=\$PATH:\$HBASE_HOME/bin
EOF

sudo su hadoop
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
sudo sshpass -p "hadoop" ssh-copy-id -i ~/.ssh/id_rsa.pub  -o "StrictHostKeyChecking no" hadoop@hbase

# hbase 启动
# start-hbase.sh

# shell 操作hbase
# hbase shell
