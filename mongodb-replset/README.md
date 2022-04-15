
```
use admin
cfg = { 
    "_id":"rs0",
    "members": [  
        {"_id":0,"host":"192.165.33.20:27017"}, 
        {"_id":1,"host":"192.165.33.21:27017"}, 
        {"_id":2,"host":"192.165.33.22:27017"} 
    ]
}

rs.initiate(cfg)
```
mongodb 部署方式 

https://www.cnblogs.com/nulige/p/7613721.html 

单节点

副本集

分片


副本集 + 分片




todo 权限管理


mongodbshark 同步数据
