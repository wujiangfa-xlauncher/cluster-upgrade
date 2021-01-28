#/bin/bash

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

yum install -y kubeadm-${VERSION}-0 --disableexcludes=kubernetes
if [ $? -ne 0 ]; then
    echo "yum install -y kubeadm-${VERSION}-0 --disableexcludes=kubernetes failed"
    exit 1
fi

kubeadm upgrade node --v=5
if [ $? -ne 0 ]; then
    echo "kubeadm upgrade node failed"
    exit 1
fi

kubectl drain $(hostname) --ignore-daemonsets

yum install -y kubelet-${VERSION}-0 kubectl-${VERSION}-0 --disableexcludes=kubernetes
if [ $? -ne 0 ]; then
    echo "yum install -y kubelet-${VERSION}-0 kubectl-${VERSION}-0 --disableexcludes=kubernetes failed"
    exit 1
fi

systemctl daemon-reload
systemctl restart kubelet

kubectl uncordon $(hostname)