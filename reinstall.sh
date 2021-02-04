#/bin/bash

if [ $# != 2 ] ; then
   echo "入参错误，需要两个参数，第一个参数为主机名，第二个参数为slb的公网ip"
   exit 1
fi
hostnamectl set-hostname $1
echo "$2 apiserver.k8s.local" >> /etc/hosts

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetescat .
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum clean all
yum makecache

#安装软件
yum install -y kubeadm-1.17.2-0 --disableexcludes=kubernetes
yum install -y kubelet-1.17.2-0 kubectl-1.17.2-0 --disableexcludes=kubernetes
yum install -y https://lstack-mcp-file-bucket.oss-cn-hangzhou.aliyuncs.com/docker/containerd.io-1.2.10-3.2.el7.x86_64.rpm
yum install -y https://lstack-mcp-file-bucket.oss-cn-hangzhou.aliyuncs.com/docker/18.09.9/docker-ce-cli-18.09.9-3.el7.x86_64.rpm
yum install -y https://lstack-mcp-file-bucket.oss-cn-hangzhou.aliyuncs.com/docker/18.09.9/docker-ce-18.09.9-3.el7.x86_64.rpm

mkdir -p /etc/docker/
cat <<EOF > /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://28mvbjoa.mirror.aliyuncs.com"
  ],
  "bip": "169.254.123.1/24",
  "data-root": "/data/docker",
  "exec-opts": [
    "native.cgroupdriver=systemd"
  ],
  "live-restore": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
EOF

#启动docker
systemctl enable docker
systemctl enable kubelet
systemctl start docker
#系统配置
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
vm.swappiness=0
EOF
sysctl --system
swapoff -a
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
yum install ipset ipvsadm -y