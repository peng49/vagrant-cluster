#! /bin/bash

#cat <<EOF | tee ~/.ssh/config
#Host *
#  StrictHostKeyChecking no
#  UserKnownHostsFile=/dev/null
#EOF

wget --no-check-certificate https://dlcdn.apache.org/hadoop/common/hadoop-3.3.3/hadoop-3.3.3.tar.gz -O hadoop-3.3.3.tar.gz && \
  tar -zxf hadoop-3.3.3.tar.gz && sudo mv hadoop-3.3.3 /usr/local/hadoop

cat <<EOF | sudo tee -a /etc/bashrc
export HADOOP_HOME=/usr/local/hadoop
export PATH=\$PATH:\$HADOOP_HOME/bin
EOF

# 在 hadoop-env.sh 设置也设置 JAVA_HOME
sudo sed -i "37a export JAVA_HOME=${JAVA_HOME}" /usr/local/hadoop/etc/hadoop/hadoop-env.sh

#IP=$(ip address | grep 192 | awk '{print $2}' | sed 's/\/24//')
cat <<EOF | sudo tee /usr/local/hadoop/etc/hadoop/core-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <!-- 指定HDFS中NameNode的地址 -->
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://name01:9000</value>
  </property>
  <property>
    <name>hadoop.tmp.dir</name>
    <value>/usr/local/hadoop/tmp</value>
  </property>
  <property>
    <name>hadoop.http.staticuser.user</name>
    <value>hadoop</value>
  </property>
  <!-- 指定Hadoop辅助名称节点主机配置 -->
  <property>
        <name>dfs.namenode.secondary.http-address</name>
        <value>name02:50090</value>
  </property>
</configuration>
EOF

cat <<EOF | sudo tee /usr/local/hadoop/etc/hadoop/hdfs-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
</configuration>
EOF

# yarn 设置
cat <<EOF | sudo tee /usr/local/hadoop/etc/hadoop/mapred-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>
  <property>
    <name>yarn.app.mapreduce.am.env</name>
    <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>
  </property>
  <property>
    <name>mapreduce.map.env</name>
    <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>
  </property>
  <property>
    <name>mapreduce.reduce.env</name>
    <value>HADOOP_MAPRED_HOME=${HADOOP_HOME}</value>
  </property>
</configuration>
EOF

cat <<EOF | sudo tee /usr/local/hadoop/etc/hadoop/yarn-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
</configuration>
EOF


# 指定数据节点
cat <<EOF | sudo tee /usr/local/hadoop/etc/hadoop/workers
data01
data02
data03
EOF

sudo chown hadoop:hadoop -R /usr/local/hadoop


# 切换到hadoop
sudo su hadoop

# 配置SSH
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
sudo sshpass -p "hadoop" ssh-copy-id -i ~/.ssh/id_rsa.pub  -o "StrictHostKeyChecking no" hadoop@name01
# sudo sshpass -p "hadoop" ssh-copy-id -i ~/.ssh/id_rsa.pub  -o "StrictHostKeyChecking no" hadoop@name02
# sudo sshpass -p "hadoop" ssh-copy-id -i ~/.ssh/id_rsa.pub  -o "StrictHostKeyChecking no" hadoop@data01
# sudo sshpass -p "hadoop" ssh-copy-id -i ~/.ssh/id_rsa.pub  -o "StrictHostKeyChecking no" hadoop@data01
# sudo sshpass -p "hadoop" ssh-copy-id -i ~/.ssh/id_rsa.pub  -o "StrictHostKeyChecking no" hadoop@data01
## 格式化文件结构
# hdfs namenode -format
##启动 HDFS
#start-dfs.sh
#
#
## 关闭安全模式 https://www.cnblogs.com/laoqing/p/15112134.html
#hdfs dfsadmin -safemode leave



# yarn --daemon start resourcemanager
# yarn --daemon start nodemanager

# wordcount 测试
# hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.3.jar wordcount /words.txt /words-output01
