[Zookeeper到底是干嘛的](https://www.cnblogs.com/ultranms/p/9585191.html) <br/>

zoo.cfg
```
tickTime=2000 通信心跳时间，毫秒

initLimit=10 leader follower 初始通信时限

syncLimit=5 leader follower 同步通信时间
    leader和follower之间通信时间如果超过 syncLimit * tickTime,leader认为follower已死，从服务器列表中删除follower

dateDir=/opt/data/zookeeper  保存zookeeper中的数据

clientPort=2181 客户端连接端口
```

zookeeper选举机制
第一次启动
非第一次启动


节点信息
```shell
# 临时节点
create -e /node01 'node01 con' 
# 永久节点
create /node02 'node02 con'
#带序号
create -s /node03 'node03 con'

#不带序号
create /node03 'node03 con'
```

监听器原理

命令行注册监听器
```shell
# 注册一次监听，只能监听到一次变化
get -w /node01
```

```shell
# 删除节点命令 
delete

# 删除指定节点和指定节点的所有子节点
deleteall 
```


写数据原理

连接leader写数据


谅解follower写数据

zookeeper分布式锁原理

1. 接受到请求后，在 /locks 下创建一个临时顺序节点【加锁】
2. 客户端判断自己是不是 /locks 下最小的序号节点
3. 如果是，执行任务，删除节点【释放锁】，如果不是对前一个节点进行监听


