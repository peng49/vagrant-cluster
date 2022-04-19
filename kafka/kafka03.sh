#! /bin/bash

sudo touch /opt/sync.pass
sudo bash -c "echo '123456' > /opt/sync.pass"
sudo chmod 600 /opt/sync.pass
sudo rsync -av vagrant@192.165.34.91::vagranthome/kafka_2.13-3.1.0.tgz /home/vagrant --password-file=/opt/sync.pass || :

# 从kafka01 复制指定的集群Id
sudo rsync -av vagrant@192.165.34.91::vagranthome/uuid.txt /home/vagrant --password-file=/opt/sync.pass || :

sudo tar -zxvf kafka_2.13-3.1.0.tgz -C /usr/local/ && sudo mv /usr/local/kafka_* /usr/local/kafka