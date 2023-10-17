### [Index](https://github.com/K-PaaS/container-platform/blob/master/README.md) > [CP Install](https://github.com/K-PaaS/container-platform/blob/master/install-guide/Readme.md) > Edge 설치 가이드

<br>

## Table of Contents

1. [문서 개요](#1)  
  1.1. [목적](#1.1)  
  1.2. [범위](#1.2)  
  1.3. [시스템 구성도](#1.3)  
  1.4. [참고자료](#1.4)  

2. [KubeEdge 설치](#2)  
  2.1. [Prerequisite](#2.1)  
  2.2. [Kubernetes Native Cluster 배포](#2.2)  
  2.3. [KubeEdge 설치 준비](#2.3)  
  2.4. [KubeEdge 설치](#2.4)  
  2.5. [KubeEdge 설치 확인](#2.5)  

3. [KubeEdge Reset (참고)](#3)  

4. [Resource 생성 시 주의사항](#4)

<br>

## <div id='1'> 1. 문서 개요

### <div id='1.1'> 1.1. 목적
본 문서 (KubeEdge 설치 가이드) 는 개방형 PaaS 플랫폼 고도화 및 개발자 지원 환경 기반의 Open PaaS에 배포되는 컨테이터 플랫폼을 설치하기 위한 KubeEdge를 설치하는 방법을 기술하였다.

<br>

### <div id='1.2'> 1.2. 범위
설치 범위는 KubeEdge를 검증하기 위한 기본 설치를 기준으로 작성하였다.

<br>

### <div id='1.3'> 1.3. 시스템 구성도
시스템 구성은 Kubernetes Cluster(Master, Worker, Edge) 환경으로 구성되어 있다. <br>
Container Platform Cluster Deployment 통해 Kubernetes Cluster(Master, Worker)를 설치하고 Kubernetes Cluster와 Edge 환경에 KubeEdge를 설치한다. Pod를 통해서는 Database, Private registry 등 미들웨어 환경을 제공하여 Container Image로 Kubernetes Cluster에 Container Platform 포털 환경을 배포한다. <br>
총 필요한 VM 환경으로는 **단독배포 또는 HA배포 클러스터, Edge VM: 1개 이상** 이 필요하며,  본 문서는 Kubernetes Cluster 환경에 Edge Node를 구성하기 위한 Edge VM 설치 내용이다.

![image 001]

<br>

### <div id='1.4'> 1.4. 참고자료
> https://kubeedge.io/en/docs/   
> https://github.com/kubeedge/kubeedge

<br>

## <div id='2'> 2. KubeEdge 설치

### <div id='2.1'> 2.1. Prerequisite
본 설치 가이드에서는 **Master, Worker Node의 환경을 Ubuntu 20.04 amd64**, **Edge Node의 환경을 Ubuntu 20.04 arm64** 환경에서 설치하는 것을 기준으로 하였다. KubeEdge 설치를 위해서는 Kubernetes Native Cluster가 시스템에 배포되어 있어야 한다.

KubeEdge 설치에 필요한 주요 소프트웨어 및 패키지 Version 정보는 다음과 같다.

|주요 소프트웨어|Version|
|---|---|
|KubeEdge|v1.12.0|
|EdgeMesh|v1.12.0|
|Kubernetes Native|v1.26.5|
|Kubernetes Native (Edge Node)|v1.22.6|
|CRI-O|v1.26.0|
|CRI-O (Edge Node)|v1.22.0|

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
| TCP | 6443 | kubernetes API Server |  
| TCP | 9443 | cloudcore router port |  
| TCP | 10000-10004 | cloudHub websocket port |  
| TCP | 10001 | cloudHub quic port |  
| TCP | 10002 | cloudHub https port |  
| TCP | 10003 | cloudStream streamPort |  
| TCP | 10004 | cloudStream tunnelPort |  
| TCP | 10250 | Kubelet API |  
| TCP | 10251 | kube-scheduler |  
| TCP | 10252 | kube-controller-manager |  
| TCP | 10255 | Read-Only Kubelet API |  
| TCP | 20004 | edgeMesh server containerPort |  
| TCP | 20006 | edgeMesh tunnel listenPort |  
| TCP | 40001 | edgeMesh edgeProxy listenPort |  
| UDP | 4789 | Calico networking VXLAN |  

- Worker Node

| <center>프로토콜</center> | <center>포트</center> | <center>비고</center> |  
| :---: | :---: | :--- |  
| TCP | 111 | NFS PortMapper |  
| TCP | 2049 | NFS |  
| TCP | 10250 | Kubelet API |  
| TCP | 10255 | Read-Only Kubelet API |  
| TCP | 20006 | edgeMesh tunnel listenPort |  
| TCP | 30000-32767 | NodePort Services |  
| TCP | 40001 | edgeMesh edgeProxy listenPort |  
| UDP | 4789 | Calico networking VXLAN |  

- Edge Node

| <center>프로토콜</center> | <center>포트</center> | <center>비고</center> |  
| :---: | :---: | :--- |  
| TCP | 111 | NFS PortMapper |  
| TCP | 1883-1884 | eventBus mqttPort |  
| TCP | 2049 | NFS |  
| TCP | 10001 | edgeHub quic port |  
| TCP | 10250 | Kubelet API |  
| TCP | 10255 | Read-Only Kubelet API |  
| TCP | 10350 | Use kubectl logs |  
| TCP | 10550 | edgecore list-watch port |  
| TCP | 20006 | edgeMesh tunnel listenPort |  
| TCP | 30000-32767 | NodePort Services |  
| TCP | 40001 | edgeMesh edgeProxy listenPort |  

<br>

### <div id='2.2'> 2.2. Kubernetes Native Cluster 배포
KubeEdge 설치를 위해서는 Cloud 영역에 Kubernetes Cluster가 배포되어있어야 하며, 배포 이후 Edge 영역에 Edge Node를 배포하여야 한다.

- Cloud 영역에 Container Platform Cluster Deployment 통해 Kubernetes Cluster 배포를 진행한다.

> https://github.com/K-PaaS/container-platform/blob/master/install-guide/standalone/cp-cluster-install.md (단독배포)

> https://github.com/K-PaaS/container-platform/blob/master/install-guide/standalone/cp-cluster-ha-install.md (HA배포)

<br>

### <div id='2.3'> 2.3. KubeEdge 설치 준비
KubeEdge 설치에 필요한 환경변수를 사전 정의 후 쉘 스크립트를 통해 설치를 진행한다.

- EdgeNode의 환경이 **라즈베리파이**일 경우 다음 정보를 추가한다. 라즈베리파이 환경이 아닐 경우 아래의 과정을 생략하고 KubeEdge 설치 환경변수 정의부터 진행한다.
```
# vi /boot/firmware/cmdline.txt

... cgroup_enable=memory cgroup_memory=1 (맨 뒤에 추가)
```

- **라즈베리파이** Reboot을 진행한다.
```
# reboot
```

- Container Platform Cluster 설치경로 이동한다. 이후 부터는 **Master Node**에서만 진행을 하면 된다.
```
## 단독배포 Cluster의 경우
$ cd cp-deployment/standalone/single_control_plane

## HA배포 Cluster의 경우
$ cd cp-deployment/standalone/ha_control_plane
```

- KubeEdge 설치에 필요한 환경변수를 정의한다. HostName, IP 정보는 다음을 통해 확인할 수 있다.
```
$ vi cp-edge-vars.sh
```

```
## HostName 정보 = 각 호스트의 쉘에서 hostname 명령어 입력
## Private IP 정보 = 각 호스트의 쉘에서 ifconfig 입력 후 inet ip 입력

#!/bin/bash

export CLOUDCORE_VIP={Master Node의 Public IP 정보 입력}

export CLOUDCORE1_NODE_HOSTNAME={CloudCore가 설치될 Node의 HostName 정보 입력}
export CLOUDCORE2_NODE_HOSTNAME={CloudCore가 설치될 Node의 HostName 정보 입력}

## Edge Node Count Info
export EDGE_NODE_CNT={Edge Node의 갯수}

## Add Edge Node Info
export EDGE1_NODE_HOSTNAME={Edge 1번 Node의 HostName 정보 입력}
export EDGE1_NODE_PRIVATE_IP={Edge 1번 Node의 Private IP 정보 입력}
...
export EDGE{n}_NODE_HOSTNAME={Edge Node의 갯수에 맞춰 HostName 정보 변수 추가}
export EDGE{n}_NODE_PRIVATE_IP={Edge Node의 갯수에 맞춰 Private IP 정보 변수 추가}
```

<br>


### <div id='2.4'> 2.4. KubeEdge 설치
쉘 스크립트를 통해 필요 패키지 설치, Node 구성정보 설정, KubeEdge 설치정보 설정, Ansible playbook을 통한 KubeEdge 설치를 일괄적으로 진행한다.

- 쉘 스크립트를 통해 설치를 진행한다.
```
## 단독배포 구성의 경우
$ source deploy-cp-edge.sh

## External ETCD 구성의 경우
$ source deploy-external-cp-edge.sh

## Stacked ETCD 구성의 경우
$ source deploy-stacked-cp-edge.sh
```

<br>

### <div id='2.5'> 2.5. KubeEdge 설치 확인
Kubernetes Node 및 kube-system Namespace의 Pod를 확인하여 KubeEdge 설치를 확인한다.

```
# kubectl get nodes
NAME                 STATUS   ROLES                  AGE     VERSION
cp-edge              Ready    agent,edge             5m40s   v1.22.6-kubeedge-v1.12.0
cp-master            Ready    control-plane,master   39m     v1.26.5
cp-worker-1          Ready    <none>                 38m     v1.26.5
cp-worker-2          Ready    <none>                 38m     v1.26.5
cp-worker-3          Ready    <none>                 38m     v1.26.5

# kubectl get pods -n kube-system
NAME                                       READY   STATUS    RESTARTS   AGE
calico-node-4hbw5                          1/1     Running   0          4m34s
calico-node-8q5tv                          1/1     Running   0          5m9s
calico-node-qlq5k                          1/1     Running   0          5m26s
calico-node-xc55c                          1/1     Running   0          4m53s
coredns-657959df74-grflz                   1/1     Running   0          37m
coredns-657959df74-wbdl6                   1/1     Running   0          37m
dns-autoscaler-b5c786945-cbcv9             1/1     Running   0          37m
kube-apiserver-cp-master                   1/1     Running   0          36m
kube-controller-manager-cp-master          1/1     Running   1          39m
kube-proxy-2ckfd                           1/1     Running   0          38m
kube-proxy-hb8p2                           1/1     Running   0          38m
kube-proxy-nnh6d                           1/1     Running   0          38m
kube-proxy-p9srm                           1/1     Running   0          6m4s
kube-proxy-zmp95                           1/1     Running   0          38m
kube-scheduler-cp-master                   1/1     Running   1          39m
metrics-server-5cd75b7749-57sc2            2/2     Running   0          37m
nginx-proxy-cp-worker-1                    1/1     Running   0          38m
nginx-proxy-cp-worker-2                    1/1     Running   0          38m
nginx-proxy-cp-worker-3                    1/1     Running   0          38m
nodelocaldns-24vq4                         1/1     Running   0          6m4s
nodelocaldns-jjrjj                         1/1     Running   0          37m
nodelocaldns-kgzxb                         1/1     Running   0          37m
nodelocaldns-l9s47                         1/1     Running   0          37m
```

<br>

## <div id='3'> 3. KubeEdge Reset (참고)
Ansible playbook을 이용하여 KubeEdge 삭제를 진행한다.

```
$ source reset-cp-edge.sh
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

[image 001]:images/edge-v1.2.png

### [Index](https://github.com/K-PaaS/container-platform/blob/master/README.md) > [CP Install](https://github.com/K-PaaS/container-platform/blob/master/install-guide/Readme.md) > Edge 설치 가이드
