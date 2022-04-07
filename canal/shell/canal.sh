#! /bin/bash
# install java
sudo yum install -y java-1.8.0-openjdk

# download canal-deployer
sudo curl -L https://github.com/alibaba/canal/releases/download/canal-1.1.5/canal.deployer-1.1.5.tar.gz -o canal.deployer-1.1.5.tar.gz
sudo mkdir /usr/local/canal-server -p
sudo tar -xzvf canal.deployer-1.1.5.tar.gz -C /usr/local/canal-server


# 修改 mysql host
sudo sed -ri 's/canal.instance.master.address=127.0.0.1:3306/canal.instance.master.address=192.168.150.120:3306/g' /usr/local/canal-server/conf/example/instance.properties
sudo sed -ri 's/canal.instance.master.journal.name=/canal.instance.master.journal.name=binlog.000003/g' /usr/local/canal-server/conf/example/instance.properties
sudo sed -ri 's/canal.instance.master.position=/canal.instance.master.position=156/g' /usr/local/canal-server/conf/example/instance.properties
sudo sed -ri 's/canal.instance.dbPassword=canal/canal.instance.dbPassword=Canal@ass01/g' /usr/local/canal-server/conf/example/instance.properties