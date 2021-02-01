## Table of Contents

1. [문서 개요](#1)  
  1.1. [목적](#1.1)  
  1.2. [범위](#1.2)  
  1.3. [시스템 구성도](#1.3)  
  1.4. [참고자료](#1.4)  

2. [KubeEdge 설치](#2)  
  2.1. [Prerequisite](#2.1)  
  2.2. [Docker 설치](#2.2)  
  2.3. [kubeadm, kubectl, kubelet 설치](#2.3)  
  2.4. [Kubernetes Native Cluster 배포](#2.4)  
  2.5. [KubeEdge keadm 설치](#2.5)  
  2.6. [KubeEdge CloudCore 설치](#2.6)  
  2.7. [KubeEdge EdgeCore 설치](#2.7)  
  2.8. [kubectl logs 기능 활성화](#2.8)  
  2.9. [KubeEdge 설치 확인](#2.9)  

3. [KubeEdge Reset (참고)](#3)  

4. [컨테이너 플랫폼 운영자 생성 및 Token 획득, Namespace 생성 (참고)](#4)  
  4.1. [Cluster Role 운영자 생성 및 Token 획득](#4.1)  
  4.2. [Namespace 사용자 Token 획득](#4.2)  
  4.3. [컨테이너 플랫폼 Temp Namespace 생성](#4.3)  
  
5. [Kubernates Monitoring 도구 (Metric-server) 배포](#5)    

6. [Resource 생성 시 주의사항](#6)  

<br>

## <div id='1'> 1. 문서 개요

### <div id='1.1'> 1.1. 목적
본 문서 (KubeEdge 설치 가이드) 는 개방형 PaaS 플랫폼 고도화 및 개발자 지원 환경 기반의 Open PaaS에 배포되는 컨테이터 플랫폼을 설치하기 위한 KubeEdge를 설치하는 방법을 기술하였다.

PaaS-TA 6.0 버전부터는 KubeEdge 기반으로 단독 배포를 지원한다. 기존 Container 서비스 기반으로 설치를 원할 경우에는 PaaS-TA 5.0 이하 버전의 문서를 참고한다.

<br>

### <div id='1.2'> 1.2. 범위
설치 범위는 KubeEdge를 검증하기 위한 기본 설치를 기준으로 작성하였다.

<br>

### <div id='1.3'> 1.3. 시스템 구성도
시스템 구성은 Kubernetes Cluster(Master, Worker)와 BOSH Inception(DBMS, HAproxy, Private Registry)환경으로 구성되어 있다. Kubeadm를 통해 Kubernetes Cluster를 설치하고 Kubernetes 환경에 KubeEdge를 설치한다. BOSH release로는 Database, Private registry 등 미들웨어 환경을 제공하여 Docker Image로 Kubernetes Cluster에 Container Platform 포털 환경을 배포한다. 총 필요한 VM 환경으로는 Master VM: 1개, Worker VM: 1개 이상, Inception VM: 1개가 필요하고 본 문서는 Kubernetes Cluster 환경을 구성하기 위한 Master VM 과 Worker VM 설치 내용이다.

![image 001]

<br>

### <div id='1.4'> 1.4. 참고자료
> https://docs.docker.com/engine/install/  
> https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/  
> https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/  
> https://kubeedge.io/en/docs/ 
> https://github.com/kubeedge/kubeedge

<br>

## <div id='2'> 2. KubeEdge 설치

### <div id='2.1'> 2.1. Prerequisite
본 설치 가이드는 Ubuntu 환경에서 설치하는 것을 기준으로 하였다. KubeEdge 설치를 위해서는 Docker, Kubernetes Native Cluster가 시스템에 배포되어 있어야 한다.

KubeEdge 설치에 필요한 주요 소프트웨어 및 패키지 Version 정보는 다음과 같다.

|주요 소프트웨어|Version|
|---|---|
|KubeEdge|v1.4.0|
|Kubernetes Native|v1.18.6|
|Docker|v19.03.12|

Kubernetes 공식 가이드 문서에서는 Cluster 배포 시 다음을 권고하고 있다.

- deb / rpm 호환 Linux OS를 실행하는 하나 이상의 머신 (Ubuntu 또는 CentOS)
- 머신 당 2G 이상의 RAM
- control-plane 노드로 사용하는 머신에 2 개 이상의 CPU
- 클러스터의 모든 시스템 간의 완전한 네트워크 연결

<br>

### <div id='2.2'> 2.2. Docker 설치
기본적으로 Kubernetes는 컨테이너 런타임 인터페이스 (CRI) 를 사용하여 선택한 컨테이너 런타임과 상호작용을 한다.  

컨테이너 런타임에는 Docker, containerd, CRI-O 가 존재하며 본 설치 가이드에서는 Docker를 기준으로 설치를 진행한다.  

설치대상은 전체 Node 대상이며 본 설치 가이드에서는 19.03.12 버전으로 설치를 진행한다.

- apt-get update를 진행한다.
```
$ sudo apt-get update
```

- Docker 설치에 필요한 Package 설치를 진행한다.
```
$ sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
```

- Docker Download 및 설치를 위한 apt-key 및 apt-repository를 추가한다.
```
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

$ sudo apt-key fingerprint 0EBFCD88

$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

- 설치 가능한 Docker 버전 정보를 확인한다.
```
$ apt-cache madison docker-ce
 docker-ce | 5:19.03.13~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.12~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.11~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.10~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.9~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.8~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.7~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.6~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.5~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.4~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.3~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.2~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.1~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.0~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:18.09.9~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:18.09.8~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:18.09.7~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:18.09.6~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:18.09.5~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:18.09.4~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:18.09.3~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:18.09.2~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:18.09.1~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:18.09.0~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 18.06.3~ce~3-0~ubuntu | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 18.06.2~ce~3-0~ubuntu | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 18.06.1~ce~3-0~ubuntu | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 18.06.0~ce~3-0~ubuntu | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 18.03.1~ce~3-0~ubuntu | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
```

- Docker 설치를 진행한다.
```
# {VERSION_STRING} : Version 정보. (ex : 5:19.03.12~3-0~ubuntu-bionic)
$ sudo apt-get install -y docker-ce={VERSION_STRING} docker-ce-cli={VERSION_STRING} containerd.io
```

- Docker 설치 후 사용자에 권한을 부여한다.
```
# {USER_NAME} : 현재 사용자
$ sudo usermod -aG docker {USER_NAME}
```

<br>

### <div id='2.3'> 2.3. kubeadm, kubectl, kubelet 설치
KubeEdge 설치를 위해서는 Master Node에 Kubernetes Cluster가 배포되어있어야 한다. Cluster를 배포하기 위해 전체 Node에 kubeadm, kubectl, kubelet 설치가 진행되어야한다.

- apt-get update 및 필요한 Package 설치를 진행한다.
```
$ sudo apt-get update && sudo apt-get install -y apt-transport-https curl
```

- kubeadm, kubectl, kubelet Download 및 설치를 위한 apt-key 및 apt-repository를 추가한다.
```
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

$ cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
```

- apt-get update 및 kubeadm, kubectl, kubelet 설치를 진행한다. 본 설치 가이드에서는 v1.18.6 기준으로 설치를 진행한다.
```
$ sudo apt-get update

$ sudo apt-get install -y kubelet=1.18.6-00 kubeadm=1.18.6-00 kubectl=1.18.6-00
```

- kubeadm, kubectl, kubelet Package를 자동으로 설치, 업그레이드, 제거하지 않도록 고정한다.
```
$ sudo apt-mark hold kubelet kubeadm kubectl
```

<br>

### <div id='2.4'> 2.4. Kubernetes Native Cluster 배포
KubeEdge 설치를 위해서는 Master Node에 Kubernetes Cluster가 배포되어있어야 한다. 

- Master Node에 Kubernetes Cluster 배포를 진행한다. Cluster 배포는 kubeadm을 통해 진행하며 배포 완료 후 출력되는 kubeadm join 명령어는 KubeEdge 설치에서는 사용하지 않는다.
```
# {MASTER_NODE_IP} : Master Node Private IP
# --pod-network-cidr=10.244.0.0/16은 flannel CNI 설치 시 설정값
$ sudo kubeadm init --apiserver-advertise-address={MASTER_NODE_IP} --pod-network-cidr=10.244.0.0/16
```

- Cluster 배포 완료 후 사용을 위하여 다음 과정을 진행한다.
```
$ mkdir -p $HOME/.kube

$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

- 추후 keadm 사용을 위해 root 계정으로 전환하여 동일한 과정을 진행한다.
```
$ sudo su -

# mkdir -p $HOME/.kube

# cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

# chown $(id -u):$(id -g) $HOME/.kube/config

# exit
```

- KubeEdge에서는 본 설치 가이드 작성 시점에 CNI를 지원하지 않으나 Master Node 구성 시 CNI Plugin이 배포되지 않으면 CoreDNS Pod가 Pending 상태를 유지하는 이슈가 발생한다. 따라서 Master Node에는 CNI Pod 배포가 필요하다. 본 설치 가이드에서는 flannel을 사용한다.
> CNI 이슈 : https://github.com/kubeedge/kubeedge/issues/2083
```
# CNI Plugin 배포 전 CodrDNS 확인, Pending 상태로 확인
$ kubectl get pods -n kube-system
NAME                                   READY   STATUS     RESTARTS   AGE
coredns-66bff467f8-s6wdg               0/1     Pending    0          4m6s
coredns-66bff467f8-wzzgk               0/1     Pending    0          4m6s
etcd-ip-10-0-0-96                      1/1     Running    0          4m21s
kube-apiserver-ip-10-0-0-96            1/1     Running    0          4m21s
kube-controller-manager-ip-10-0-0-96   1/1     Running    0          4m21s
kube-proxy-lsjrg                       1/1     Running    0          4m6s
kube-scheduler-ip-10-0-0-96            1/1     Running    0          4m21s

# CNI Plugin 배포
$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml

# CNI Plugin 배포 후 CodrDNS 확인, Running 상태로 확인
$ kubectl get pods -n kube-system
NAME                                   READY   STATUS    RESTARTS   AGE
coredns-66bff467f8-s6wdg               1/1     Running   0          8m26s
coredns-66bff467f8-wzzgk               1/1     Running   0          8m26s
etcd-ip-10-0-0-96                      1/1     Running   0          8m41s
kube-apiserver-ip-10-0-0-96            1/1     Running   0          8m41s
kube-controller-manager-ip-10-0-0-96   1/1     Running   0          8m41s
kube-flannel-ds-amd64-dqf2w            1/1     Running   0          4m31s
kube-proxy-lsjrg                       1/1     Running   0          8m26s
kube-scheduler-ip-10-0-0-96            1/1     Running   0          8m41s
```

- 이후 Worker Node에 배포되지 않도록 CNI Plugin의 DaemonSet yaml 수정을 진행한다.
```
$ kubectl edit daemonsets.apps -n kube-system kube-flannel-ds-amd64
```

- spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms.matchExpressions 경로에 아래 내용을 추가한다.
```
- key: node-role.kubernetes.io/edge
  operator: DoesNotExist
```

<br>

### <div id='2.5'> 2.5. KubeEdge keadm 설치
KubeEdge 설치를 위한 keadm 설치를 진행한다. keadm 실행 시 Super User 혹은 root 권한이 필요하므로 root 권한으로 설치를 진행한다.

- root 계정으로 전환 후 전체 Master, Worker Node에 keadm 다운로드 및 설치를 진행한다.
```
$ sudo su -

# git clone -b dev --single-branch https://github.com/PaaS-TA/paas-ta-container-platform-deployment.git

# cd paas-ta-container-platform-deployment/edge

# cp keadm /usr/bin/keadm
```

<br>

### <div id='2.6'> 2.6. KubeEdge CloudCore 설치
본 항목부터 Master Node, Worker Node의 명칭을 KubeEdge 공식 가이드에 맞춰 각각 Cloud Side, Edge Side로 명시한다.
KubeEdge Cloud Side에 CloudCore를 설치하여 설정을 진행한다.

- keadm init 명령으로 Cloud Side에 CloudCore 설치를 진행한다.
```
# {CLOUD_SIDE_IP} : Cloud Side Private IP
# keadm init --advertise-address={CLOUD_SIDE_IP} --master=https://{CLOUD_SIDE_IP}:6443 --kubeedge-version 1.4.0
```

- Edge Side에 EdgeCore를 설치하기 위한 Token값을 가져온다.
```
# keadm gettoken
```

<br>

### <div id='2.7'> 2.7. KubeEdge EdgeCore 설치
KubeEdge Edge Side에 EdgeCore를 설치하여 설정을 진행한다.

- keadm join 명령으로 Edge Side에 EdgeCore 설치를 진행한다.
```
# {CLOUD_SIDE_IP} : Cloud Side Private IP
# {INTERFACE_NAME} : 실제 Edge Side에서 사용중인 인터페이스 이름 (ex: ens5)
# {GET_TOKEN} : Cloud Side에서 CloudCore 설치 이후 호출한 Token 값
# keadm join --cloudcore-ipport={CLOUD_SIDE_IP}:10000 --interfacename={INTERFACE_NAME} --token={GET_TOKEN} --kubeedge-version 1.4.0
```

<br>

### <div id='2.8'> 2.8. kubectl logs 기능 활성화
KubeEdge v1.4.0 에서는 기본적으로 kubectl logs 명령을 사용할 수 없는 이슈가 존재한다. 본 설치 가이드에서는 해당 기능을 활성화 하기 위한 설정 가이드를 제공한다.

- Cloud Side에서 kubernetes ca.crt 및 ca.key 파일을 확인한다.
```
# ls /etc/kubernetes/pki/
```

- Cloud Side에서 CLOUDCOREIPS 환경변수 설정 및 확인을 진행한다. (HA Cluster 구성 시 VIP 설정)
```
# {CLOUD_SIDE_IP} : Cloud Side Private IP
# export CLOUDCOREIPS="{CLOUD_SIDE_IP}"

# echo $CLOUDCOREIPS
```

- Cloud Side에서 certgen.sh 다운로드 및 인증서 생성을 진행한다.
```
# cd /etc/kubeedge

# wget https://raw.githubusercontent.com/kubeedge/kubeedge/master/build/tools/certgen.sh

# chmod +x certgen.sh

# /etc/kubeedge/certgen.sh stream
```

- Cloud Side에서 iptables을 설정한다.
```
# iptables -t nat -A OUTPUT -p tcp --dport 10350 -j DNAT --to $CLOUDCOREIPS:10003
```

- Cloud Side에서 cloudcore.yaml 파일을 수정한다. (enable: true 로 변경)
```
# vi /etc/kubeedge/config/cloudcore.yaml
```

```
cloudStream:
  enable: true
  streamPort: 10003
  tlsStreamCAFile: /etc/kubeedge/ca/streamCA.crt
  tlsStreamCertFile: /etc/kubeedge/certs/stream.crt
  tlsStreamPrivateKeyFile: /etc/kubeedge/certs/stream.key
  tlsTunnelCAFile: /etc/kubeedge/ca/rootCA.crt
  tlsTunnelCertFile: /etc/kubeedge/certs/server.crt
  tlsTunnelPrivateKeyFile: /etc/kubeedge/certs/server.key
  tunnelPort: 10004
```

- Edge Side에서 edgecore.yaml 파일을 수정한다. (enable: true, server: {CLOUD_SIDE_IP}:10004)
```
# vi /etc/kubeedge/config/edgecore.yaml
```

```
# {CLOUD_SIDE_IP} : Cloud Side Private IP

edgeStream:
  enable: true
  handshakeTimeout: 30
  readDeadline: 15
  server: {CLOUD_SIDE_IP}:10004
  tlsTunnelCAFile: /etc/kubeedge/ca/rootCA.crt
  tlsTunnelCertFile: /etc/kubeedge/certs/server.crt
  tlsTunnelPrivateKeyFile: /etc/kubeedge/certs/server.key
  writeDeadline: 15
```

- Cloud Side에서 cloudcore를 재시작한다.
```
# pkill cloudcore
# nohup cloudcore > cloudcore.log 2>&1 &
```

- KubeEdge는 EdgeMesh를 사용하여 통신하나 현재 NodePort를 사용할 수 없는 이슈가 확인되어 kube-proxy를 사용하여야 NodePort가 정상 동작한다.  
  kube-proxy 배포되어 있을 경우 edgecore 재시작이 불가능하므로 edgecore 재시작 시 kube-proxy 배포 여부를 우회할 수 있는 방법을 기술한다.

- edgecore.service 파일을 수정한다.
```
$ sudo vi /etc/kubeedge/edgecore.service
```

- edgecore.service 파일의 [Service]에 다음을 추가한다.
```
Environment="CHECK_EDGECORE_ENVIRONMENT=false"
```

- Edge Side에서 edgecore를 재시작한다.
```
# systemctl daemon-reload
# systemctl restart edgecore.service
```

<br>

### <div id='2.9'> 2.9. KubeEdge 설치 확인
Kubernetes Node 및 kube-system Namespace의 Pod를 확인하여 KubeEdge 설치를 확인한다.

```
$ kubectl get nodes
NAME            STATUS   ROLES        AGE   VERSION
ip-10-0-0-107   Ready    agent,edge   36m   v1.18.6-kubeedge-v1.4.0
ip-10-0-0-157   Ready    agent,edge   35m   v1.18.6-kubeedge-v1.4.0
ip-10-0-0-18    Ready    master       58m   v1.18.6
ip-10-0-0-86    Ready    agent,edge   30m   v1.18.6-kubeedge-v1.4.0

$ kubectl get pods -n kube-system
NAME                                   READY   STATUS    RESTARTS   AGE
coredns-66bff467f8-qzhd9               1/1     Running   0          58m
coredns-66bff467f8-rnmhk               1/1     Running   0          58m
etcd-ip-10-0-0-18                      1/1     Running   0          58m
kube-apiserver-ip-10-0-0-18            1/1     Running   0          58m
kube-controller-manager-ip-10-0-0-18   1/1     Running   0          58m
kube-flannel-ds-amd64-4xc69            1/1     Running   0          46m
kube-proxy-bj6c6                       1/1     Running   0          45m
kube-scheduler-ip-10-0-0-18            1/1     Running   0          58m
```

<br>

## <div id='3'> 3. Kubernates Monitoring 도구 (Metrics-server) 배포 
배포된 Resource의 CPU/Memory 사용량 등을 확인하기 위해서는 Metric-server 배포가 필요하며, 컨테이너 플랫폼 사용자포탈에서도 정상적인 운용을 위해서는 필수적으로 배포되어야 한다.  
또한 KubeEdge에서 Metrics-Server 배포 시 2.8. kubectl logs 기능 활성화 가 필수적으로 진행되어야 한다.

- Metrics-Server 배포를 위한 yaml 파일을 다운받는다.
```
$ wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.0/components.yaml
```

- components.yaml 파일을 수정한다.
```
$ vi components.yaml
```

```
# spec.template.spec 하위에 추가
# {CLOUD_SIDE_HOSTNAME} : 실제 Cloud Side Hostname

    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                - {CLOUD_SIDE_HOSTNAME}
      hostNetwork: true

# spec.template.spec.containers 하위 - args:에 추가

      containers:
      - args:
        - --v=2
        - --kubelet-insecure-tls

# spec.template.spec 하위에 추가    

      tolerations:
      - key: "node-role.kubernetes.io"
        operator: "Equal"
        value: "master"
        effect: "NoSchedule"    
```

- 노드의 Taint 설정을 해제한다.
```
$ kubectl taint nodes --all node-role.kubernetes.io/master-
node/ip-10-0-0-251 untainted
error: taint "node-role.kubernetes.io/master" not found
```

- Metrics-Server를 배포한다.
```
$ kubectl apply -f components.yaml
```

- Metrics 정보를 확인한다.
```
$ kubectl top nodes
NAME            CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
ip-10-0-0-234   83m          4%     2438Mi          31%
ip-10-0-0-97    38m          1%     2971Mi          38%

$ kubectl top pods -n kube-system
NAME                                    CPU(cores)   MEMORY(bytes)
coredns-66bff467f8-8lngp                2m           6Mi
coredns-66bff467f8-cjqzv                2m           6Mi
etcd-ip-10-0-0-234                      11m          45Mi
kube-apiserver-ip-10-0-0-234            19m          286Mi
kube-controller-manager-ip-10-0-0-234   8m           40Mi
kube-flannel-ds-amd64-tstq9             2m           9Mi
kube-proxy-7cz4b                        1m           10Mi
kube-proxy-nntnh                        1m           10Mi
kube-scheduler-ip-10-0-0-234            3m           11Mi
metrics-server-68cb9f9b79-xvkks         3m           12Mi
```

<br>

## <div id='4'> 4. KubeEdge Reset (참고)
Cloud Side, Edge Side에서 KubeEdge를 중지합니다. 필수구성요소는 삭제하지 않습니다.

- Cloud Side에서 cloudcore를 중지하고 kubeedge Namespace와 같은 Kubernetes Master에서 KubeEdge 관련 리소스를 삭제합니다.
```
# keadm reset --kube-config=$HOME/.kube/config
```

- Edge Side에서 edgecore를 중지합니다.
```
# keadm reset
```

<br>

## <div id='5'> 5. 컨테이너 플랫폼 운영자 생성 및 Token 획득 (참고)

### <div id='5.1'> 5.1. Cluster Role 운영자 생성 및 Token 획득
Kubespray 설치 이후에 Cluster Role을 가진 운영자의 Service Account를 생성한다. 해당 Service Account의 Token은 운영자 포털에서 Super Admin 계정 생성 시 이용된다.

- Service Account를 생성한다.
```
# {SERVICE_ACCOUNT} : Service Account 명
$ kubectl create serviceaccount {SERVICE_ACCOUNT} -n kube-system
(eg. kubectl create serviceaccount k8sadmin -n kube-system)
```

- Cluster Role을 생성한 Service Account에 바인딩한다.
```
$ kubectl create clusterrolebinding {SERVICE_ACCOUNT} --clusterrole=cluster-admin --serviceaccount=kube-system:{SERVICE_ACCOUNT}
```

- 생성한 Service Account의 Token을 획득한다.
```
# {SECRET_NAME} : Mountable secrets 값 확인
$ kubectl describe serviceaccount {SERVICE_ACCOUNT} -n kube-system

$ kubectl describe secret {SECRET_NAME} -n kube-system | grep -E '^token' | cut -f2 -d':' | tr -d " "
```

### <div id='5.2'> 5.2. Namespace 사용자 Token 획득
포털에서 Namespace 생성 및 사용자 등록 이후 Token값을 획득 시 이용된다.

- Namespace 사용자의 Token을 획득한다.
```
# {SECRET_NAME} : Mountable secrets 값 확인
# {NAMESPACE} : Namespace 명
$ kubectl describe serviceaccount {SERVICE_ACCOUNT} -n {NAMESPACE}

$ kubectl describe secret {SECRET_NAME} -n {NAMESPACE} | grep -E '^token' | cut -f2 -d':' | tr -d " "
```

### <div id='5.3'> 5.3. 컨테이너 플랫폼 Temp Namespace 생성
컨테이너 플랫폼 배포 시 최초 Temp Namespace 생성이 필요하다. 해당 Temp Namespace는 포털 내 사용자 계정 관리를 위해 이용된다.

- Temp Namespace를 생성한다.
```
$ kubectl create namespace paas-ta-container-platform-temp-namespace
```


<br>

## <div id='6'> 6. Resource 생성 시 주의사항
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


----
[image 001]:images/cp-001.png
