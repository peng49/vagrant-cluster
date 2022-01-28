# elasticsearch 安装
导入gpg key
> sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

添加 /etc/yum.repos.d/elasticsearch.repo 文件
```shell
sudo bash -c 'cat <<EOF > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF'
```
yum安装elasticsearch
> sudo yum install --enablerepo=elasticsearch -y elasticsearch

systemd 启动 elasticsearch
> sudo systemctl start elasticsearch

虚拟机请求 localhost:9200 
```shell
[vagrant@elk ~]$ curl localhost:9200
{
  "name" : "elk",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "DvqJaxRyR7auHoI2qK2enQ",
  "version" : {
    "number" : "7.16.3",
    "build_flavor" : "default",
    "build_type" : "rpm",
    "build_hash" : "4e6e4eab2297e949ec994e688dad46290d018022",
    "build_date" : "2022-01-06T23:43:02.825887787Z",
    "build_snapshot" : false,
    "lucene_version" : "8.10.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```
可以成功访问

修改配置

[Configuring Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/settings.html)

设置 network.host 让 elasticsearch 可以远程访问
> sudo sed -i 's/#network.host:.*$/network.host: 0.0.0.0/' /etc/elasticsearch/elasticsearch.yml

添加 discovery.type: single-node 标记 elasticsearch 为单节点环境
> sudo sed -i '/^#cluster.initial_master_nodes.*/ a\discovery.type: single-node' /etc/elasticsearch/elasticsearch.yml

重启
> sudo systemctl restart elasticsearch

启动成功之后可在浏览器中用 http://192.165.33.11:9200/ 访问 

# kibana 安装
添加 /etc/yum.repos.d/kibana.repo 文件
## 生成repo文件
```shell
sudo bash -c 'cat <<EOF > /etc/yum.repos.d/kibana.repo
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF'
```

## yum 安装 kibana
> sudo yum install -y kibana

## 修改kibana默认配置
备份默认配置文件
> sudo cp /etc/kibana/kibana.yml /etc/kibana/kibana.yml.default

设置 server.host 让 kibana 可以远程访问
> sudo sed -i 's/#server.host:.*$/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml

重启
> sudo systemctl restart kibana

启动成功之后可在浏览器中用 http://192.165.33.11:5601/ 访问

# logstash 安装

[Installing Logstash](https://www.elastic.co/guide/en/logstash/current/installing-logstash.html)
## yum 安装
> sudo yum install -y logstash


[linux安装logstash7.6.1及搭建简单ELK--logstash收集nginx日志](https://www.cnblogs.com/tyhj-zxp/p/13191379.html)

