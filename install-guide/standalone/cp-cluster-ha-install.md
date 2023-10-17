### [Index](https://github.com/K-PaaS/container-platform/blob/master/README.md) > [CP Install](https://github.com/K-PaaS/container-platform/blob/master/install-guide/Readme.md) > 클러스터 설치 가이드 (HA)

<br>

## Table of Contents

1. [문서 개요](#1)  
  1.1. [목적](#1.1)  
  1.2. [범위](#1.2)  
  1.3. [시스템 구성도](#1.3)  
  1.4. [참고자료](#1.4)  

2. [Container Platform Cluster HA 설치](#2)  
  2.1. [Prerequisite](#2.1)  
  2.2. [LoadBalancer 구성](#2.2)  
  2.3. [SSH Key 생성 및 배포](#2.3)  
  2.4. [Container Platform Cluster 다운로드](#2.4)  
  2.5. [Container Platform Cluster 설치 준비](#2.5)  
  2.6. [Container Platform Cluster 설치](#2.6)  
  2.7. [Container Platform Cluster 설치 확인](#2.7)  

3. [Container Platform Cluster 삭제 (참고)](#3)  

4. [Resource 생성 시 주의사항](#4)  

<br>

## <div id='1'> 1. 문서 개요

### <div id='1.1'> 1.1. 목적
본 문서 (Container Platform Cluster HA 설치 가이드) 는 개방형 PaaS 플랫폼 고도화 및 개발자 지원 환경 기반의 Open PaaS에 배포되는 컨테이터 플랫폼을 설치하기 위한 Kubernetes Native를 Container Platform Cluster Deployment를 이용하여 설치하는 방법을 기술하였다.

<br>

### <div id='1.2'> 1.2. 범위
설치 범위는 Kubernetes Native를 검증하기 위한 Container Platform Cluster HA 설치를 기준으로 작성하였다.

<br>

### <div id='1.3'> 1.3. 시스템 구성도
시스템 구성은 IaaS 환경에 따라 구성 차이가 있으며 External ETCD, Stacked ETCD 방식에 따라 구성에 차이가 있다.<br>

시스템 구성은 LoadBalancer, Kubernetes Cluster 환경으로 구성되어 있으며 이중화된 LoadBalancer 구성 후 Container Platform Cluster Deployment를 통해 Kubernetes Cluster를 설치하고 Pod를 통해 Database, Private registry 등 미들웨어 환경을 제공하여 Container Image로 Kubernetes Cluster에 Container Platform 포털 환경을 배포한다.<br>

**OpenStack, vSphere External ETCD** 기준 총 필요한 VM 환경으로는 **LoadBalancer VM: 2개, Master VM: 3개, External ETCD VM: 3개, Worker VM: 3개 이상**이 필요하다.<br>

**OpenStack, vSphere Stacked ETCD** 기준 총 필요한 VM 환경으로는 **LoadBalancer VM: 2개, Master VM: 3개, Worker VM: 3개 이상**이 필요하다.<br>

**AWS External ETCD** 기준 총 필요한 VM 환경으로는 **Master VM: 3개, External ETCD VM: 3개, Worker VM: 3개 이상**이 필요하다.<br>

**AWS Stacked ETCD** 기준 총 필요한 VM 환경으로는 **Master VM: 3개, Worker VM: 3개 이상**이 필요하다.<br>

본 문서는 Kubernetes Cluster 환경을 구성하기 위한 LoadBalancer, Master VM, External ETCD VM, Worker VM 설치 내용이다.<br>

> 컨테이너 플랫폼 v1.4 버전부터는 Cluster 배포 시 Storage가 함께 배포된다.

> NFS 배포 시 NFS-Server 설치가 우선 진행되어야 한다.  
> [NFS Server 설치](../nfs-server-install-guide.md)  

> Rook-Ceph 배포 시 **각 Worker VM에 Root Volume 외에 추가 Volume 할당**이 우선 진행되어야 한다.

- External ETCD
![image 001]

- Stacked ETCD
![image 002]

<br>

### <div id='1.4'> 1.4. 참고자료
> https://kubespray.io  
> https://github.com/kubernetes-sigs/kubespray  

<br>

## <div id='2'> 2. Container Platform Cluster HA 설치

### <div id='2.1'> 2.1. Prerequisite
본 설치 가이드는 **Ubuntu 20.04** 환경에서 설치하는 것을 기준으로 하였다. Container Platform Cluster HA 설치를 위해서는 Ansible v5.7 +, Jinja 3.1+ 및 python-netaddr이 Ansible 명령을 실행할 시스템에 설치되어 있어야 하며 설치 가이드에 따라 순차적으로 설치가 진행된다.

Container Platform Cluster 설치에 필요한 주요 소프트웨어 및 패키지 Version 정보는 다음과 같다.

|주요 소프트웨어|Version|Python Package|Version
|---|---|---|---|
|Kubespray|v2.22.1|ansible|5.7.1|
|Kubernetes Native|v1.26.5|ansible-core|2.12.5|
|CRI-O|v1.26.0|cryptography|3.4.8|
|Helm|v3.12.0|jinja2|3.1.2|
|Istio|1.16.0|netaddr|0.8.0|
|Podman|3.4.2|pbr|5.11.1|
|Terraform|1.3.4|jmespath|1.0.1|
|NFS Common||ruamel.yaml|0.17.21|
|Rook Ceph|1.10.3|ruamel.yaml.clib|0.2.7|
|Kubeflow|1.7.0|MarkupSafe|2.1.2|
|Vault|1.11.3|

본 가이드 문서에서는 Container Platform 배포 시 다음을 권고하고 있다.

- deb / rpm 호환 Linux OS를 실행하는 하나 이상의 머신 (Ubuntu)
- 머신 당 8G (최소사양) or 16G (권장사양) 이상의 RAM
- control-plane 노드로 사용하는 머신에 2 개 (최소사양) or 4 개 (권장사양) 이상의 CPU
- 클러스터의 모든 시스템 간의 완전한 네트워크 연결


#### 방화벽 정보
- Master Node

| <center>프로토콜</center> | <center>포트</center> | <center>비고</center> |  
| :---: | :---: | :--- |  
| TCP | 111 | NFS PortMapper |  
| TCP | 2049 | NFS |  
| TCP | 2379-2380 | etcd server client API |  
| TCP | 6443 | Kubernetes API Server |  
| TCP | 10250 | Kubelet API |  
| TCP | 10251 | kube-scheduler |  
| TCP | 10252 | kube-controller-manager |  
| TCP | 10255 | Read-Only Kubelet API |  
| UDP | 4789 | Calico networking VXLAN |  

- Worker Node

| <center>프로토콜</center> | <center>포트</center> | <center>비고</center> |  
| :---: | :---: | :--- |  
| TCP | 111 | NFS PortMapper |  
| TCP | 2049 | NFS |  
| TCP | 10250 | Kubelet API |  
| TCP | 10255 | Read-Only Kubelet API |  
| TCP | 30000-32767 | NodePort Services |  
| UDP | 4789 | Calico networking VXLAN |  

<br>

### <div id='2.2'> 2.2. LoadBalancer 구성
Keepalived, HAProxy를 이용하여 LoadBalancer를 구성하며 HA 구성을 위하여 별도의 VIP가 필요하다. LoadBalancer 구성을 위한 2개의 VM에 다음과 같이 Keepalived, HAProxy 설치를 진행한다.

- **AWS 기준 LoadBalancer 설정 방법을 간략하게 기술한다.** OpenStack과 다르게 별도의 VM 생성 및 Keepalived, HAProxy를 사용하지 않고 자체 제공하는 LoadBalancer를 이용한다. 사전에 Master Node VM이 생성되어 있어야 한다.

1. **AWS 서비스 > EC2 > 로드밸런싱 > 로드밸런서 > 로드 밸런서 생성** 으로 이동
<br>
2. **Classic Load Balancer > Create** 로 이동
<br>
3. Load Balancer 이름 입력, LB 생성할 VPC 선택, 리스너 구성의 프로토콜: TCP  / 포트: 6443 선택, 서브넷 선택 후 다음으로 이동
<br>
4. 보안 그룹 선택 후 EC 인스턴스 추가 메뉴까지 다음으로 이동
<br>
5. EC2 인스턴스 추가 에서 Master Node 모두 선택 후 다음으로 이동
<br>
6. Load Balancer 생성
<br>
7. 이후 과정을 생략하고 **2.3. SSH Key 생성 및 배포** 과정을 진행
<br>

- **OpenStack 기준 LoadBalancer VM VIP 할당 방법을 간략하게 기술한다.**
1. OpenStack Horizon 접속
<br>
2. **네트워크 > 네트워크 > "사용할 네트워크 이름 선택" > 포트 탭 > 포트생성** 으로 이동
<br>
3. 이름, 고정 IP 주소 정보 입력 후 생성
<br>
4. **Compute > 인스턴스 > "LoadBalancer 인스턴스 이름 선택" > 인터페이스 탭 > "인터페이스 이름 선택" > 허용된 주소 쌍 탭 > 허용된 주소 쌍 추가** 로 이동
<br>
5. IP 주소 또는 CIDR 항목에 포트 Private IP 정보 입력
<br>

- **vSphere 기준 LoadBalancer VM VIP 할당 방법을 간략하게 기술한다.**
1. pfsense 접속
<br>
2. **Firewall > Virtual IPs** 로 이동
<br>
3. Add 버튼 클릭 후 **Type: IP Alias, 사용할 Interface 선택 및 Address 정보 입력
<br>

- 2개의 LoadBalancer VM에 다음과 같이 Keepalived 설치를 진행한다.
```
$ sudo su -

# apt-get update

# apt-get install -y keepalived

# echo 'net.ipv4.ip_nonlocal_bind=1' >> /etc/sysctl.conf
# echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
# sysctl -p
```

- Keepalived 설정을 진행한다.
```
# vi /etc/keepalived/keepalived.conf
```

```
## Interface Name 정보 : 각 호스트의 쉘에서 ifconfig 입력 후 확인
## VIP 정보 : LoadBalancer VM에 할당한 포트의 Private IP

## Master VM에 설정을 진행한다.
vrrp_instance VI_1 {
  state MASTER
  interface {{INTERFACE_NAME}}
  virtual_router_id 51
  priority 110
  advert_int 1
  authentication {
    auth_type PASS
    auth_pass 1111
  }
  virtual_ipaddress {
    {{VIP}}
  }
}

## Backup VM에 설정을 진행한다.
vrrp_instance VI_1 {
  state BACKUP
  interface {{INTERFACE_NAME}}
  virtual_router_id 51
  priority 100
  advert_int 1
  authentication {
    auth_type PASS
    auth_pass 1111
  }
  virtual_ipaddress {
    {{VIP}}
  }
}
```

- Keepalived 서비스를 시작한다.
```
# systemctl start keepalived
# systemctl enable keepalived
```

- 2개의 LoadBalancer VM에 다음과 같이 HAProxy 설치를 진행한다.
```
# apt-get install -y haproxy
```

- HAProxy 설정을 진행한다. haproxy.cfg 파일 최하단에 다음 내용을 추가한다.

```
# vi /etc/haproxy/haproxy.cfg
```

```
## VIP 정보 : LoadBalancer VM에 할당한 포트의 Private IP
## Master Node IP 정보 : 각 Master Node Private IP 입력

...
listen kubernetes-apiserver-https
  bind {{VIP}}:6443
  mode tcp
  option log-health-checks
  timeout client 3h
  timeout server 3h
  server master1 {{MASTER_NODE_IP1}}:6443 check check-ssl verify none inter 10000
  server master2 {{MASTER_NODE_IP2}}:6443 check check-ssl verify none inter 10000
  server master3 {{MASTER_NODE_IP3}}:6443 check check-ssl verify none inter 10000
  balance roundrobin
```

- HAProxy 서비스를 재시작한다.
```
# systemctl restart haproxy
```

<br>

### <div id='2.3'> 2.3. SSH Key 생성 및 배포
Container Platform Cluster 설치를 위해서는 SSH Key가 인벤토리의 모든 서버들에 복사되어야 한다. 본 설치 가이드에서는 RSA 공개키를 이용하여 SSH 접속 설정을 진행한다.  

SSH Key 생성 및 배포 이후의 모든 설치과정은 **1번 Master Node**에서 진행한다.

- **1번 Master Node**에서 RSA 공개키를 생성한다.
```
$ ssh-keygen -t rsa -m PEM
Generating public/private rsa key pair.
Enter file in which to save the key (/home/ubuntu/.ssh/id_rsa): [엔터키 입력]
Enter passphrase (empty for no passphrase): [엔터키 입력]
Enter same passphrase again: [엔터키 입력]
Your identification has been saved in /home/ubuntu/.ssh/id_rsa.
Your public key has been saved in /home/ubuntu/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:pIG4/G309Dof305mWjdNz1OORx9nQgQ3b8yUP5DzC3w ubuntu@cp-master
The key's randomart image is:
+---[RSA 2048]----+
|            ..= o|
|   . .       * B |
|  . . . .   . = *|
| . .   +     + E.|
|  o   o S     +.O|
|   . o o .     XB|
|    . o . o   *oO|
|     .  .. o B oo|
|        .o. o.o  |
+----[SHA256]-----+
```

- 사용할 **모든 Master, ETCD, Worker Node**에 공개키를 복사한다.
```
## 출력된 공개키 복사

$ cat ~/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5QrbqzV6g4iZT4iR1u+EKKVQGqBy4DbGqH7/PVfmAYEo3CcFGhRhzLcVz3rKb+C25mOne+MaQGynZFpZk4muEAUdkpieoo+B6r2eJHjBLopn5quWJ561H7EZb/GlfC5ThjHFF+hTf5trF4boW1iZRvUM56KAwXiYosLLRBXeNlub4SKfApe8ojQh4RRzFBZP/wNbOKr+Fo6g4RQCWrr5xQCZMK3ugBzTHM+zh9Ra7tG0oCySRcFTAXXoyXnJm+PFhdR6jbkerDlUYP9RD/87p/YKS1wSXExpBkEglpbTUPMCj+t1kXXEJ68JkMrVMpeznuuopgjHYWWD2FgjFFNkp ubuntu@cp-master
```

- 사용할 **모든 Master, ETCD, Worker Node**의 authorized_keys 파일 본문의 마지막 부분(기존 본문 내용 아래 추가)에 공개키를 복사한다.
```
$ vi .ssh/authorized_keys

ex)
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRueywSiuwyfmCSecHu7iwyi3xYS1xigAnhR/RMg/Ws3yOuwbKfeDFUprQR24BoMaD360uyuRaPpfqSL3LS9oRFrj0BSaQfmLcMM1+dWv+NbH/vvq7QWhIszVCLzwTqlHrhgNsh0+EMhqc15KEo5kHm7d7vLc0fB5tZkmovsUFzp01Ceo9+Qye6+j+UM6ssxdTmatoMP3ZZKZzUPF0EZwTcGG6+8rVK2G8GhTqwGLj9E+As3GB1YdOvr/fsTAi2PoxxFsypNR4NX8ZTDvRdAUzIxz8wv2VV4mADStSjFpE7HWrzr4tZUjvvVFptU4LbyON9YY4brMzjxA7kTuf/e3j Generated-by-Nova
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5QrbqzV6g4iZT4iR1u+EKKVQGqBy4DbGqH7/PVfmAYEo3CcFGhRhzLcVz3rKb+C25mOne+MaQGynZFpZk4muEAUdkpieoo+B6r2eJHjBLopn5quWJ561H7EZb/GlfC5ThjHFF+hTf5trF4boW1iZRvUM56KAwXiYosLLRBXeNlub4SKfApe8ojQh4RRzFBZP/wNbOKr+Fo6g4RQCWrr5xQCZMK3ugBzTHM+zh9Ra7tG0oCySRcFTAXXoyXnJm+PFhdR6jbkerDlUYP9RD/87p/YKS1wSXExpBkEglpbTUPMCj+t1kXXEJ68JkMrVMpeznuuopgjHYWWD2FgjFFNkp ubuntu@cp-master
```

<br>

### <div id='2.4'> 2.4. Container Platform Cluster Deployment 다운로드
2.4.부터는 **1번 Master Node**에서만 진행을 하면 된다.(나머지 Node에는 더 이상 추가 작업이 없음)
Container Platform Cluster 설치에 필요한 Source File을 Download 받아 Container Platform Cluster 설치 작업 경로로 위치시킨다.

- Container Platform Cluster Deployment Download URL : https://github.com/k-paas/cp-deployment

- git clone 명령을 통해 다음 경로에서 Container Platform Cluster Deployment 다운로드를 진행한다.
```
$ git clone https://github.com/K-PaaS/cp-deployment.git -b branch_v1.4.x
```

<br>

### <div id='2.5'> 2.5. Container Platform Cluster 설치 준비
Container Platform Cluster 설치에 필요한 환경변수를 사전 정의 후 쉘 스크립트를 통해 설치를 진행한다.

- Container Platform Cluster 설치경로 이동한다.
```
$ cd cp-deployment/standalone/ha_control_plane
```

- Container Platform Cluster 설치에 필요한 환경변수를 정의한다.
```
## External ETCD 구성의 경우
$ vi external-cp-cluster-vars.sh

## Stacked ETCD 구성의 경우
$ vi stacked-cp-cluster-vars.sh
```

- LoadBalancer Domain 정보를 입력한다.
```
## LoadBalancer 정보 = Domain 정보 또는 VIP 정보 입력

#!/bin/bash

export LOADBALANCER_DOMAIN={LoadBalancer의 Domain 정보 또는 VIP 정보 입력}
...
```

- IaaS 공통의 Node 정보를 입력한다. HostName, IP 정보는 다음을 통해 확인할 수 있다.
```
## HostName 정보 = 각 호스트의 쉘에서 hostname 명령어 입력
## Private IP 정보 = 각 호스트의 쉘에서 ifconfig 입력 후 inet ip 입력
## Public IP 정보 = 할당된 Public IP 정보 입력, 미 할당 시 Private IP 정보 입력

## External ETCD 구성

...
export MASTER1_NODE_HOSTNAME={Master 1번 Node의 HostName 정보 입력}
export MASTER1_NODE_PUBLIC_IP={Master 1번 Node의 Public IP 정보 입력}
export MASTER1_NODE_PRIVATE_IP={Master 1번 Node의 Private IP 정보 입력}
export MASTER2_NODE_HOSTNAME={Master 2번 Node의 HostName 정보 입력}
export MASTER2_NODE_PRIVATE_IP={Master 2번 Node의 Private IP 정보 입력}
export MASTER3_NODE_HOSTNAME={Master 3번 Node의 HostName 정보 입력}
export MASTER3_NODE_PRIVATE_IP={Master 3번 Node의 Private IP 정보 입력}
export ETCD1_NODE_HOSTNAME={ETCD 1번 Node의 HostName 정보 입력}
export ETCD1_NODE_PRIVATE_IP={ETCD 1번 Node의 Private IP 정보 입력}
export ETCD2_NODE_HOSTNAME={ETCD 2번 Node의 HostName 정보 입력}
export ETCD2_NODE_PRIVATE_IP={ETCD 2번 Node의 Private IP 정보 입력}
export ETCD3_NODE_HOSTNAME={ETCD 3번 Node의 HostName 정보 입력}
export ETCD3_NODE_PRIVATE_IP={ETCD 3번 Node의 Private IP 정보 입력}

## Worker Node Count Info
export WORKER_NODE_CNT={Worker Node의 갯수}

## Add Worker Node Info
export WORKER1_NODE_HOSTNAME={Worker 1번 Node의 HostName 정보 입력}
export WORKER1_NODE_PRIVATE_IP={Worker 1번 Node의 Private IP 정보 입력}
export WORKER2_NODE_HOSTNAME={Worker 2번 Node의 HostName 정보 입력}
export WORKER2_NODE_PRIVATE_IP={Worker 2번 Node의 Private IP 정보 입력}
export WORKER3_NODE_HOSTNAME={Worker 3번 Node의 HostName 정보 입력}
export WORKER3_NODE_PRIVATE_IP={Worker 3번 Node의 Private IP 정보 입력}
...
export WORKER{n}_NODE_HOSTNAME={Worker Node의 갯수에 맞춰 HostName 정보 변수 추가}
export WORKER{n}_NODE_PRIVATE_IP={Worker Node의 갯수에 맞춰 Private IP 정보 변수 추가}
...
## Storage Type Info (eg. nfs, rook-ceph)
export STORAGE_TYPE={설치할 Storage Type 정보 입력}
export NFS_SERVER_PRIVATE_IP={Storage Type nfs 설정 시 NFS Server의 Private IP 정보 입력}

## Stacked ETCD 구성

...
export MASTER1_NODE_HOSTNAME={Master 1번 Node의 HostName 정보 입력}
export MASTER1_NODE_PUBLIC_IP={Master 1번 Node의 Public IP 정보 입력}
export MASTER1_NODE_PRIVATE_IP={Master 1번 Node의 Private IP 정보 입력}
export MASTER2_NODE_HOSTNAME={Master 2번 Node의 HostName 정보 입력}
export MASTER2_NODE_PRIVATE_IP={Master 2번 Node의 Private IP 정보 입력}
export MASTER3_NODE_HOSTNAME={Master 3번 Node의 HostName 정보 입력}
export MASTER3_NODE_PRIVATE_IP={Master 3번 Node의 Private IP 정보 입력}

## Worker Node Count Info
export WORKER_NODE_CNT={Worker Node의 갯수}

## Add Worker Node Info
export WORKER1_NODE_HOSTNAME={Worker 1번 Node의 HostName 정보 입력}
export WORKER1_NODE_PRIVATE_IP={Worker 1번 Node의 Private IP 정보 입력}
export WORKER2_NODE_HOSTNAME={Worker 2번 Node의 HostName 정보 입력}
export WORKER2_NODE_PRIVATE_IP={Worker 2번 Node의 Private IP 정보 입력}
export WORKER3_NODE_HOSTNAME={Worker 3번 Node의 HostName 정보 입력}
export WORKER3_NODE_PRIVATE_IP={Worker 3번 Node의 Private IP 정보 입력}
...
export WORKER{n}_NODE_HOSTNAME={Worker Node의 갯수에 맞춰 HostName 정보 변수 추가}
export WORKER{n}_NODE_PRIVATE_IP={Worker Node의 갯수에 맞춰 Private IP 정보 변수 추가}
...
## Storage Type Info (eg. nfs, rook-ceph)
export STORAGE_TYPE={설치할 Storage Type 정보 입력}
export NFS_SERVER_PRIVATE_IP={Storage Type nfs 설정 시 NFS Server의 Private IP 정보 입력}
```

<br>

### <div id='2.6'> 2.6. Container Platform Cluster 설치
쉘 스크립트를 통해 필요 패키지 설치, Node 구성정보 설정, Container Platform Cluster 설치정보 설정, Ansible playbook을 통한 Container Platform Cluster 설치를 일괄적으로 진행한다.

- 쉘 스크립트를 통해 설치를 진행한다.
```
## External ETCD 구성의 경우
$ source deploy-external-cp-cluster.sh

## Stacked ETCD 구성의 경우
$ source deploy-stacked-cp-cluster.sh
```

<br>

### <div id='2.7'> 2.7. Container Platform Cluster 설치 확인
Kubernetes Node 및 kube-system Namespace의 Pod를 확인하여 Container Platform Cluster 설치를 확인한다.

```
$ kubectl get nodes
NAME                 STATUS   ROLES                  AGE   VERSION
cp-master-1          Ready    control-plane          12m   v1.26.5
cp-master-2          Ready    control-plane          12m   v1.26.5
cp-master-3          Ready    control-plane          12m   v1.26.5
cp-worker-1          Ready    <none>                 10m   v1.26.5
cp-worker-2          Ready    <none>                 10m   v1.26.5
cp-worker-3          Ready    <none>                 10m   v1.26.5

$ kubectl get pods -n kube-system
NAME                                                           READY   STATUS    RESTARTS   AGE
calico-node-2xwst                                              1/1     Running   0          15h
calico-node-5rbmb                                              1/1     Running   0          15h
calico-node-cqsgz                                              1/1     Running   0          15h
calico-node-gp2vp                                              1/1     Running   0          15h
calico-node-j4mz5                                              1/1     Running   0          15h
calico-node-stjlh                                              1/1     Running   0          15h
coredns-657959df74-99gz9                                       1/1     Running   0          15h
coredns-657959df74-lqhvf                                       1/1     Running   0          15h
dns-autoscaler-b5c786945-hxnr9                                 1/1     Running   0          15h
kube-apiserver-cp-master-1                                     1/1     Running   0          15h
kube-apiserver-cp-master-2                                     1/1     Running   0          15h
kube-apiserver-cp-master-3                                     1/1     Running   0          15h
kube-controller-manager-cp-master-1                            1/1     Running   0          15h
kube-controller-manager-cp-master-2                            1/1     Running   0          15h
kube-controller-manager-cp-master-3                            1/1     Running   0          15h
kube-proxy-clskg                                               1/1     Running   0          15h
kube-proxy-lwjzg                                               1/1     Running   0          15h
kube-proxy-p8kcq                                               1/1     Running   0          15h
kube-proxy-q9wxp                                               1/1     Running   0          15h
kube-proxy-qbv9j                                               1/1     Running   0          15h
kube-proxy-zlkpv                                               1/1     Running   0          15h
kube-scheduler-cp-master-1                                     1/1     Running   0          15h
kube-scheduler-cp-master-2                                     1/1     Running   0          15h
kube-scheduler-cp-master-3                                     1/1     Running   0          15h
metrics-server-876f9ff55-tntqz                                 2/2     Running   0          15h
nodelocaldns-7b5kp                                             1/1     Running   0          15h
nodelocaldns-9hc28                                             1/1     Running   0          15h
nodelocaldns-kf7tb                                             1/1     Running   0          15h
nodelocaldns-nhwr4                                             1/1     Running   0          15h
nodelocaldns-sj2zd                                             1/1     Running   0          15h
nodelocaldns-t7xg9                                             1/1     Running   0          15h
```

<br>

## <div id='3'> 3. Container Platform Cluster 삭제 (참고)
Ansible playbook을 이용하여 Container Platform Cluster 삭제를 진행한다.

```
$ source reset-cp-cluster.sh
```

<br>

## <div id='4'> 4. Resource 생성 시 주의사항
사용자가 직접 Resource를 생성 시 다음과 같은 prefix를 사용하지 않도록 주의한다.

|Resource 명|생성 시 제외해야 할 prefix|
|---|---|
|전체 Resource|kube*|
|Namespace|all|
||kubernetes-dashboard|
||paas-ta-container-platform-temp-namespace|
|Role|paas-ta-container-platform-init-role|
||paas-ta-container-platform-admin-role|
|ResourceQuota|paas-ta-container-platform-low-rq|
||paas-ta-container-platform-medium-rq|
||paas-ta-container-platform-high-rq|
|LimitRanges|paas-ta-container-platform-low-limit-range|
||paas-ta-container-platform-medium-limit-range|
||paas-ta-container-platform-high-limit-range|
|Pod|nodes|
||resources|

<br>

[image 001]:images/stanalone-ha-external-etcd-v1.2.png
[image 002]:images/stanalone-ha-stacked-etcd-v1.2.png

### [Index](https://github.com/K-PaaS/container-platform/blob/master/README.md) > [CP Install](https://github.com/K-PaaS/container-platform/blob/master/install-guide/Readme.md) > 클러스터 설치 가이드 (HA)
