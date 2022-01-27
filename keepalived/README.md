[Keepalived](https://www.jianshu.com/p/a6b5ab36292a)

[使用LVS实现负载均衡原理及安装配置详解](https://www.cnblogs.com/zyd112/p/8809200.html)

[【Nginx】如何实现Nginx的高可用负载均衡？看完我也会了！！](https://www.cnblogs.com/binghe001/p/13378305.html)

[keepalived的一些。。](https://www.cnblogs.com/gqdw/p/3558706.html)

[虚拟机virtualBox 搭建 Keepalived+lvs dr+httpd 负载均衡](https://blog.csdn.net/u014695188/article/details/50986372)

[VirtualBox + CentOS + NGINX + Keepalived 初阶实战：负载均衡 + HA](https://github.com/lilins/Blog/issues/2)


[通过阿里云的弹性网卡实现keepalived高可用](https://github.com/paololiu/aliyun-eni)
[阿里云 ECS 实例是否支持安装 keepalived 配置虚拟 VIP，进行负载均衡？](https://developer.aliyun.com/ask/111822?spm=a2c6h.13159736)
[弹性公网 IP](https://help.aliyun.com/product/61789.html)
[弹性网卡概述](https://help.aliyun.com/document_detail/58496.html)


ipvsadm 三种工作模式解析?


####常用命令
查看版本
> keepalived -v

查看日志

[Linux Systemd 查看日志](https://pdf-lib.org/home/details/9426)

> sudo journalctl -u keepalived

动态显示日志
> sudo journalctl -u keepalived -f

> sudo ipvsadm -Ln --stats

> sudo ipvsadm -Ln --rate

查看当前节点是主节点还是备节点

[View Current State of Keepalived](https://serverfault.com/questions/560024/view-current-state-of-keepalived)
> sudo journalctl -u keepalived | grep Entering



#### 报错处理
[Unknown keyword 'nb_get_retry'](https://blog.csdn.net/qq_36801585/article/details/105137556)

