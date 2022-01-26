# 使用Kubeadm搭建三个节点的K8S集群

## 准备三台机器

准备三台物理机。

```bash
vagrant up
```

检查三个节点已经安装了`kubeadm`, `kubelet` and `kubectl`, 并且docker已经运行了

```bash
➜  kubeadm git:(master) ✗ vagrant status
Current machine states:

k8s-master                running (virtualbox)
k8s-node1                 running (virtualbox)
k8s-node2                 running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
➜  kubeadm git:(master) ✗ vagrant ssh k8s-master
Last login: Sat Jun  9 14:00:35 2018 from 10.0.2.2
-bash: warning: setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory
[vagrant@k8s-master ~]$
[vagrant@k8s-master ~]$
[vagrant@k8s-master ~]$
[vagrant@k8s-master ~]$ which kubeadm
/usr/bin/kubeadm
[vagrant@k8s-master ~]$ which kubelet
/usr/bin/kubelet
[vagrant@k8s-master ~]$ which kubectl
/usr/bin/kubectl
[vagrant@k8s-master ~]$
[vagrant@k8s-master ~]$ sudo docker version
Client:
 Version:         1.13.1
 API version:     1.26
 Package version: docker-1.13.1-63.git94f4240.el7.centos.x86_64
 Go version:      go1.9.4
 Git commit:      94f4240/1.13.1
 Built:           Fri May 18 15:44:33 2018
 OS/Arch:         linux/amd64

Server:
 Version:         1.13.1
 API version:     1.26 (minimum version 1.12)
 Package version: docker-1.13.1-63.git94f4240.el7.centos.x86_64
 Go version:      go1.9.4
 Git commit:      94f4240/1.13.1
 Built:           Fri May 18 15:44:33 2018
 OS/Arch:         linux/amd64
 Experimental:    false
[vagrant@k8s-master ~]$
```

## Configuring Kubernetes Master node


### kubeadm init on master node

```bash
[vagrant@k8s-master ~]$ sudo kubeadm init --pod-network-cidr 172.100.0.0/16 --apiserver-advertise-address 192.168.205.120
[init] Using Kubernetes version: v1.15.3
[preflight] Running pre-flight checks
	[WARNING Service-Docker]: docker service is not enabled, please run 'systemctl enable docker.service'
	[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
	[WARNING SystemVerification]: this Docker version is not on the list of validated versions: 19.03.1. Latest validated version: 18.09
	[WARNING Service-Kubelet]: kubelet service is not enabled, please run 'systemctl enable kubelet.service'
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Activating the kubelet service
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s-master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.205.120]
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s-master localhost] and IPs [192.168.205.120 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s-master localhost] and IPs [192.168.205.120 127.0.0.1 ::1]
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 23.002991 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.15" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node k8s-master as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node k8s-master as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: snipoh.vxfykjsi7e7rbtna
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.205.120:6443 --token snipoh.vxfykjsi7e7rbtna \
    --discovery-token-ca-cert-hash sha256:e202fbfa3eed1e1d6c646dd568285947d67e99b51e824c99aeb6f45080d284c1
[vagrant@k8s-master ~]$
```

然后在master节点上运行

```bash
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

检查pod

```
[vagrant@k8s-master ~]$ kubectl get pod --all-namespaces
NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE
kube-system   coredns-5c98db65d4-f4kjf             0/1     Pending   0          58m
kube-system   coredns-5c98db65d4-xqpwd             0/1     Pending   0          58m
kube-system   etcd-k8s-master                      1/1     Running   0          57m
kube-system   kube-apiserver-k8s-master            1/1     Running   0          57m
kube-system   kube-controller-manager-k8s-master   1/1     Running   0          57m
kube-system   kube-proxy-9l9vr                     1/1     Running   0          58m
kube-system   kube-scheduler-k8s-master            1/1     Running   0          57m
[vagrant@k8s-master ~]$
```

安装网络插件

```bash
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

检查pod

