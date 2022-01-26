#/bin/sh
sudo curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#https://www.jianshu.com/p/2206cb265247
sudo sed -ri 's/cloud.aliyuncs/aliyun/g' /etc/yum.repos.d/CentOS-Base.repo

sudo yum clean all && sudo yum makecache

# install some tools
sudo yum install -y vim telnet bind-utils wget


# install docker
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh

if [ ! $(getent group docker) ];
then 
    sudo groupadd docker;
else
    echo "docker user group already exists"
fi

sudo touch /etc/docker/daemon.json
sudo bash -c 'cat <<EOF > /etc/docker/daemon.json
{
        "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF'

sudo gpasswd -a $USER docker
sudo systemctl restart docker

rm -rf get-docker.sh

# open password auth for backup if ssh key doesn't work, bydefault, username=vagrant password=vagrant
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

sudo bash -c 'cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF'

# 也可以尝试国内的源 http://ljchen.net/2018/10/23/%E5%9F%BA%E4%BA%8E%E9%98%BF%E9%87%8C%E4%BA%91%E9%95%9C%E5%83%8F%E7%AB%99%E5%AE%89%E8%A3%85kubernetes/

sudo setenforce 0

# install kubeadm, kubectl, and kubelet.
sudo yum install -y kubelet kubeadm kubectl

sudo bash -c 'cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward=1
EOF'

sudo bash -c 'cat <<EOF >  /etc/sysconfig/kubelet
KUBELET_EXTRA_ARGS="--fail-swap-on=false --cgroup-driver=systemd"
EOF'

sudo sysctl --system

sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo swapoff -a

# 永久关闭swap分区
sudo sed -ri 's/.*swap.*/#&/' /etc/fstab

systemctl enable docker.service
systemctl enable kubelet.service

sudo bash -c 'cat <<EOF >  /tmp/local.sh
for i in \`kubeadm config images list\`; do
  imageName=\${i#k8s.gcr.io/}
  aliName=\${imageName}
  if [ \$imageName == "coredns/coredns:v1.8.6" ]
  then
    aliName="coredns:v1.8.6"
  fi

  docker pull registry.aliyuncs.com/google_containers/\$aliName
  docker tag registry.aliyuncs.com/google_containers/\$aliName k8s.gcr.io/\$imageName
  docker rmi registry.aliyuncs.com/google_containers/\$aliName
done;
EOF'

sudo sh /tmp/local.sh