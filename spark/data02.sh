#! /bin/bash
sudo sshpass -p "vagrant" scp -P 22 -o "StrictHostKeyChecking no" -r vagrant@192.168.35.11:/usr/local/hadoop /usr/local/hadoop

sudo useradd hadoop
echo 'hadoop' | sudo passwd hadoop --stdin
sudo chown hadoop:hadoop -R /usr/local/hadoop

# 设置 hadoop 用户可以使用sudo
sudo sed -i '100a hadoop  ALL=(ALL) NOPASSWD:ALL' /etc/sudoers

