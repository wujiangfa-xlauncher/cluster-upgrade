#/bin/bash

source ./color-print.sh

#执行前请修改VERSION参数，该参数表示要升级的版本
export VERSION=1.16.0

UPGRADE_NODE_FILE=upgrade_node.sh
UPGRADE_MASTER_FILE=./upgrade_master.sh

read -n 1 -p "是否安装master节点，输入y/n > " upgrade_master
printf "\n"  #换行

if [ $upgrade_master = 'y' ]; then
   if [ ! -f "${UPGRADE_MASTER_FILE}" ]; then
       print_error "升级master的脚本不存在：${UPGRADE_MASTER_FILE}"
       exit 1
   fi
   source ${UPGRADE_MASTER_FILE}
   if [ $? -ne 0 ]; then
      print_error "升级master失败"
      exit 1
   fi
fi

yum install -y sshpass

while true
do

  read -n 1 -p "是否升级其他节点，输入y/n > " upgrade
  printf "\n"  #换行
  if [ $upgrade = 'n' ]; then
     exit 0
  fi

  if [ $upgrade = 'y' ]; then
    if [ ! -f "${UPGRADE_NODE_FILE}" ]; then
       print_error "升级节点的脚本不存在：${UPGRADE_NODE_FILE}"
       exit 1
    fi
    read -p "请输入要升级节点的ip: " node_ip
    if [ -z "${node_ip}" ]; then
       echo "节点ip为空，请重新输入"
       continue
    fi
    read -p "请输入要升级节点的root密码: " node_root_pwd
    if [ -z "${node_root_pwd}" ]; then
        echo "节点root密码为空，请重新输入"
        continue
    fi

    print_tips "远程拷贝升级节点脚本，节点ip: ${node_ip}"
    sshpass -p ${node_root_pwd} scp ${UPGRADE_NODE_FILE} root@${node_ip}:/root/
    if [ $? -ne 0 ]; then
       print_error "升级节点脚本拷贝失败"
       exit 1
    fi

    sshpass -p ${node_root_pwd} scp -r /root/.kube root@${node_ip}:/root/
    if [ $? -ne 0 ]; then
       print_error "kubeconfig拷贝失败"
       exit 1
    fi

    print_tips "远程执行升级节点脚本，节点ip: ${node_ip}"
    sshpass -p ${node_root_pwd} ssh -p 22 root@${node_ip} /root/${UPGRADE_NODE_FILE}
    if [ $? -ne 0 ]; then
       print_error "升级节点脚本执行失败"
       exit 1
    fi

  else
     echo "错误，请重新输入"
  fi

done