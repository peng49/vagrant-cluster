#! /bin/bash

sudo mkdir /etc/rsync
sudo touch /etc/rsync/rsyncd.secrets
sudo touch /etc/rsync/rsyncd.motd
# 权限必须600
sudo chmod 600 /etc/rsync/rsyncd.secrets
sudo bash -c "echo 'rsyn001:123456' > /etc/rsync/rsyncd.secrets"

cat <<EOF | sudo tee /etc/rsyncd.conf
uid = vagrant
gid = vagrant
use chroot = yes

read only = yes
max connections = 4
pid file = /var/run/rsyncd.pid
secrets file = /etc/rsync/rsyncd.secrets
motd file = /etc/rsync/rsyncd.motd
log file = /var/log/rsync.log
#lock file = /var/run/rsync.lock
# exclude = lost+found/
# 是否开启Rsync数据传输日志功能
# transfer logging = yes
timeout = 900
ignore nonreadable = yes
dont compress = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2

# 设置允许哪些主机可以同步数据，可以是单个IP，也可以是网段，多个IP与网段之间使用空格分隔
hosts allow=192.168.34.1/24
# 设置拒绝所有（除hosts allow定义的主机外）
hosts deny=*

[downloads]
        path = /home/vagrant/downloads
        #忽略一些IO错误
        ignore errors
        # comment定义注释说明字串
        comment = sync vagrant home
        # exclude可以指定例外的目录
        # exclude = test/
        # 设置允许连接服务器的账户，账户可以是系统中不存在的用户
        auth users = rsyn001
        #客户端请求显示模块列表时，本模块名称是否显示，默认为true
        list = false
EOF

sudo setenforce 0
sudo sed -ie "s/^SELINUX=.*/SELINUX=disabled/" /etc/selinux/config
sudo systemctl restart rsyncd