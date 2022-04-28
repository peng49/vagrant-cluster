### 索引生命周期管理 (ILM)管理日志数据

#### 创建一个ILM策略
```shell
PUT /_ilm/policy/hot-warm-cold-delete-7days
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
        "min_age": "5d",
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

```shell
POST /_index_template/logs-template
{
  "index_patterns": [
    "nginx-logs*"
  ],
  "data_stream": {},
  "template": {
    "settings": {
      "index.lifecycle.name": "hot-warm-cold-delete-7days",
      "index.number_of_shards": "3",
      "index.number_of_replicas": "1"
    },
    "mappings": {
      "dynamic": "false",
      "properties": {
        "@timestamp": {
          "type": "date",
          "format": "date_optional_time||epoch_millis"
        }
        "requestId": {
          "type": "keyword"
        },
        "url": {
          "type": "keyword"
        },
        "responseBody": {
          "type": "text"
        }
      }
    }
  },
  "composed_of": [],
  "_meta": {
    "description": "search logs template"
  }
}
```

