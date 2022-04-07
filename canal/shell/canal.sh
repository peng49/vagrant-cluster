#! /bin/bash

sudo yum install -y java-1.8.0-openjdk

sudo curl -L https://github.com/alibaba/canal/releases/download/canal-1.1.5/canal.deployer-1.1.5.tar.gz -o canal.deployer-1.1.5.tar.gz
sudo mkdir /usr/local/canal-server -p
sudo tar -xzvf canal.deployer-1.1.5.tar.gz -C /usr/local/canal-server