```bash
[vagrant@k8s-master ~]$ kubectl get pod --all-namespaces
NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE
kube-system   coredns-5c98db65d4-gpsvq             1/1     Running   0          7h31m
kube-system   coredns-5c98db65d4-st4pf             1/1     Running   0          7h31m
kube-system   etcd-k8s-master                      1/1     Running   0          7h30m
kube-system   kube-apiserver-k8s-master            1/1     Running   0          7h30m
kube-system   kube-controller-manager-k8s-master   1/1     Running   0          7h30m
kube-system   kube-proxy-kx5mv                     1/1     Running   0          7h31m
kube-system   kube-scheduler-k8s-master            1/1     Running   0          7h30m
kube-system   weave-net-57dtf                      2/2     Running   0          59s
[vagrant@k8s-master ~]$
```

## 添加worker节点

Please use sudo join

```bash
[vagrant@k8s-node2 ~]$ sudo kubeadm join 192.168.205.120:6443 --token tte278.145ozal6u6e26ypm --discovery-token-ca-cert-hash sha256:cbb168e0665fe1b14e96a87c2da5dc1eeda04c70932ac1913d989753703277bb
[preflight] Running pre-flight checks
	[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
	[WARNING SystemVerification]: this Docker version is not on the list of validated versions: 19.03.1. Latest validated version: 18.09
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.15" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Activating the kubelet service
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

[vagrant@k8s-node2 ~]$
```

After that, we can get three nodes ouput on master node

```bash
[vagrant@k8s-master ~]$ kubectl get nodes
NAME         STATUS   ROLES    AGE     VERSION
k8s-master   Ready    master   25m     v1.15.3
k8s-node1    Ready    <none>   11m     v1.15.3
k8s-node2    Ready    <none>   5m39s   v1.15.3
[vagrant@k8s-master ~]$
```

all pod are ok

```bash
[vagrant@k8s-master ~]$ kubectl get pod --all-namespaces
NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE
kube-system   coredns-5c98db65d4-72252             1/1     Running   0          25m
kube-system   coredns-5c98db65d4-x7xf5             1/1     Running   0          25m
kube-system   etcd-k8s-master                      1/1     Running   0          24m
kube-system   kube-apiserver-k8s-master            1/1     Running   0          24m
kube-system   kube-controller-manager-k8s-master   1/1     Running   0          24m
kube-system   kube-proxy-6wdp5                     1/1     Running   0          6m2s
kube-system   kube-proxy-rnk55                     1/1     Running   0          25m
kube-system   kube-proxy-tz8fr                     1/1     Running   0          11m
kube-system   kube-scheduler-k8s-master            1/1     Running   0          24m
kube-system   weave-net-5gmjh                      2/2     Running   0          6m2s
kube-system   weave-net-dtl8f                      2/2     Running   0          16m
kube-system   weave-net-jnlkn                      2/2     Running   0          11m
[vagrant@k8s-master ~]$
```



获取国内镜像
```shell
for i in `kubeadm config images list`; do 
  imageName=${i#k8s.gcr.io/}
  aliName=${imageName}
  if [ $imageName == 'coredns/coredns:v1.8.6' ] 
  then
    aliName='coredns:v1.8.6'
  fi 
  
  docker pull registry.aliyuncs.com/google_containers/$aliName
  docker tag registry.aliyuncs.com/google_containers/$aliName k8s.gcr.io/$imageName
  docker rmi registry.aliyuncs.com/google_containers/$aliName
done;
```

## Reference

