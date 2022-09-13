#! /bin/bash

cat <<EOF | tee ~/.ssh/config
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
EOF

wget --no-check-certificate https://dlcdn.apache.org/hadoop/common/hadoop-3.3.3/hadoop-3.3.3.tar.gz -O hadoop-3.3.3.tar.gz && \
  tar -zxf hadoop-3.3.3.tar.gz && sudo mv hadoop-3.3.3 /usr/local/hadoop

# 在 hadoop-env.sh 设置也设置 JAVA_HOME
sudo sed -i "37a export JAVA_HOME=${JAVA_HOME}" /usr/local/hadoop/etc/hadoop/hadoop-env.sh

#IP=$(ip address | grep 192 | awk '{print $2}' | sed 's/\/24//')
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>
  <!-- 指定HDFS中NameNode的地址 -->
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://name01:9000</value>
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
</configuration>" | sudo tee /usr/local/hadoop/etc/hadoop/core-site.xml

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
</configuration>" | sudo tee /usr/local/hadoop/etc/hadoop/hdfs-site.xml

# 指定数据节点
cat <<EOF | sudo tee /usr/local/hadoop/etc/hadoop/workers
data01
data02
data03
EOF

# 新增一个用户 hadoop 并设置密码为 hadoop
sudo useradd hadoop
echo 'hadoop' | sudo passwd hadoop --stdin

sudo chown hadoop:hadoop -R /usr/local/hadoop

# 设置 hadoop 用户可以使用sudo
sudo sed -i '100a hadoop  ALL=(ALL) NOPASSWD:ALL' /etc/sudoers


# 切换到hadoop
sudo su hadoop

# 配置SSH
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
sudo sshpass -p "hadoop" ssh-copy-id -i ~/.ssh/id_rsa.pub  -o "StrictHostKeyChecking no" hadoop@name01
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

