#! /bin/bash
# 设置时区
sudo timedatectl set-timezone Asia/Shanghai

sudo curl -L -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#https://www.jianshu.com/p/2206cb265247
sudo sed -ri 's/cloud.aliyuncs/aliyun/g' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -ri 's/aliyuncs.com/aliyun.com/g' /etc/yum.repos.d/CentOS-Base.repo

sudo yum clean all && sudo yum makecache

# ssh允许密码登录
sudo sed -ri 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# 允许root用户ssh登录
sudo sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
cat <<EOF | sudo tee /etc/yum.repos.d/elastic.repo
[elastic]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF

# install elasticsearch
sudo yum install --enablerepo=elastic -y elasticsearch
# 修改elastcisearch默认配置
# 备份默认配置文件
sudo cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.default
#设置 network.host 让 elasticsearch 可以远程访问
sudo sed -i 's/#network.host:.*$/network.host: 0.0.0.0/' /etc/elasticsearch/elasticsearch.yml
#添加 discovery.type: single-node 标记 elasticsearch 为单节点环境
sudo sed -i '/^#cluster.initial_master_nodes.*/ a\discovery.type: single-node' /etc/elasticsearch/elasticsearch.yml

# install kibana
sudo yum install --enablerepo=elastic -y kibana
sudo sed -i 's/#server.host:.*$/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml

# install openresty
sudo curl -L https://openresty.org/package/centos/openresty.repo -o /etc/yum.repos.d/openresty.repo
sudo yum check-update
sudo yum install -y openresty
# 设置PATH
cat <<EOF | sudo tee -a /etc/profile
PATH=/usr/local/openresty/nginx/sbin:\$PATH
EOF

# 设置nginx.conf
sudo cp /vagrant/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

# 启动openresty生成日志文件
sudo systemctl start openresty
# 日志文件可读权限
sudo chmod +r /usr/local/openresty/nginx/logs/access.log

# install logstash
sudo yum install --enablerepo=elastic -y logstash
sudo sed -i 's/# path.config:.*$/path.config: "\/etc\/logstash\/conf.d\/*.conf"/' /etc/logstash/logstash.yml
# logstash配置,读取nginx日志同步到elasticsearch
#sudo cp /vagrant/logstash.nginx.conf /etc/logstash/conf.d/
sudo cp /vagrant/logstash.beats.conf /etc/logstash/conf.d/

# install filebeat
sudo yum install --enablerepo=elastic -y filebeat
sudo cp /vagrant/filebeat.logstash.yml /etc/filebeat/filebeat.yml


sudo systemctl start elasticsearch
sudo systemctl start kibana
sudo systemctl start logstash
sudo systemctl start filebeat

sudo systemctl enable elasticsearch
sudo systemctl enable kibana
sudo systemctl enable logstash
sudo systemctl enable openresty
sudo systemctl enable filebeat

sudo systemctl stop firewalld
sudo systemctl disable firewalld




