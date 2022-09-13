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
|192.168.35.11|name01|NameNode|
|192.168.35.12|name02|NameNode|
|192.168.35.13|data01|DataNode|
|192.168.35.14|data02|DataNode|
|192.168.35.15|data03|DataNode|

vagrant启动5台虚拟机,并在每台机器上安装好java
> sudo yum install -y java-11-openjdk-devel vim wget

下载 hadoop-3.3.3
```shell
[vagrant@name01 ~]$ wget --no-check-certificate https://dlcdn.apache.org/hadoop/common/hadoop-3.3.3/hadoop-3.3.3.tar.gz -O hadoop-3.3.3.tar.gz && \
  tar -zxf hadoop-3.3.3.tar.gz && sudo mv hadoop-3.3.3 /usr/local/hadoop
```

