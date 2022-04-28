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
sudo sed -ie "s/#network.host:.*/network.host: $(ip address |  grep 'global.*eth1' | awk '{print $2}' | sed -e 's/\/24//')/" /etc/elasticsearch/elasticsearch.yml

# 设置集群配置
sudo sed -ie 's/#discovery.seed_hosts:.*/discovery.seed_hosts: ["192.168.34.11:9300","192.168.34.12:9300","192.168.34.13:9300"]/' /etc/elasticsearch/elasticsearch.yml
sudo sed -ie 's/#cluster.initial_master_nodes:.*/cluster.initial_master_nodes: ["es01", "es02", "es03"]/' /etc/elasticsearch/elasticsearch.yml


# 生成CA证书
echo -e "\n" | sudo /usr/share/elasticsearch/bin/elasticsearch-certutil ca --pass ""

sudo mv /usr/share/elasticsearch/elastic-stack-ca.p12 /etc/elasticsearch/config/
sudo cp /etc/elasticsearch/config/elastic-stack-ca.p12 /home/vagrant/downloads/
# 根据证书生成认证文件
echo -e "\n" | sudo /usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca /etc/elasticsearch/config/elastic-stack-ca.p12 --out /home/vagrant/downloads/elastic-certificates.p12 --pass ""

#sudo chown elasticsearch:elasticsearch /home/vagrant/downloads/elastic-certificates.p12
sudo chmod +r /home/vagrant/downloads/ -R

cat <<EOF | sudo tee /etc/yum.repos.d/kibana.repo
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
sudo yum install -y kibana

# install kibana
function installKibanaAndGenESPassword() {
  # 设置kibana
  sudo sed -i 's/#server.port:/server.port:/' /etc/kibana/kibana.yml
  sudo sed -i 's/#server.host:.*$/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml
  # 访问kibana的地址，不能以 / 结尾
  sudo sed -i "s/#server.publicBaseUrl:.*/server.publicBaseUrl: \"http:\/\/$(ip address |  grep 'global.*eth1' | awk '{print $2}' | sed -e 's/\/24//'):5601\"/" /etc/kibana/kibana.yml
  sudo sed -i 's/#elasticsearch.hosts:.*$/elasticsearch.hosts: ["http:\/\/192.168.34.11:9200","http:\/\/192.168.34.12:9200","http:\/\/192.168.34.13:9200"]/' /etc/kibana/kibana.yml

  sleep 180 # 180秒后es01执行下面的代码
  # 密码需要集群启动之后才可以生成
  echo 'Y' | sudo /usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto | tee /home/vagrant/es.pass
  pass=$(< /home/vagrant/es.pass tr '' '' | grep 'kibana_system = ' | awk '{print $4}')
  sudo sed -ie 's/#elasticsearch.username/elasticsearch.username/' /etc/kibana/kibana.yml
  sudo sed -ie "s/#elasticsearch.password.*/elasticsearch.password: ${pass}/" /etc/kibana/kibana.yml
  sudo systemctl start kibana
  sudo systemctl enable kibana
}

installKibanaAndGenESPassword &