#/bin/sh

# install jenkins
# https://www.jenkins.io/doc/book/installing/linux/#red-hat-centos
sudo curl -L -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum -y upgrade
sudo yum install -y java-11-openjdk
sudo yum install -y jenkins
sudo systemctl daemon-reload

sudo systemctl start jenkins
#sudo systemctl enable jenkins
sudo /sbin/chkconfig jenkins on