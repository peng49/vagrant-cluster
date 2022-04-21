#! /bin/bash

# 安装 logstash
# https://www.elastic.co/guide/en/logstash/current/installing-logstash.html
sudo yum install -y logstash

# 安装nginx
sudo bash -c 'cat <<EOF > /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF'

sudo yum install -y nginx

sudo sed -i 's/# path.config:.*$/path.config: "\/etc\/logstash\/conf.d\/*.conf"/' /etc/logstash/logstash.yml

# 读取nginx日志的logstash配置
cat <<EOF | sudo tee /etc/logstash/conf.d/nginx.conf
input {
   # 从文件读取日志信息
   file {
        path => "/var/log/nginx/access.log"
        type => "nginx-access"
        start_position => "beginning"
    }
}

filter {
    json {
       source => "message"
       remove_field => ["beat","offset","tags","prospector"] #移除字段，不需要采集
    }

    date {
      match => ["timestamp", "dd/MMM/yyyy:HH:mm:ss Z"] #匹配timestamp字段
      target => "@timestamp"  #将匹配到的数据写到@timestamp字段中
    }
}

output {
    elasticsearch {
      hosts => ["192.165.33.11:9200"]
      index => "nginx-access-%{+YYYY.MM.dd}"
    }
}
EOF

# 覆盖默认的nginx.conf配置文件,格式化日志内容
# https://www.cnblogs.com/tyhj-zxp/p/13191379.html
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old
cat <<EOF | sudo tee /etc/nginx/nginx.conf
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    log_format access_json '{"@timestamp":"\$time_iso8601",'
        '"host":"\$server_addr",'
        '"clientip":"\$remote_addr",'
        '"size":\$body_bytes_sent,'
        '"responsetime":\$request_time,'
        '"upstreamtime":"\$upstream_response_time",'
        '"upstreamhost":"\$upstream_addr",'
        '"http_host":"\$host",'
        '"url":"\$uri",'
        '"domain":"\$host",'
        '"xff":"\$http_x_forwarded_for",'
        '"referer":"\$http_referer",'
        '"status":"\$status"}';

    access_log  /var/log/nginx/access.log  access_json;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
EOF

# 添加文件的可读权限
sudo chmod +r /var/log/nginx/access.log