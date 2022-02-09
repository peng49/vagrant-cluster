#/bin/sh
sudo curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#https://www.jianshu.com/p/2206cb265247
sudo sed -ri 's/cloud.aliyuncs/aliyun/g' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -ri 's/aliyuncs.com/aliyun.com/g' /etc/yum.repos.d/CentOS-Base.repo

sudo yum clean all && sudo yum makecache

# 安装 elasticsearch
# https://www.elastic.co/guide/en/elasticsearch/reference/current/rpm.html
# import gpg key
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
sudo bash -c 'cat <<EOF > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF'
sudo yum install --enablerepo=elasticsearch -y elasticsearch

# 修改elastcisearch默认配置
# 备份默认配置文件
sudo cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.default

#设置 network.host 让 elasticsearch 可以远程访问
sudo sed -i 's/#network.host:.*$/network.host: 0.0.0.0/' /etc/elasticsearch/elasticsearch.yml

#添加 discovery.type: single-node 标记 elasticsearch 为单节点环境
sudo sed -i '/^#cluster.initial_master_nodes.*/ a\discovery.type: single-node' /etc/elasticsearch/elasticsearch.yml

# 安装 kibana
# https://www.elastic.co/guide/en/kibana/current/install.html
# sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
sudo bash -c 'cat <<EOF > /etc/yum.repos.d/kibana.repo
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF'
sudo yum install -y kibana

sudo sed -i 's/#server.host:.*$/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml

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
sudo sudo cp /vagrant/logstash-conf/* /etc/logstash/conf.d/

# 覆盖默认的nginx.conf配置文件,格式化日志内容
# https://www.cnblogs.com/tyhj-zxp/p/13191379.html
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old
sudo cp -f /vagrant/nginx-log-json-format.conf /etc/nginx/nginx.conf

# 添加文件的可读权限
sudo chmod +r /var/log/nginx/access.log

sudo systemctl start elasticsearch &
sudo systemctl start kibana &
sudo systemctl start logstash &
sudo systemctl start nginx &



sudo systemctl enable elasticsearch
sudo systemctl enable kibana
sudo systemctl enable logstash
sudo systemctl enable nginx

sudo systemctl stop firewalld
sudo systemctl disable firewalld




