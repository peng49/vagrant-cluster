### nginx负载均衡配置

创建配置文件

> vi /etc/nginx/conf.d/8080.conf

复制如下内容:

```shell
upstream hosts {
    server 192.165.43.101;
    server 192.165.43.102;
    server 192.165.43.103;
}

server {
    listen       8080;
    server_name  localhost;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        proxy_pass http://hosts;
        proxy_redirect default;
    }
}
```
重启服务
> sudo systemctl restart nginx


访问 http://192.165.43.101:8080/ 多次刷新页面可看到效果

### nginx负载方式
[Nginx实现负载均衡](https://www.jianshu.com/p/4c250c1cd6cd)
#### 轮询 【默认方式】
```shell
upstream hosts {   
    server 192.165.43.101;
    server 192.165.43.102;
    server 192.165.43.103;    
}
```
#### 权重
```shell
upstream hosts {   
    server 192.165.43.101 weight=3;
    server 192.165.43.102 weight=2;
    server 192.165.43.103 weight=1;    
}
```
#### ip hash
```shell
upstream hosts {   
    ip_hash;
    server 192.165.43.101;
    server 192.165.43.102;
    server 192.165.43.103;    
}
```
#### 最少连接
```shell
upstream hosts {   
    least_conn;
    server 192.165.43.101;
    server 192.165.43.102;
    server 192.165.43.103;    
}
```
#### fair 【需安装第三方模块】
按后端服务器的响应时间来分配请求，响应时间短的优先分配
```shell
upstream hosts {
    server 192.165.43.101;
    server 192.165.43.102;
    server 192.165.43.103;
    fair;
}
```
[官网](http://nginx.org/en/docs/http/ngx_http_upstream_module.html)



### nginx 配置ldap认证
https://lantian.pub/article/modify-website/nginx-ldap-authentication.lantian/

https://www.jianshu.com/p/3728c882d252

https://www.jianshu.com/p/70543ab5201f
