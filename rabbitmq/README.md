[捋明白 RabbitMQ 中的权限系统，再也不用担忧消息发送失败了](https://blog.csdn.net/SharingOfficer/article/details/121754092)

[rabbitmq 生产环境配置](https://www.cnblogs.com/operationhome/p/10483840.html)

[官网:LDAP Support](https://www.rabbitmq.com/ldap.html)

advanced.config 示例
```shell
[{rabbitmq_auth_backend_ldap, [
  {vhost_access_query, {in_group, "cn=1,ou=groups,dc=fly-develop,dc=com"}},
  {resource_access_query,
    {for, [{resource, exchange, {for, [{permission, configure,
      {in_group, "cn=1,ou=groups,dc=fly-develop,dc=com"}
    },
      {permission, write, {constant, false}},
      {permission, read, {constant, true}}
    ]}},
      {resource, queue, {constant, true}}
    ]}},
  {tag_queries, [{administrator, {constant, true}}, {management, {constant, true}}]}
]}].
```


```shell
  {resource_access_query,
    # exchange 权限说明   是否在组 cn=1,ou=groups,dc=fly-develop,dc=com 中,在的话有可配置权限，没有写权限 有读权限
    {for, [{resource, exchange, {for, [{permission, configure,
      {in_group, "cn=1,ou=groups,dc=fly-develop,dc=com"}
    },
      {permission, write, {constant, false}},
      {permission, read, {constant, true}}
    ]}},
      # ldap用户有队列的读写权限
      {resource, queue, {constant, true}}
    ]}},
```


**用户权限**
1. 用户权限指的是用户对exchange，queue的操作权限，包括配置权限，读写权限。
2. 配置权限会影响到exchange，queue的声明和删除。
3. 读写权限影响到从queue里取消息，向exchange发送消息以及queue和exchange的绑定(bind)操作。

例如:
1. 将queue绑定到某exchange上，需要具有queue的可写权限，以及exchange的可读权限；
2. 向exchange发送消息需要具有exchange的可写权限；
3. 从queue里取数据需要具有queue的可读权限
