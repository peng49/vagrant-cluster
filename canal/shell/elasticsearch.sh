#/bin/sh

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

sudo systemctl start elasticsearch &
sudo systemctl enalbe elasticsearch

# 安装 kibana
sudo yum install --enablerepo=kibana -y kibana
sudo sed -i 's/#server.host:.*$/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml
sudo systemctl start kibana &
sudo systemctl enable kibana