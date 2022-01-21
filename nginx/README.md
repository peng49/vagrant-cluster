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