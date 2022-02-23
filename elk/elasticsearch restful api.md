查看集群是否健康
> curl localhost:9200/_cat/health?v

查看集群节点列表
> curl localhost:9200/_cat/nodes?v

查看集群所有索引
> curl localhost:9200/_cat/indices?v

创建索引
```shell
PUT /my-index-000001
{
  "settings": {
    "index": {
      "number_of_shards": 3,  
      "number_of_replicas": 2 
    }
  }
}
```

删除索引
```shell
DELETE /my-index-000001
```

### 添加文档
https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html
```shell
POST my-index-000001/_doc/
{
  "@timestamp": "2099-11-15T13:12:00",
  "message": "GET /search HTTP/1.1 200 1070000",
  "user": {
    "id": "kimchy"
  }
}
```

### 修改文档
https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-update.html


### 删除文档

### 查询

