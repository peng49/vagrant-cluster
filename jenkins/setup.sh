#! /bin/sh
# 设置时区
sudo timedatectl set-timezone Asia/Shanghai

sudo curl -L -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#https://www.jianshu.com/p/2206cb265247
sudo sed -ri 's/cloud.aliyuncs/aliyun/g' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -ri 's/aliyuncs.com/aliyun.com/g' /etc/yum.repos.d/CentOS-Base.repo

sudo yum install -y epel-release
sudo yum clean all && sudo yum makecache

# ssh允许密码登录
sudo sed -ri 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# 允许root用户ssh登录
sudo sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd



if [ ${HOSTNAME} == 'jenkins' ];
then
  # install jenkins
  # https://www.jenkins.io/doc/book/installing/linux/#red-hat-centos
  # 设置时区
sudo timedatectl set-timezone Asia/Shanghai

sudo curl -L -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
  sudo yum -y upgrade
  sudo yum install -y java-11-openjdk
  sudo yum install -y jenkins
  sudo systemctl daemon-reload

  sudo systemctl start jenkins
  #sudo systemctl enable jenkins
  sudo /sbin/chkconfig jenkins on

  #jenkins 初始密码
  echo -n "jenkins init password: " && sudo cat /var/lib/jenkins/secrets/initialAdminPassword
fi


