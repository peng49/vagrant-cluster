#/bin/sh
sudo curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#https://www.jianshu.com/p/2206cb265247
sudo sed -ri 's/cloud.aliyuncs/aliyun/g' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -ri 's/aliyuncs.com/aliyun.com/g' /etc/yum.repos.d/CentOS-Base.repo

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

sudo yum clean all && sudo yum makecache

sudo yum install -y nginx

# 根据主机名生成不同的 nginx index.html
sudo bash -c 'cat <<EOL > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<body style="text-align:center;padding:45px;"><h2>hostname: ${HOSTNAME}</h2></body>
</html>
EOL'


CFG=/vagrant/${HOSTNAME}.conf
if [ -f "${CFG}" ]; then
  sudo mv -f "${CFG}" /etc/nginx/conf.d/8080.conf
fi

sudo systemctl start nginx &

sudo systemctl enable nginx

sudo systemctl stop firewalld
sudo systemctl disable firewalld




