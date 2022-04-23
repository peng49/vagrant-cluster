#! /bin/bash

mkdir downloads
chown vagrant:vagrant downloads

# install elasticsearch
# https://www.elastic.co/guide/en/elasticsearch/reference/7.17/rpm.html
curl -L https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.3-x86_64.rpm \
  -o downloads/elasticsearch-7.17.3-x86_64.rpm
curl -L https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.3-x86_64.rpm.sha512 \
  -o downloads/elasticsearch-7.17.3-x86_64.rpm.sha512

cd downloads && shasum -a 512 -c elasticsearch-7.17.3-x86_64.rpm.sha512 && sudo rpm --install elasticsearch-7.17.3-x86_64.rpm

# 设置rsyncd
sudo sed -i 's/\r//' /vagrant/rsync.sh
sudo bash /vagrant/rsync.sh

# 设置集群名称
sudo sed -ie 's/#cluster.name:.*/cluster.name: esc/' /etc/elasticsearch/elasticsearch.yml
# 设置节点名称
sudo sed -ie "s/#node.name:.*/node.name: $(hostname -f)/" /etc/elasticsearch/elasticsearch.yml

sudo sed -ie "/node.name:.*/ a\node.master: true\nnode.data: true" /etc/elasticsearch/elasticsearch.yml

# todo 设置数据保存路径

#设置网络
sudo sed -ie 's/#network.host:.*/network.host: 0.0.0.0/' /etc/elasticsearch/elasticsearch.yml

# 设置集群配置
sudo sed -ie 's/#discovery.seed_hosts:.*/discovery.seed_hosts: ["192.168.34.11:9300","192.168.34.12:9300","192.168.34.13:9300"]/' /etc/elasticsearch/elasticsearch.yml


# todo install kibana