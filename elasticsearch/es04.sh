#! /bin/bash

sudo touch /opt/sync.pass
sudo bash -c "echo '123456' > /opt/sync.pass"
sudo chmod 600 /opt/sync.pass
sudo mkdir /home/vagrant/downloads
sudo rsync -av rsyn001@192.168.34.11::downloads /home/vagrant/downloads --password-file=/opt/sync.pass || :

cd downloads && shasum -a 512 -c elasticsearch-7.17.3-x86_64.rpm.sha512 && sudo rpm --install elasticsearch-7.17.3-x86_64.rpm

# 设置集群名称
sudo sed -ie 's/#cluster.name:.*/cluster.name: esc/' /etc/elasticsearch/elasticsearch.yml
# 设置节点名称
sudo sed -ie "s/#node.name:.*/node.name: $(hostname -f)/" /etc/elasticsearch/elasticsearch.yml

sudo sed -ie "/node.name:.*/ a\node.master: false\nnode.data: true" /etc/elasticsearch/elasticsearch.yml


#设置网络
sudo sed -ie 's/#network.host:.*/network.host: 0.0.0.0/' /etc/elasticsearch/elasticsearch.yml
# network.publish_host 是群集中的其他节点将与之通信的主机
sudo sed -ie "/network.host:.*/ a\network.publish_host: $(ip address |  grep 'global.*eth1' | awk '{print $2}' | sed -e 's/\/24//')" /etc/elasticsearch/elasticsearch.yml


# 设置集群配置
sudo sed -ie 's/#discovery.seed_hosts:.*/discovery.seed_hosts: ["192.168.34.11:9300","192.168.34.12:9300","192.168.34.13:9300"]/' /etc/elasticsearch/elasticsearch.yml
sudo sed -ie 's/#cluster.initial_master_nodes:.*/cluster.initial_master_nodes: ["es01", "es02", "es03"]/' /etc/elasticsearch/elasticsearch.yml
