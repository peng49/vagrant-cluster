hadoop集群搭建
* https://cloud.tencent.com/developer/article/1910213

hadoop web页面:
* http://192.168.35.11:8088/
* http://192.168.35.11:9870/

初始化环境
```shell
vagrant up
```

|节点IP|主机名|类型|
|:---:|:---:|:---:|
|192.168.35.11|name01|NameNode,Hive|
|192.168.35.12|name02|NameNode|
|192.168.35.13|data01|DataNode|
|192.168.35.14|data02|DataNode|
|192.168.35.15|data03|DataNode|
|192.168.35.16|hbase |hbase|

vagrant启动5台虚拟机,并在每台机器上安装好java
> sudo yum install -y java-1.8.0-openjdk-devel vim wget sshpass

下载 hadoop-3.3.3
```shell
[vagrant@name01 ~]$ wget --no-check-certificate https://dlcdn.apache.org/hadoop/common/hadoop-3.3.3/hadoop-3.3.3.tar.gz -O hadoop-3.3.3.tar.gz && \
  tar -zxf hadoop-3.3.3.tar.gz && sudo mv hadoop-3.3.3 /usr/local/hadoop
```

在每台机器上都执行以下命令设置hosts,并设置 JAVA_HOME
```shell
# 设置hosts
$ cat <<EOF | tee -a /etc/hosts
192.168.35.11 name01
192.168.35.12 name02
192.168.35.13 data01
192.168.35.14 data02
192.168.35.15 data03
192.168.35.16 hbase
EOF

# 设置 JAVA_HOME
$ JAVA_HOME=$(realpath /usr/bin/java | sed 's/\/bin\/java//')

$ cat <<EOF | sudo tee -a /etc/bashrc
export JAVA_HOME=${JAVA_HOME}
EOF

# 新增一个用户 hadoop 并设置密码为 hadoop
$ sudo useradd hadoop
$ echo 'hadoop' | sudo passwd hadoop --stdin

# 设置 hadoop 用户可以使用sudo
$ sudo sed -i '100a hadoop  ALL=(ALL) NOPASSWD:ALL' /etc/sudoers
```

在name01节点下载 hadoop-3.3.3.tar.gz 并解压
```shell
[hadoop@name01 ~]$ tar -zxvf hadoop-3.3.3.tar.gz
[hadoop@name01 ~]$ sudo mv hadoop-3.3.3 /usr/local/hadoop
[hadoop@name01 ~]$ sudo chown hadoop:hadoop -R /usr/local/hadoop
[hadoop@name01 ~]$ cat <<EOF | sudo tee -a /etc/bashrc
export HADOOP_HOME=/usr/local/hadoop
export PATH=\$PATH:\$HADOOP_HOME/bin
EOF
[hadoop@name01 ~]$ source /etc/bashrc
```

hadoop配置
```shell
# 在 hadoop-env.sh 设置也设置 JAVA_HOME
[hadoop@name01 ~]$ sudo sed -i "37a export JAVA_HOME=${JAVA_HOME}" /usr/local/hadoop/etc/hadoop/hadoop-env.sh

[hadoop@name01 ~]$ cat <<EOF | sudo tee /usr/local/hadoop/etc/hadoop/core-site.xml
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
    <value>/usr/local/hadoop/data</value>
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

[hadoop@name01 ~]$ mkdir /usr/local/hadoop/data

# 设置副本数量
[hadoop@name01 ~]$ cat <<EOF | sudo tee /usr/local/hadoop/etc/hadoop/hdfs-site.xml
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
[hadoop@name01 ~]$ cat <<EOF | sudo tee /usr/local/hadoop/etc/hadoop/mapred-site.xml
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

[hadoop@name01 ~]$ cat <<EOF | sudo tee /usr/local/hadoop/etc/hadoop/yarn-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
</configuration>
EOF
```


指定数据节点
```shell
# 指定数据节点
cat <<EOF | sudo tee /usr/local/hadoop/etc/hadoop/workers
data01
data02
data03
EOF
```

在`name02`,`data01`,`data02`,`data03`节点上执行如下命令从`name01`复制`/usr/local/hadoop`文件夹到本地
```shell
$ sudo scp -P 22 -o "StrictHostKeyChecking no" -r hadoop@name01:/usr/local/hadoop/ /usr/local/hadoop
$ sudo chown hadoop:hadoop -R /usr/local/hadoop
$ cat <<EOF | sudo tee -a /etc/bashrc
export HADOOP_HOME=/usr/local/hadoop
export PATH=\$PATH:\${HADOOP_HOME}/bin:\${HADOOP_HOME}/sbin
EOF
$ source /etc/bashrc
```

name01节点
```shell
# namenode节点可以远程连接
[hadoop@name01 ~]$ sed -i 's/name01:9000/0.0.0.0:9000/' /usr/local/hadoop/etc/hadoop/core-site.xml
# 初始化namenode
[hadoop@name01 ~]$ hdfs namenode -format
# 启动namenode
[hadoop@name01 ~]$ hdfs --daemon start namenode
```

http://192.168.35.11:9870/ 查看namenode页面 

`data01`,`data02`,`data03`节点
```shell
# 初始化datanode
$ hdfs datanode -format

$ hdfs --daemon start datanode
```

hdfs 搭建完成

启动resourcemanager和nodemanagers 管理 mapreduce

```shell
# 启动yarn
[hadoop@name01 ~]$ start-yarn.sh
Starting resourcemanager
Starting nodemanagers

# 查看进程 
[hadoop@name01 ~]$ jps
28656 ResourceManager
27378 SecondaryNameNode
26804 NameNode
28968 Jps
```
http://192.168.35.11:8088/ 访问前端页面

wordcount测试
```shell
[hadoop@name01 ~]$ cat <<EOF | tee hello.txt
hello world
hi world
hi hi
hello world
EOF

[hadoop@name01 ~]$ hdfs dfs -put hello.txt /hello.txt

[hadoop@name01 ~]$ hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.3.jar wordcount /hello.txt /output

# 执行成功之后查看统计结果
[hadoop@name01 ~]$ hdfs dfs -cat /output/part-r-00000
hello   2
hi      3
world   3
```

hbase安装

官网下载hbase-2.5.0-bin.tar.gz,解压到 /usr/local/hbase

hbase设置
```shell
[hadoop@hbase ~]$  cat <<EOF | sudo tee /usr/local/hbase/conf/hbase-site.xml
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


# 设置环境变量
[hadoop@hbase ~]$ cat <<EOF | sudo tee -a /etc/bashrc
export HBASE_HOME=/usr/local/hbase
export PATH=\$PATH:\$HBASE_HOME/bin
EOF
[hadoop@hbase ~]$ source /etc/bashrc
# hbase 启动
[hadoop@hbase ~]$ start-hbase.sh
# shell 操作hbase
[hadoop@hbase ~]$ hbase shell
```



`name01` 安装hive
官网下载 apache-hive-3.1.3-bin.tar.gz

