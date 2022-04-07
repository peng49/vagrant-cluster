#! /bin/sh
# 设置时区
sudo timedatectl set-timezone Asia/Shanghai

sudo curl -L -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#https://www.jianshu.com/p/2206cb265247
sudo sed -ri 's/cloud.aliyuncs/aliyun/g' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -ri 's/aliyuncs.com/aliyun.com/g' /etc/yum.repos.d/CentOS-Base.repo

sudo yum clean all && sudo yum makecache

# ssh允许密码登录
sudo sed -ri 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# 允许root用户ssh登录
sudo sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

sudo bash -c 'cat <<EOF > /etc/yum.repos.d/nginx.repo
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF'

# 关闭selinux
sudo setenforce 0
sudo sed -ri 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux


sudo yum install -y php php-fpm nginx subversion

# 覆盖nginx默认配置文件
sudo cp -f /vagrant/svnadmin.conf /etc/nginx/conf.d/default.conf

# 下载if.svnadmin
sudo curl -L https://github.com/mfreiholz/iF.SVNAdmin/archive/refs/tags/stable-1.6.2.tar.gz -o iF.SVNAdmin.tar.gz
sudo mkdir /var/www/svnadmin -p && \
  sudo tar -xzvf iF.SVNAdmin.tar.gz && \
  sudo mv iF.SVNAdmin-stable-1.6.2/* /var/www/svnadmin/ && \
  sudo rm iF.SVNAdmin-stable-1.6.2/ -rf && \
  sudo chown nginx:nginx -R /var/www/svnadmin/ && \
  sudo chmod -R 777 /var/www/svnadmin/data


# 设置php-fpm的用户为nginx,来和nginx的启动用户保持一致
sudo sed -ri 's/ = apache/ = nginx/g' /etc/php-fpm.d/www.conf

sudo systemctl start php-fpm
sudo systemctl enable php-fpm
sudo systemctl start nginx
sudo systemctl enable nginx

sudo mkdir /var/www/svnregistry -p

# 创建用户文件passwd和权限控制文件authz
sudo touch /var/www/svnregistry/passwd
sudo touch /var/www/svnregistry/authz

sudo chown -R nginx:nginx /var/www/svnregistry
#php session 保存路径
sudo chown nginx:nginx -R /var/lib/php/session/
sudo chmod 1733 -R /var/lib/php/session/

sudo bash -c 'cat <<EOF > /usr/lib/systemd/system/svnserve.service
[Unit]
Description=SVN Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/svnserve -X -r /var/www/svnregistry
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl start svnserve.service
sudo systemctl enable svnserve.service