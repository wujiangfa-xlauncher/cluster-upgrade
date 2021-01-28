#/bin/bash

print_tips "1.yum源配置"
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum clean all
yum makecache

print_tips "2.升级master节点的kubeadm,执行yum install -y kubeadm-${VERSION}-0 --disableexcludes=kubernetes"
yum install -y kubeadm-${VERSION}-0 --disableexcludes=kubernetes
if [ $? -ne 0 ]; then
    print_error "yum install -y kubeadm-${VERSION}-0 --disableexcludes=kubernetes failed"
    exit 1
fi

print_tips "3.开始升级master节点，执行kubeadm upgrade apply v${VERSION}"
kubeadm upgrade apply v${VERSION} --v=5
if [ $? -ne 0 ]; then
    print_error "kubeadm upgrade apply v${VERSION} failed"
    exit 1
fi

print_tips "4.驱逐master节点,执行kubectl drain $(hostname) --ignore-daemonsets"
kubectl drain $(hostname) --ignore-daemonsets

print_tips "5.升级节点的kubectl和kubelet,执行yum install -y kubelet-${VERSION}-0 kubectl-${VERSION}-0 --disableexcludes=kubernetes"
yum install -y kubelet-${VERSION}-0 kubectl-${VERSION}-0 --disableexcludes=kubernetes
if [ $? -ne 0 ]; then
    print_error "yum install -y kubelet-${VERSION}-0 kubectl-${VERSION}-0 --disableexcludes=kubernetes failed"
    exit 1
fi

systemctl daemon-reload
systemctl restart kubelet

kubectl uncordon $(hostname)