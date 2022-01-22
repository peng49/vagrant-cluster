#/bin/sh
sudo curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#https://www.jianshu.com/p/2206cb265247
sudo sed -ri 's/cloud.aliyuncs/aliyun/g' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -ri 's/aliyuncs.com/aliyun.com/g' /etc/yum.repos.d/CentOS-Base.repo

sudo yum clean all && sudo yum makecache

sudo yum install -y etcd

CFG=/vagrant/${HOSTNAME}.conf
if [ -f "${CFG}" ]; then
  sudo cp -f "${CFG}" /etc/etcd/etcd.conf
fi

sudo systemctl enable etcd
sudo systemctl start etcd &

sudo systemctl stop firewalld
sudo systemctl disable firewalld