[https://blog.tekspace.io/setup-kubernetes-cluster-on-centos-7/](https://blog.tekspace.io/setup-kubernetes-cluster-on-centos-7/)


## 异常
1. 初始化报错
```shell
[init] Using Kubernetes version: v1.23.1
[preflight] Running pre-flight checks
        [WARNING Swap]: swap is enabled; production deployments should disable swap unless testing the NodeSwap feature gate of the kubelet
[preflight] The system verification failed. Printing the output from the verification:
KERNEL_VERSION: 3.10.0-327.4.5.el7.x86_64
CONFIG_NAMESPACES: enabled
CONFIG_NET_NS: enabled
CONFIG_PID_NS: enabled
CONFIG_IPC_NS: enabled
CONFIG_UTS_NS: enabled
CONFIG_CGROUPS: enabled
CONFIG_CGROUP_CPUACCT: enabled
CONFIG_CGROUP_DEVICE: enabled
CONFIG_CGROUP_FREEZER: enabled
CONFIG_CGROUP_PIDS: not set
CONFIG_CGROUP_SCHED: enabled
CONFIG_CPUSETS: enabled
CONFIG_MEMCG: enabled
CONFIG_INET: enabled
CONFIG_EXT4_FS: enabled (as module)
CONFIG_PROC_FS: enabled
CONFIG_NETFILTER_XT_TARGET_REDIRECT: enabled (as module)
CONFIG_NETFILTER_XT_MATCH_COMMENT: enabled (as module)
CONFIG_FAIR_GROUP_SCHED: enabled
CONFIG_OVERLAY_FS: enabled (as module)
CONFIG_AUFS_FS: not set - Required for aufs.
CONFIG_BLK_DEV_DM: enabled (as module)
CONFIG_CFS_BANDWIDTH: enabled
CONFIG_CGROUP_HUGETLB: enabled
CONFIG_SECCOMP: enabled
CONFIG_SECCOMP_FILTER: enabled
DOCKER_VERSION: 20.10.12
DOCKER_GRAPH_DRIVER: devicemapper
OS: Linux
CGROUPS_CPU: enabled
CGROUPS_CPUACCT: enabled
CGROUPS_CPUSET: enabled
CGROUPS_DEVICES: enabled
CGROUPS_FREEZER: enabled
CGROUPS_MEMORY: enabled
CGROUPS_PIDS: missing
CGROUPS_HUGETLB: enabled
error execution phase preflight: [preflight] Some fatal errors occurred:
        [ERROR SystemVerification]: unexpected kernel config: CONFIG_CGROUP_PIDS
        [ERROR SystemVerification]: missing required cgroups: pids
[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
To see the stack trace of this error execute with --v=5 or higher
```

[https://stackoverflow.com/questions/65884578/kubernetes-kubeadm-init-cgroups-pids-missing](https://stackoverflow.com/questions/65884578/kubernetes-kubeadm-init-cgroups-pids-missing)
[https://www.jianshu.com/p/a2e44fe93f88](https://www.jianshu.com/p/a2e44fe93f88)

[https://blog.51cto.com/ckl893/2343871](https://blog.51cto.com/ckl893/2343871)

[基于阿里云镜像站安装Kubernetes](http://ljchen.net/2018/10/23/%E5%9F%BA%E4%BA%8E%E9%98%BF%E9%87%8C%E4%BA%91%E9%95%9C%E5%83%8F%E7%AB%99%E5%AE%89%E8%A3%85kubernetes/)

[kubernetes一些报错集合](https://www.jianshu.com/p/8e78e0abddf9)

[\[ERROR FileAvailable--etc-kubernetes-manifests-kube-apiserver.yaml\]: /etc/kubernetes/manifests/kube-apiserver.yaml already exists](https://github.com/kubernetes/kubeadm/issues/1616)

[Kubernetes启动报错 kubelet cgroup driver: “cgroupfs“ is different from dock](https://blog.csdn.net/sd4493091/article/details/103645032)



### 常用命令

Deployment
创建
> kubectl create -f nginx.yml

创建或者更新
> kubectl apply -f nginx.yml

> kubectl delete deployments.apps [deployment-name]

> kubectl edit deployment [deployment-name]

> kubectl get deployments -o wide


> kubectl exec -it [pod-name] -n [namespace] -- sh


[kubeadm集群添加新master或node节点](https://blog.csdn.net/weixin_46152207/article/details/111870720)
[Creating Highly Available clusters with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)

首先在 master 上生成新的token
> kubeadm token create --print-join-command

在master上生成用于新master加入的证书
> kubeadm init phase upload-certs --experimental-upload-certs

添加新node
> kubeadm join 192.168.205.120:6443 --token okdfch.fgiw682na0ef6kn9 --discovery-token-ca-cert-hash sha256:c574be327af48b17d24b99fbb578fcad74ecf33b4e143d2e3070343a5c3f7e31

添加新master，把红色部分加到 –experimental-control-plane --certificate-key 后
> kubeadm join 192.168.205.120:6443 --token okdfch.fgiw682na0ef6kn9 \
>   --discovery-token-ca-cert-hash sha256:c574be327af48b17d24b99fbb578fcad74ecf33b4e143d2e3070343a5c3f7e31 \
>   --control-plane \ 
>   --certificate-key e799a655f667fc327ab8c91f4f2541b57b96d2693ab5af96314ebddea7a68526
