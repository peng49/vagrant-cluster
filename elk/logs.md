https://blog.csdn.net/zmx729618/article/details/80885179


#### 创建一个ILM策略
日志总共保存14天，前3天保存在hot节点,3天后移动到warm节点保存4天,移动到cold节点,再7天后删除日志
```shell
PUT /_ilm/policy/access-logs-14days
{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "set_priority": {
            "priority": 100
          },
          "rollover": {
            "max_docs": 10000,
            "max_size": "5gb",
            "max_age":"1d"
          }
        }
      },
      "warm": {
        "min_age": "3d",
        "actions": {
          "set_priority": {
            "priority": 50
          },
          "allocate": {
            "number_of_replicas": 1
          },
          "shrink": {
            "number_of_shards": 1
          },
          "forcemerge": {
            "max_num_segments": 1
          }
        }
      },
      "cold": {
        "min_age": "4d",
        "actions": {
          "set_priority": {
            "priority": 0
          },
         "freeze": {}
        }
      },
      "delete": {
        "min_age": "7d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
```

#### 创建模板,指定模板使用的ILM策略
```shell
POST /_index_template/logs-template
{
  "index_patterns": [
    "nginx-access*"
  ],
  "data_stream": {},
  "template": {
    "settings": {
      "index.lifecycle.name": "access-logs-14days",
      "index.number_of_shards": "1",
      "index.number_of_replicas": "1"
    },
    "mappings": {
      "dynamic": "false",
      "properties": {
        "@timestamp": {
          "type": "date",
          "format": "date_optional_time || epoch_millis"
        },
        "@version": {
          "type": "integer"
        },
        "host": {
          "type": "keyword"
        },
        "type": {
          "type": "keyword"
        },
        "data": {
          "properties":{            
            "http_host": {
              "type": "keyword"
            },
            "http_uri": {
              "type": "keyword"
            },
            "http_status":{
              "type": "integer"
            },
            "request": {
              "type": "keyword"
            },
            "request_header": {
              "type": "text"
            },
            "request_method": {
              "type": "keyword"
            },
            "request_query": {
              "type": "text"
            },
            "request_body": {
              "type": "text"
            },
            "request_post": {
              "type": "text"
            },
            "response_header": {
              "type": "text"
            },       
            "response_body": {
              "type": "text"
            }
          }
        }
      }
    }
  },
  "composed_of": [],
  "_meta": {
    "description": "nginx access logs template"
  }
}
```

#### 直接添加一个文档测试ILM和模板是否生效
```shell

```

#### nginx生成格式化日志
```shell

```


#### logstash读取日志写入elasticsearch
```shell

```