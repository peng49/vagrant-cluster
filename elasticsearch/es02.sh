#! /bin/bash

sudo touch /opt/sync.pass
sudo bash -c "echo '123456' > /opt/sync.pass"
sudo chmod 600 /opt/sync.pass
sudo mkdir /home/vagrant/downloads
sudo rsync -av rsyn001@192.168.34.11::downloads /home/vagrant/downloads --password-file=/opt/sync.pass || :

cd downloads && shasum -a 512 -c elasticsearch-7.17.3-x86_64.rpm.sha512 && sudo rpm --install elasticsearch-7.17.3-x86_64.rpm


