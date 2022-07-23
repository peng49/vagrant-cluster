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

sudo yum install -y java-11-openjdk-devel vim wget

wget --no-check-certificate https://dlcdn.apache.org/hadoop/common/hadoop-3.3.3/hadoop-3.3.3.tar.gz -O hadoop-3.3.3.tar.gz &&
  tar -zxvf hadoop-3.3.3.tar.gz &&
  sudo mv hadoop-3.3.3 /usr/local/hadoop

#设置HADOOP_HOME JAVA_HOME
JAVA_HOME=$(realpath /usr/bin/java | sed 's/bin\/java//')
HADOOP_HOME=/usr/local/hadoop

cat <<EOF | sudo tee -a /etc/profile
export JAVA_HOME=${JAVA_HOME}
export HADOOP_HOME=${HADOOP_HOME}
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin
EOF

# 在 hadoop-env.sh 设置也设置 JAVA_HOME
sudo sed -i "37a export JAVA_HOME=${JAVA_HOME}" /usr/local/hadoop/etc/hadoop/hadoop-env.sh

IP=$(ip address | grep 192 | awk '{print $2}' | sed 's/\/24//')
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://${IP}:9000</value>
  </property>
  <property>
    <name>hadoop.http.staticuser.user</name>
    <value>hadoop</value>
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
ssh-copy-id -i ~/.ssh/id_rsa hadoop@"${IP}"
# 格式化文件结构
hdfs namenode -format
#启动 HDFS
start-dfs.sh