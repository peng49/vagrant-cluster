**参考链接** <br/>
[Canal——增量同步MySQL数据到ElasticSearch](https://www.cnblogs.com/caoweixiong/p/11825303.html) <br/>

|系统|版本|
|:---:|:---:|
|canal|1.1.5|
|mysql|8.0.27|

###### mysql设置
创建同步用户
```shell
mysql> create user 'canal'@'%' identified by 'Canal@ass01';
Query OK, 0 rows affected (0.01 sec)

# https://my.oschina.net/u/1394615/blog/5130062
# canal需要select权限
mysql> grant replication slave,select  on *.* to 'canal'@'%';
Query OK, 0 rows affected (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)

mysql> create database `syncdb`;
Query OK, 1 row affected (0.00 sec)
```
```shell
alter user 'canal'@'%' identified with mysql_native_password by 'Canal@ass01';
```

修改配置文件
```shell
vim /etc/my.cnf
```
在该配置文件[mysqld]下面添加下面内容
```shell
[mysqld]
log-bin=/var/lib/mysql/binlog
server-id=1
binlog-do-db=syncdb

datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
```

查看主服务器当前二进制日志名和偏移量
```shell
mysql> show master status;
+---------------+----------+--------------+------------------+-------------------+
| File          | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+---------------+----------+--------------+------------------+-------------------+
| binlog.000002 |      157 | syncdb      |                  |                   |
+---------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)
```

log_bin 是否为 ON
```shell
mysql> show variables like '%log_bin%';
+---------------------------------+-----------------------------+
| Variable_name                   | Value                       |
+---------------------------------+-----------------------------+
| log_bin                         | ON                          |
| log_bin_basename                | /var/lib/mysql/binlog       |
| log_bin_index                   | /var/lib/mysql/binlog.index |
| log_bin_trust_function_creators | OFF                         |
| log_bin_use_v1_row_events       | OFF                         |
| sql_log_bin                     | ON                          |
+---------------------------------+-----------------------------+
6 rows in set (0.00 sec)
```

查看binlog模式
```shell
mysql> show variables like '%binlog_format%';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| binlog_format | ROW   |
+---------------+-------+
1 row in set (0.00 sec)
```


###### canal设置
安装java
```shell
sudo yum install -y java-1.8.0-openjdk
```

下载canal并解压
```shell
sudo curl -L https://github.com/alibaba/canal/releases/download/canal-1.1.5/canal.deployer-1.1.5.tar.gz -o canal.deployer-1.1.5.tar.gz
sudo mkdir /usr/local/canal-server -p
sudo tar -xzvf canal.deployer-1.1.5.tar.gz -C /usr/local/canal-server
```
打开默认实例
```shell
sudo vim /usr/local/canal-server/conf/example/instance.properties
```
修改如下设置
```shell
canal.instance.master.address=192.168.150.120:3306

# 在数据库执行 show master status; 查出的值
canal.instance.master.journal.name=binlog.000003
canal.instance.master.position=156

canal.instance.dbUsername=canal
canal.instance.dbPassword=Canal@ass01

# table regex
canal.instance.filter.regex=.*\\..*
# table black regex
canal.instance.filter.black.regex=mysql\\.slave_.*
```

启动关闭
```shell
# 启动
sudo sh /usr/local/canal-server/bin/startup.sh

# 重启
sudo sh /usr/local/canal-server/bin/restart.sh

# 关闭
sudo sh /usr/local/canal-server/bin/stop.sh
```