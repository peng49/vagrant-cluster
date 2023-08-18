## 数据库简单使用
获取当前数据库名称
```
> db.getName()
test
```
创建数据库
> use demo

存在则使用,没有这个库则创建

查看数据库状态
```shell
> db.stats()
{
        "db" : "demo",
        "collections" : 1,
        "views" : 0,
        "objects" : 1,
        "avgObjSize" : 81,
        "dataSize" : 81,
        "storageSize" : 24576,
        "indexes" : 1,
        "indexSize" : 24576,
        "totalSize" : 49152,
        "scaleFactor" : 1,
        "fsUsedSize" : 4172267520,
        "fsTotalSize" : 42927656960,
        "ok" : 1
}
```

db.help() 查看帮助信息
```shell
> db.help()
DB methods:
        db.adminCommand(nameOrDocument) - switches to 'admin' db, and runs command [just calls db.runCommand(...)]
        db.aggregate([pipeline], {options}) - performs a collectionless aggregation on this database; returns a cursor
        db.auth(username, password)
        db.cloneDatabase(fromhost) - will only function with MongoDB 4.0 and below
        db.commandHelp(name) returns the help for the command
        db.copyDatabase(fromdb, todb, fromhost) - will only function with MongoDB 4.0 and below
        db.createCollection(name, {size: ..., capped: ..., max: ...})
        db.createUser(userDocument)
        db.createView(name, viewOn, [{$operator: {...}}, ...], {viewOptions})
        db.currentOp() displays currently executing operations in the db
        db.dropDatabase(writeConcern)
        db.dropUser(username)
        db.eval() - deprecated
        db.fsyncLock() flush data to disk and lock server for backups
        db.fsyncUnlock() unlocks server following a db.fsyncLock()
        db.getCollection(cname) same as db['cname'] or db.cname
        db.getCollectionInfos([filter]) - returns a list that contains the names and options of the db's collections
        db.getCollectionNames()
        db.getLastError() - just returns the err msg string
        db.getLastErrorObj() - return full status object
        db.getLogComponents()
        db.getMongo() get the server connection object
        db.getMongo().setSecondaryOk() allow queries on a replication secondary server
        db.getName()
        db.getProfilingLevel() - deprecated
        db.getProfilingStatus() - returns if profiling is on and slow threshold
        db.getReplicationInfo()
        db.getSiblingDB(name) get the db at the same server as this one
        db.getWriteConcern() - returns the write concern used for any operations on this db, inherited from server object if set
        db.hostInfo() get details about the server's host
        db.isMaster() check replica primary status
        db.hello() check replica primary status
        db.killOp(opid) kills the current operation in the db
        db.listCommands() lists all the db commands
        db.loadServerScripts() loads all the scripts in db.system.js
        db.logout()
        db.printCollectionStats()
        db.printReplicationInfo()
        db.printShardingStatus()
        db.printSecondaryReplicationInfo()
        db.resetError()
        db.runCommand(cmdObj) run a database command.  if cmdObj is a string, turns it into {cmdObj: 1}
        db.serverStatus()
        db.setLogLevel(level,<component>)
        db.setProfilingLevel(level,slowms) 0=off 1=slow 2=all
        db.setVerboseShell(flag) display extra information in shell output
        db.setWriteConcern(<write concern doc>) - sets the write concern for writes to the db
        db.shutdownServer()
        db.stats()
        db.unsetWriteConcern(<write concern doc>) - unsets the write concern for writes to the db
        db.version() current version of the server
        db.watch() - opens a change stream cursor for a database to report on all  changes to its non-system collections.
```

#### 数据类型

#### 数据的增删改查

添加单条数据

添加多条数据

删除单条数据

删除多条数据

修改单条数据

修改多条数据

查询单条数据

查询多条数据

#### 创建索引



#### mongodb 账号权限

管理员账号
```shell
> use admin

> db.createUser({user:"admin",pwd:"Admin@123",roles:["root"]})
```

指定数据库只读账号


指定数据库可读可写账号


#### docker启动复制集
```shell
openssl rand -base64 756 > mongo.key

chmod 600 mongo.key
```

```shell
docker run -it -d --name mongo-relicat-set -p 27017:27017 -v `pwd`/mongo.key:/data/configdb/mongo.key --restart always -e MONGO_INITDB_ROOT_USERNAME=root -e MONGO_INITDB_ROOT_PASSWORD=Admin@123 mongo:4.4.6 mongod --replSet rs0  --keyFile /data/configdb/mongo.key
```





