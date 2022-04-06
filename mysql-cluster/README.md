#### mysql主从配置

|mysql|ip|
|:---:|:---:|
|主服务器|192.165.33.15|
|从服务器1|192.165.33.16|
|从服务器2|192.165.33.17|


##### 配置主库

###### 授权给从数据库服务器
```shell
mysql> create user 'salve01'@'192.165.33.%' identified by 'Salve@pass01';
Query OK, 0 rows affected (0.01 sec)

mysql> grant replication slave on *.* to 'salve01'@'192.165.33.%';
Query OK, 0 rows affected (0.01 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)
```

###### 修改主库配置文件，开启binlog，并设置server-id
每次修改配置文件后都要重启mysql服务才会生效
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

server-id: master端的ID号

log-bin: 同步的日志路径及文件名，一定注意这个目录要是mysql有权限写入的（我这里是偷懒了，直接放在了下面那个datadir下面）；

binlog-do-db:要同步的数据库名

还可以显示 设置不同步的数据库: <br/>
binlog-ignore-db = mysql 不同步mysql库和test库 <br/>
binlog-ignore-db = test

修改配置文件后，重启服务：`sudo systemctl restart mysqld`

如果启动失败，通过cat /var/log/mysqld.log | tail -30  查看mysql启动失败的日志，从日志内容寻找解决方案

###### 查看主服务器当前二进制日志名和偏移量
这个操作的目的是为了在从数据库启动后，从这个点开始进行数据的恢复
```shell
mysql> show master status;
+---------------+----------+--------------+------------------+-------------------+
| File          | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+---------------+----------+--------------+------------------+-------------------+
| binlog.000003 |      353 | sync-db      |                  |                   |
+---------------+----------+--------------+------------------+-------------------+
```

##### 配置从库
设置`server-id`

```shell
vim /etc/my.conf
```
server-id的值要在集群中是唯一的
```shell
[mysqld]
server-id=2
```

执行如下mysql
```mysql
change master to master_host = '192.165.33.15',
    master_port = 3306,
    master_user = 'salve01',
    get_master_public_key = 1,
    master_password  = 'Salve@pass01',
    master_log_file  = 'binlog.000003',
    master_log_pos = 353;
```
启动slave进程
```shell
mysql> start slave;
Query OK, 0 rows affected, 1 warning (0.02 sec)
```

查看slave的状态，如果下面两项值为YES，则表示配置正确：<br/>
Slave_IO_Running: Yes

Slave_SQL_Running: Yes
```shell
mysql> show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for source to send event
                  Master_Host: 192.165.33.15
                  Master_User: salve01
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: binlog.000003
          Read_Master_Log_Pos: 2955
               Relay_Log_File: mysql02-relay-bin.000003
                Relay_Log_Pos: 2925
        Relay_Master_Log_File: binlog.000003
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 2955
              Relay_Log_Space: 3317
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File:
           Master_SSL_CA_Path:
              Master_SSL_Cert:
            Master_SSL_Cipher:
               Master_SSL_Key:
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Master_Server_Id: 1
                  Master_UUID: e0840617-b558-11ec-a0ee-5254004d77d3
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Replica has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set:
            Executed_Gtid_Set:
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:
       Master_public_key_path:
        Get_master_public_key: 1
            Network_Namespace:
1 row in set, 1 warning (0.00 sec)
```

##### 同步主库已有数据到从库

###### 主库
停止主库的数据更新操作
> flush tables with read lock;


##### 异常处理

**参考链接**<br/>
[mysql主从同步配置](https://www.cnblogs.com/zhoujie/p/mysql1.html)