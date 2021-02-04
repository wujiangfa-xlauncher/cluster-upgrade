#/bin/bash

if [ $# != 1 ] ; then
   echo "aliyun_ccm: slb的公网ip未传入"
   exit 1
fi

ca_data=$(cat /etc/kubernetes/pki/ca.crt|base64 -w 0)

echo "生成/etc/kubernetes/cloud-controller-manager.conf"
cat > /etc/kubernetes/cloud-controller-manager.conf <<EOF
kind: Config
contexts:
- context:
    cluster: kubernetes
    user: system:cloud-controller-manager
  name: system:cloud-controller-manager@kubernetes
current-context: system:cloud-controller-manager@kubernetes
users:
- name: system:cloud-controller-manager
  user:
    tokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $ca_data
    server: https://$1:6443
  name: kubernetes
EOF

echo "重启kubelet"
systemctl restart kubelet