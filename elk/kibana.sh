#! /bin/bash

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