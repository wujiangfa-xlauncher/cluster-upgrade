#/bin/bash
## 设置镜像来源仓库地址
MY_REGISTRY=registry.aliyuncs.com/google_containers
## 设置镜像上传仓库地址
PUSH_REGISTRY=registry.aliyuncs.com/launcher
## 拉取镜像
docker pull ${MY_REGISTRY}/kube-apiserver:v1.16.0
docker pull ${MY_REGISTRY}/kube-controller-manager:v1.16.0
docker pull ${MY_REGISTRY}/kube-scheduler:v1.16.0
docker pull ${MY_REGISTRY}/kube-proxy:v1.16.0
docker pull ${MY_REGISTRY}/etcd:3.3.15-0
docker pull ${MY_REGISTRY}/pause:3.1
docker pull ${MY_REGISTRY}/coredns:1.6.2
## 设置标签
docker tag ${MY_REGISTRY}/kube-apiserver:v1.16.0          ${PUSH_REGISTRY}/kube-apiserver:v1.16.0
docker tag ${MY_REGISTRY}/kube-scheduler:v1.16.0          ${PUSH_REGISTRY}/kube-scheduler:v1.16.0
docker tag ${MY_REGISTRY}/kube-controller-manager:v1.16.0 ${PUSH_REGISTRY}/kube-controller-manager:v1.16.0
docker tag ${MY_REGISTRY}/kube-proxy:v1.16.0              ${PUSH_REGISTRY}/kube-proxy:v1.16.0
docker tag ${MY_REGISTRY}/etcd:3.3.15-0                   ${PUSH_REGISTRY}/etcd:3.3.15-0
docker tag ${MY_REGISTRY}/pause:3.1                       ${PUSH_REGISTRY}/pause:3.1
docker tag ${MY_REGISTRY}/coredns:1.6.2                   ${PUSH_REGISTRY}/coredns:1.6.2

docker push ${PUSH_REGISTRY}/kube-apiserver:v1.16.0
docker push ${PUSH_REGISTRY}/kube-scheduler:v1.16.0
docker push ${PUSH_REGISTRY}/kube-controller-manager:v1.16.0
docker push ${PUSH_REGISTRY}/kube-proxy:v1.16.0
docker push ${PUSH_REGISTRY}/etcd:3.3.15-0
docker push ${PUSH_REGISTRY}/pause:3.1
docker push ${PUSH_REGISTRY}/coredns:1.6.2