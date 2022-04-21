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
sudo bash /vagrant/rsync.sh