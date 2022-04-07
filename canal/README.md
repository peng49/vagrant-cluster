**参考链接** <br/>
[Canal——增量同步MySQL数据到ElasticSearch](https://www.cnblogs.com/caoweixiong/p/11825303.html) <br/>


###### mysql设置
创建同步用户
```shell
mysql> create user 'canal'@'%' identified by 'Canal@ass01';
Query OK, 0 rows affected (0.01 sec)

mysql> grant replication slave on *.* to 'canal'@'%';
Query OK, 0 rows affected (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)

mysql> create database `sync-db`;
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
binlog-do-db=sync-db

datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
```

查看主服务器当前二进制日志名和偏移量
```shell
mysql> show master status;
+---------------+----------+--------------+------------------+-------------------+
| File          | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+---------------+----------+--------------+------------------+-------------------+
| binlog.000002 |      157 | sync-db      |                  |                   |
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