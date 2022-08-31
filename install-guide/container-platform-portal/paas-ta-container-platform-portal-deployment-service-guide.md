### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Install](/install-guide/Readme.md) > 서비스형 배포 포털 설치 가이드

<br>

## Table of Contents

1. [문서 개요](#1)  
    1.1. [목적](#1.1)  
    1.2. [범위](#1.2)  
    1.3. [시스템 구성도](#1.3)  
    1.4. [참고 자료](#1.4)  

2. [Prerequisite](#2)  
    2.1. [방화벽 정보](#2.1)  
    2.2. [NFS Server 설치](#2.2)    

3. [컨테이너 플랫폼 포털 배포](#3)  
    3.1. [컨테이너 플랫폼 포털 배포](#3.1)  
    3.1.1. [컨테이너 플랫폼 포털 Deployment 파일 다운로드](#3.1.1)  
    3.1.2. [컨테이너 플랫폼 포털 변수 정의](#3.1.2)    
    3.1.3. [컨테이너 플랫폼 포털 배포 스크립트 실행](#3.1.3)  
    3.1.4. [(참조) 컨테이너 플랫폼 포털 리소스 삭제](#3.1.4)

4. [컨테이너 플랫폼 포털 사용자 인증 서비스 구성](#4)      
    4.1. [컨테이너 플랫폼 포털 사용자 인증 구성 Deployment 다운로드](#4.1)      
    4.2. [컨테이너 플랫폼 포털 사용자 인증 구성 변수 정의](#4.2)      
    4.3. [컨테이너 플랫폼 포털 사용자 인증 구성 스크립트 실행](#4.3)          
    4.4. [(참조) 컨테이너 플랫폼 포털 사용자 인증 구성 해제](#4.4)    

5. [컨테이너 플랫폼 포털 서비스 브로커](#5)       
    5.1. [컨테이너 플랫폼 포털 서비스 브로커 등록](#5.1)  
    5.2. [컨테이너 플랫폼 포털 서비스 조회 설정](#5.2)    
    5.3. [컨테이너 플랫폼 사용자/운영자 포털 사용 가이드](#5.3)

6. [컨네이너 플랫폼 포털 참고](#6)  
    6.1. [운영자 Cluster Role Token 생성](#6.1)    
    6.2. [Kubernetes 리소스 생성 시 주의사항](#6.2)      


## <div id='1'>1. 문서 개요
### <div id='1.1'>1.1. 목적
본 문서(컨테이너 플랫폼 PaaS-TA 서비스 배포 형 포털 설치 가이드)는 Kubernetes Cluster를 설치하고 컨테이너 플랫폼 PaaS-TA 서비스 배포 형 포털 배포 방법을 기술하였다.<br>
<br>

### <div id='1.2'>1.2. 범위
설치 범위는 Kubernetes Cluster 배포를 기준으로 작성하였다.

<br>

### <div id='1.3'>1.3. 시스템 구성도
<p align="center"><img src="images/cp-001.png"></p>    

시스템 구성은 **Kubernetes Cluster(Master, Worker)** 환경과 데이터 관리를 위한 **네트워크 파일 시스템(NFS)** 스토리지 서버로 구성되어 있다. Kubespray를 통해 설치된 Kubernetes Cluster 환경에 컨테이너 플랫폼 포털 이미지 및 Helm Chart를 관리하는 **Harbor**, 컨테이너 플랫폼 포털 사용자 인증을 관리하는 **Keycloak**, 컨테이너 플랫폼 포털 메타 데이터를 관리하는 **MariaDB(RDBMS)** 등 미들웨어 환경을 컨테이너로 제공한다. 총 필요한 VM 환경으로는 **Master Node VM: 1개, Worker Node VM: 1개 이상, NFS Server : 1개**가 필요하고 본 문서는 Kubernetes Cluster에 컨테이너 플랫폼 포털 환경을 배포하는 내용이다. **네트워크 파일 시스템(NFS)** 은 컨테이너플랫폼에서 기본으로 제공하는 스토리지로 사용자 환경에 따라 다양한 종류의 스토리지를 사용할 수 있다.  

<br>    

### <div id='1.4'>1.4. 참고 자료
> https://kubernetes.io/ko/docs<br>
> https://goharbor.io/docs<br>
> https://www.keycloak.org/documentation

<br>

## <div id='2'>2. Prerequisite
본 설치 가이드는 **Ubuntu 18.04** 환경에서 설치하는 것을 기준으로 작성하였다.

### <div id='2.1'>2.1. 방화벽 정보
IaaS Security Group의 열어줘야할 Port를 설정한다.

- Master Node

| <center>프로토콜</center> | <center>포트</center> | <center>비고</center> |  
| :---: | :---: | :--- |  
| TCP | 111 | NFS PortMapper |  
| TCP | 179 | Calio BGP Network |  
| TCP | 2049 | NFS |  
| TCP | 2379-2380 | etcd server client API |  
| TCP | 6443 | Kubernetes API Server |  
| TCP | 10250 | Kubelet API |  
| TCP | 10251 | kube-scheduler |  
| TCP | 10252 | kube-controller-manager |  
| TCP | 10255 | Read-Only Kubelet API |  
| IP-in-IP (Protocol Num 4) || Calico Overlay Network |  

- Worker Node

| <center>프로토콜</center> | <center>포트</center> | <center>비고</center> |  
| :---: | :---: | :--- |  
| TCP | 111 | NFS PortMapper |  
| TCP | 179 | Calio BGP network |  
| TCP | 2049 | NFS |  
| TCP | 10250 | Kubelet API |  
| TCP | 10255 | Read-Only Kubelet API |  
| TCP | 30000-32767 | NodePort Services |  
| IP-in-IP (Protocol Num 4) || Calico Overlay Network |  

<br>

### <div id='2.2'>2.2. NFS Server 설치
컨테이너 플랫폼 포털 서비스에서 사용할 스토리지 **NFS Storage Server** 설치가 사전에 진행되어야 한다.<br>
NFS Storage Server 설치는 아래 가이드를 참조한다.  
> [NFS Server 설치](../nfs-server-install-guide.md)      

<br>

## <div id='3'>3. 컨테이너 플랫폼 포털 배포
### <div id='3.1'>3.1. 컨테이너 플랫폼 포털 배포

#### <div id='3.1.1'>3.1.1. 컨테이너 플랫폼 포털 Deployment 파일 다운로드
컨테이너 플랫폼 포털 배포를 위해 컨테이너 플랫폼 포털 Deployment 파일을 다운로드 받아 아래 경로로 위치시킨다.<br>
:bulb: 해당 내용은 Kubernetes **Master Node**에서 진행한다.

+ 컨테이너 플랫폼 포털 Deployment 파일 다운로드 :
   [paas-ta-container-platform-portal-deployment_v1.2.3.tar.gz](https://nextcloud.paas-ta.org/index.php/s/2WxffSnLTp4eLxL/download)

```
# Deployment 파일 다운로드 경로 생성
$ mkdir -p ~/workspace/container-platform
$ cd ~/workspace/container-platform

# Deployment 파일 다운로드 및 파일 경로 확인
$ wget --content-disposition https://nextcloud.paas-ta.org/index.php/s/2WxffSnLTp4eLxL/download

$ ls ~/workspace/container-platform
  paas-ta-container-platform-portal-deployment_v1.2.3.tar.gz

# Deployment 파일 압축 해제
$ tar -xvf paas-ta-container-platform-portal-deployment_v1.2.3.tar.gz
```

- Deployment 파일 디렉토리 구성
```
├── script          # 컨테이너 플랫폼 포털 배포 관련 변수 및 스크립트 파일 위치
├── images          # 컨테이너 플랫폼 포털 이미지 파일 위치
├── charts          # 컨테이너 플랫폼 포털 Helm Charts 파일 위치
├── values_orig     # 컨테이너 플랫폼 포털 Helm Charts values.yaml 파일 위치
└── keycloak_orig   # 컨테이너 플랫폼 포털 사용자 인증 관리를 위한 Keycloak 배포 관련 파일 위치
```

<br>

#### <div id='3.1.2'>3.1.2. 컨테이너 플랫폼 포털 변수 정의
컨테이너 플랫폼 포털을 배포하기 전 변수 값 정의가 필요하다. 배포에 필요한 정보를 확인하여 변수를 설정한다.

:bulb: Keycloak 기본 배포 방식은 **HTTP**이며 인증서를 통한 **HTTPS**를 설정하고자 하는 경우 아래 가이드를 참조하여 선처리한다.
> [Keycloak TLS 설정](paas-ta-container-platform-portal-deployment-keycloak-tls-setting-guide.md#2-keycloak-tls-설정)       

<br>

```
$ cd ~/workspace/container-platform/cp-portal-deployment/script
$ vi cp-portal-vars.sh
```

```                                                     
# COMMON VARIABLE
K8S_MASTER_NODE_IP="{k8s master node public ip}"             # Kubernetes Master Node Public IP
K8S_AUTH_BEARER_TOKEN="{k8s auth bearer token}"              # Kubernetes Authorization Bearer Token
NFS_SERVER_IP="{nfs server ip}"                              # NFS Server IP
PROVIDER_TYPE="{container platform portal provider type}"    # Container Platform Portal Provider Type (Please enter 'standalone' or 'service')
....    
```
```    
# Example
K8S_MASTER_NODE_IP="xx.xxx.xxx.xx"                 
K8S_AUTH_BEARER_TOKEN="qY3k2xaZpNbw3AJxxxxx...."                 
NFS_SERVER_IP="xx.xxx.xxx.xx"                                  
PROVIDER_TYPE="service"           
```

- **K8S_MASTER_NODE_IP** <br>Kubernetes Master Node Public IP 입력<br><br>
- **K8S_AUTH_BEARER_TOKEN** <br>Kubernetes Bearer Token 입력<br>
   + [[6.1. 운영자 Cluster Role Token 생성]](#6.1) 참고하여 Token 값 생성 후 입력<br><br>
- **NFS_SERVER_IP** <br>NFS Server Private IP 입력<br>
   + 가이드 [[NFS Server 설치](../nfs-server-install-guide.md)]를 통해 설치된 NFS Server Private IP 입력<br><br>
- **PROVIDER_TYPE** <br>컨테이너 플랫폼 포털 제공 타입 입력 <br>
   + 본 가이드는 포털 PaaS-TA 서비스 형 배포 설치 가이드로 **'service'** 값 입력 필요

<br>    

#### <div id='3.1.3'>3.1.3. 컨테이너 플랫폼 포털 배포 스크립트 실행
컨테이너 플랫폼 포털 배포를 위한 배포 스크립트를 실행한다.

```
$ chmod +x deploy-cp-portal.sh
$ ./deploy-cp-portal.sh
```
<br>

컨테이너 플랫폼 포털 관련 리소스가 정상적으로 배포되었는지 확인한다.<br>
리소스 Pod의 경우 Node에 바인딩 및 컨테이너 생성 후 Running 상태로 전환되기까지 몇 초가 소요된다.

- **NFS 리소스 조회**
>`$ kubectl get all -n nfs-storageclass`  
```
$ kubectl get all -n nfs-storageclass
NAME                                       READY   STATUS    RESTARTS   AGE
pod/nfs-pod-provisioner-7f9cb9468d-rqzxc   1/1     Running   0          3m14s

NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nfs-pod-provisioner   1/1     1            1           3m14s

NAME                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/nfs-pod-provisioner-7f9cb9468d   1         1         1       3m14s
```

- **Harbor 리소스 조회**
>`$ kubectl get all -n harbor`   
```
$ kubectl get all -n harbor
NAME                                           READY   STATUS    RESTARTS   AGE
pod/cp-harbor-chartmuseum-65b54f7469-9d6js     1/1     Running   0          3m31s
pod/cp-harbor-core-5bcd965dd7-4f99l            1/1     Running   0          3m31s
pod/cp-harbor-database-0                       1/1     Running   0          3m31s
pod/cp-harbor-jobservice-66c49bd956-xcnxq      1/1     Running   0          3m31s
pod/cp-harbor-nginx-9bf76d997-2h5rm            1/1     Running   0          3m31s
pod/cp-harbor-notary-server-68c5f9bb87-t7ltq   1/1     Running   0          3m31s
pod/cp-harbor-notary-signer-65ccdf7b85-d5jxv   1/1     Running   0          3m31s
pod/cp-harbor-portal-69775f785f-ljbjz          1/1     Running   0          3m31s
pod/cp-harbor-redis-0                          1/1     Running   0          3m31s
pod/cp-harbor-registry-775d9b7dcf-xpbt7        2/2     Running   0          3m31s
pod/cp-harbor-trivy-0                          1/1     Running   0          3m31s

NAME                              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                       AGE
service/cp-harbor-chartmuseum     ClusterIP   10.233.61.185   <none>        80/TCP                        3m31s
service/cp-harbor-core            ClusterIP   10.233.63.107   <none>        80/TCP                        3m31s
service/cp-harbor-database        ClusterIP   10.233.10.172   <none>        5432/TCP                      3m31s
service/cp-harbor-jobservice      ClusterIP   10.233.46.225   <none>        80/TCP                        3m31s
service/cp-harbor-notary-server   ClusterIP   10.233.41.132   <none>        4443/TCP                      3m31s
service/cp-harbor-notary-signer   ClusterIP   10.233.51.119   <none>        7899/TCP                      3m31s
service/cp-harbor-portal          ClusterIP   10.233.60.132   <none>        80/TCP                        3m31s
service/cp-harbor-redis           ClusterIP   10.233.4.71     <none>        6379/TCP                      3m31s
service/cp-harbor-registry        ClusterIP   10.233.54.92    <none>        5000/TCP,8080/TCP             3m31s
service/cp-harbor-trivy           ClusterIP   10.233.39.198   <none>        8080/TCP                      3m31s
service/harbor                    NodePort    10.233.36.25    <none>        80:30002/TCP,4443:30004/TCP   3m31s

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cp-harbor-chartmuseum     1/1     1            1           3m31s
deployment.apps/cp-harbor-core            1/1     1            1           3m31s
deployment.apps/cp-harbor-jobservice      1/1     1            1           3m31s
deployment.apps/cp-harbor-nginx           1/1     1            1           3m31s
deployment.apps/cp-harbor-notary-server   1/1     1            1           3m31s
deployment.apps/cp-harbor-notary-signer   1/1     1            1           3m31s
deployment.apps/cp-harbor-portal          1/1     1            1           3m31s
deployment.apps/cp-harbor-registry        1/1     1            1           3m31s

NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/cp-harbor-chartmuseum-65b54f7469     1         1         1       3m31s
replicaset.apps/cp-harbor-core-5bcd965dd7            1         1         1       3m31s
replicaset.apps/cp-harbor-jobservice-66c49bd956      1         1         1       3m31s
replicaset.apps/cp-harbor-nginx-9bf76d997            1         1         1       3m31s
replicaset.apps/cp-harbor-notary-server-68c5f9bb87   1         1         1       3m31s
replicaset.apps/cp-harbor-notary-signer-65ccdf7b85   1         1         1       3m31s
replicaset.apps/cp-harbor-portal-69775f785f          1         1         1       3m31s
replicaset.apps/cp-harbor-registry-775d9b7dcf        1         1         1       3m31s

NAME                                  READY   AGE
statefulset.apps/cp-harbor-database   1/1     3m31s
statefulset.apps/cp-harbor-redis      1/1     3m31s
statefulset.apps/cp-harbor-trivy      1/1     3m31s
```

- **MariaDB 리소스 조회**
>`$ kubectl get all -n mariadb`  
```
$ kubectl get all -n mariadb
NAME               READY   STATUS    RESTARTS   AGE
pod/cp-mariadb-0   1/1     Running   0          4m29s

NAME                 TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
service/cp-mariadb   NodePort   10.233.58.86   <none>        3306:31306/TCP   4m29s

NAME                          READY   AGE
statefulset.apps/cp-mariadb   1/1     4m29s
```    

- **Keycloak 리소스 조회**
>`$ kubectl get all -n keycloak`  
```
$ kubectl get all -n keycloak
NAME                               READY   STATUS    RESTARTS   AGE
pod/cp-keycloak-6cb7f5c8cb-qqv5s   1/1     Running   0          4m49s
pod/cp-keycloak-6cb7f5c8cb-w65zr   1/1     Running   0          4m49s

NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/cp-keycloak           NodePort    10.233.26.250   <none>        8080:32710/TCP   4m49s
service/cp-keycloak-cluster   ClusterIP   None            <none>        8080/TCP         4m49s

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cp-keycloak   2/2     2            2           4m49s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/cp-keycloak-6cb7f5c8cb   2         2         2       4m49s
```

- **컨테이너 플랫폼 포털 리소스 조회**
>`$ kubectl get all -n cp-portal`   
```
$ kubectl get all -n cp-portal
NAME                                                             READY   STATUS    RESTARTS   AGE
pod/cp-portal-admin-service-broker-deployment-59844fc678-x4hwb   1/1     Running   0          5m56s
pod/cp-portal-api-deployment-859d5d5bb4-4w4gf                    1/1     Running   0          5m57s
pod/cp-portal-common-api-deployment-54c6785587-cq8xx             1/1     Running   0          5m57s
pod/cp-portal-user-service-broker-deployment-5bc6fb785-2p9g5     1/1     Running   0          5m56s
pod/cp-portal-webadmin-deployment-5d67485c6b-6ppp4               1/1     Running   0          5m58s
pod/cp-portal-webuser-deployment-96b5698f7-jfdps                 1/1     Running   0          5m57s

NAME                                             TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/cp-portal-admin-service-broker-service   NodePort   10.233.52.221   <none>        3330:32704/TCP   5m56s
service/cp-portal-api-service                    NodePort   10.233.32.119   <none>        3333:32701/TCP   5m57s
service/cp-portal-common-api-service             NodePort   10.233.49.181   <none>        3334:32700/TCP   5m57s
service/cp-portal-user-service-broker-service    NodePort   10.233.18.191   <none>        3331:32705/TCP   5m56s
service/cp-portal-webadmin-service               NodePort   10.233.45.232   <none>        8090:32703/TCP   5m58s
service/cp-portal-webuser-service                NodePort   10.233.38.66    <none>        8091:32702/TCP   5m57s

NAME                                                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cp-portal-admin-service-broker-deployment   1/1     1            1           5m56s
deployment.apps/cp-portal-api-deployment                    1/1     1            1           5m57s
deployment.apps/cp-portal-common-api-deployment             1/1     1            1           5m57s
deployment.apps/cp-portal-user-service-broker-deployment    1/1     1            1           5m56s
deployment.apps/cp-portal-webadmin-deployment               1/1     1            1           5m58s
deployment.apps/cp-portal-webuser-deployment                1/1     1            1           5m57s

NAME                                                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/cp-portal-admin-service-broker-deployment-59844fc678   1         1         1       5m56s
replicaset.apps/cp-portal-api-deployment-859d5d5bb4                    1         1         1       5m57s
replicaset.apps/cp-portal-common-api-deployment-54c6785587             1         1         1       5m57s
replicaset.apps/cp-portal-user-service-broker-deployment-5bc6fb785     1         1         1       5m56s
replicaset.apps/cp-portal-webadmin-deployment-5d67485c6b               1         1         1       5m58s
replicaset.apps/cp-portal-webuser-deployment-96b5698f7                 1         1         1       5m57s
```    

<br>

#### <div id='3.1.4'>3.1.4. (참조) 컨테이너 플랫폼 포털 리소스 삭제
배포된 컨테이너 플랫폼 포털 리소스의 삭제를 원하는 경우 아래 스크립트를 실행한다.<br>
:loudspeaker: (주의) 컨테이너 플랫폼 포털이 운영되는 상태에서 해당 스크립트 실행 시, **운영에 필요한 리소스가 모두 삭제**되므로 주의가 필요하다.<br>

```
$ cd ~/workspace/container-platform/cp-portal-deployment/script
$ chmod +x uninstall-cp-portal.sh
$ ./uninstall-cp-portal.sh
```
```    
Are you sure you want to delete the container platform portal? <y/n> y
release "cp-nfs-storageclass" uninstalled
namespace "nfs-storageclass" deleted
.... 
release "cp-harbor" uninstalled
namespace "harbor" deleted
release "cp-mariadb" uninstalled
namespace "mariadb" deleted
release "cp-keycloak" uninstalled
namespace "keycloak" deleted
release "cp-portal-admin-service-broker" uninstalled
release "cp-portal-api" uninstalled
release "cp-portal-common-api" uninstalled
release "cp-portal-configmap" uninstalled
release "cp-portal-user-service-broker" uninstalled
release "cp-portal-webadmin" uninstalled
release "cp-portal-webuser" uninstalled
namespace "cp-portal" deleted
"cp-portal-repository" has been removed from your repositories
Uninstalled plugin: cm-push
.... 
```

<br>   

## <div id='4'>4. 컨테이너 플랫폼 포털 사용자 인증 서비스 구성
컨테이너 플랫폼 포털 사용자 인증은 Keycloak 서비스를 통해 관리된다. PaaS-TA 포털의 사용자 인증 서비스 UAA의 사용자 계정으로 컨테이너 플랫폼 포털 접속을 위해
UAA 서비스를 ID 제공자(Identity Provider)로, Keycloak 서비스를 서비스 제공자(Service Provider)로 구성하는 단계가 필요하다.

#### <div id='4.1'>4.1. 컨테이너 플랫폼 포털 사용자 인증 구성 Deployment 다운로드
UAA 서비스와 Keycloak 서비스 인증 구성을 위한 Deployment 파일을 다운로드 받아 아래 경로로 위치시킨다.<br>
:bulb: 해당 내용은 PaaS-TA 포털이 설치된 **BOSH Inception**에서 진행한다.

+ 컨테이너 플랫폼 포털 사용자 인증 구성 Deployment 다운로드 :  
   [paas-ta-container-platform-saml-deployment_v1.2.3.tar.gz](https://nextcloud.paas-ta.org/index.php/s/Q25F4g7wZiTZG4E/download)  

```
# Deployment 파일 다운로드 경로 생성
$ mkdir -p ~/workspace/container-platform
$ cd ~/workspace/container-platform

# Deployment 파일 다운로드 및 파일 경로 확인
$ wget --content-disposition https://nextcloud.paas-ta.org/index.php/s/Q25F4g7wZiTZG4E/download

$ ls ~/workspace/container-platform
  paas-ta-container-platform-saml-deployment_v1.2.3.tar.gz

# Deployment 파일 압축 해제
$ tar -xvf paas-ta-container-platform-saml-deployment_v1.2.3.tar.gz
```
<br>

#### <div id='4.2'>4.2. 컨테이너 플랫폼 포털 사용자 인증 구성 변수 정의
UAA 서비스와 Keycloak 서비스 인증 구성을 위한 변수 값 정의가 필요하다. 구성에 필요한 정보를 확인하여 변수를 설정한다.

:bulb: **Keycloak TLS HTTPS** 설정이 적용된 경우, Keycloak URL 변수 값 변경이 필요하다. <br>
아래 가이드를 참조하여 변수 값을 변경한다.
> [(서비스형 배포) 사용자 인증 서비스 구성 변경](paas-ta-container-platform-portal-deployment-keycloak-tls-setting-guide.md#3-서비스형-배포-사용자-인증-서비스-구성-변경)       

<br>

```
$ cd ~/workspace/container-platform/cp-saml-deployment
$ vi cp-saml-vars.sh
```

```                                                     
# COMMON VARIABLE
PAASTA_SYSTEM_DOMAIN="xx.xxx.xx.xxx.nip.io"                       # PaaS-TA System Domain
K8S_MASTER_NODE_IP="xx.xxx.xx.xxx"                                # Kubernetes Master Node Public IP
UAA_CLIENT_ADMIN_ID="admin"                                       # UAA Admin Client ID (e.g. admin)
UAA_CLIENT_ADMIN_SECRET="admin-secret"                            # UAA Admin Client Secret (e.g. admin-secret)
....    
```


- **PAASTA_SYSTEM_DOMAIN** <br> PaaS-TA 배포 시 지정했던 System Domain 명 입력<br><br>
- **K8S_MASTER_NODE_IP** <br>Kubernetes Master Node Public IP 입력<br><br>
- **UAA_CLIENT_ADMIN_ID** <br>UAAC Admin Client Admin ID 입력 (기본 값 : admin)<br><br>
- **UAA_CLIENT_ADMIN_SECRET** <br>UAAC Admin Client에 접근하기 위한 Secret 변수 (기본 값 : admin-secret)<br><br>

<br>

#### <div id='4.3'>4.3. 컨테이너 플랫폼 포털 사용자 인증 구성 스크립트 실행
UAA 서비스와 Keycloak 서비스 인증 구성을 위한 스크립트를 실행한다.

```
$ chmod +x create-service-provider.sh
$ ./create-service-provider.sh
```

<br>

구성이 정상적으로 처리되었는지 확인한다. (**RESPONSE BODY 내 결과 확인**)
- UAAC Service Providers 조회   
>`$ uaac curl /saml/service-providers --insecure`     
```    
$ uaac curl /saml/service-providers --insecure
GET https://uaa.xx.xxx.xxx.xx.nip.io/saml/service-providers

200 OK
RESPONSE HEADERS:
  Cache-Control: no-cache, no-store, max-age=0, must-revalidate
  Content-Type: application/json
....   
RESPONSE BODY:
[
  {
    "config": "{\"metaDataLocation\": .... }",
    "id": "c86dd09a-2d47-4005-943d-a4fc717efd0e",
    "entityId": "http://xx.xxx.xxx.xx:32710/auth/realms/cp-realm",
    "name": "cp-saml-sp",
    "version": 0,
    "created": 1651815898042,
    "lastModified": 1651815898042,
    "active": true,
    "identityZoneId": "uaa"
  }
]
```    

<br>

#### <div id='4.4'>4.4. (참조) 컨테이너 플랫폼 포털 사용자 인증 구성 해제
UAA 서비스와 Keycloak 서비스 인증 구성 해제를 원하는 경우 아래 스크립트를 실행한다.<br>
:loudspeaker: (주의) 컨테이너 플랫폼 포털이 운영되는 상태에서 해당 스크립트 실행 시, 사용자 인증 구성이 불가하므로 주의가 필요하다.<br>


##### 해제할 Service Provider ID 조회
UAAC Service Providers 조회 후 **RESPONSE BODY** 결과 내 아래 조건을 가진 **Service Provider ID**를 조회한다.
- `entityId : http://{K8S_MASTER_NODE_IP}:32710/auth/realms/cp-realm` <br>
- `name : cp-saml-sp` <br>

```  
$ uaac curl /saml/service-providers --insecure

....
RESPONSE BODY:
[
  {
    "config": "{\"metaDataLocation\": .... }",
    "id": "c86dd09a-2d47-4005-943d-a4fc717efd0e",   # 해제할 Service Provider ID
    "entityId": "http://xx.xxx.xxx.xx:32710/auth/realms/cp-realm",
    "name": "cp-saml-sp",
    "version": 0,
    "created": 1651815898042,
    "lastModified": 1651815898042,
    "active": true,
    "identityZoneId": "uaa"
  }
....    
]
```    

<br>

해제할 **Service Provider ID** 조회 후 인증 구성 해제 스크립트를 실행한다.

```
$ cd ~/workspace/container-platform/cp-saml-deployment
$ chmod +x uninstall-service-provider.sh
$ ./uninstall-service-provider.sh {Service_Provider_ID}
```

```    
$ ./uninstall-service-provider.sh c86dd09a-2d47-4005-943d-a4fc717efd0e
....  
Are you sure you want to delete this service provider? <y/n> y
DELETE https://uaa.xx.xxx.xxx.xx.nip.io/saml/service-providers/c86dd09a-2d47-4005-943d-a4fc717efd0e
....    
```

<br>

## <div id='5'>5. 컨테이너 플랫폼 포털 서비스 브로커
컨테이너 플랫폼 PaaS-TA 서비스 형 포털로 설치하는 경우 CF와 Kubernetes에 배포된 컨테이너 플랫폼 포털 서비스 연동을 위해서 브로커를 등록해 주어야 한다.
PaaS-TA 운영자 포털을 통해 서비스를 등록하고 공개하면, PaaS-TA 사용자 포털을 통해 서비스를 신청하여 사용할 수 있다.

### <div id='5.1'>5.1. 컨테이너 플랫폼 포털 서비스 브로커 등록
서비스 브로커 등록 시 개방형 클라우드 플랫폼에서 서비스 브로커를 등록할 수 있는 사용자로 로그인이 되어있어야 한다.

##### 서비스 브로커 목록을 확인한다.
>`$ cf service-brokers`
```
$ cf service-brokers
Getting service brokers as admin...
No service brokers found
```


##### 컨테이너 플랫폼 포털 서비스 브로커를 등록한다.
>`$ cf create-service-broker {서비스팩 이름} {서비스팩 사용자ID} {서비스팩 사용자비밀번호} http://{서비스팩 URL}`

서비스팩 이름 : 서비스 팩 관리를 위해 개방형 클라우드 플랫폼에서 보여지는 명칭<br>
서비스팩 사용자 ID/비밀번호 : 서비스팩에 접근할 수 있는 사용자 ID/비밀번호<br>
서비스팩 URL : 서비스팩이 제공하는 API를 사용할 수 있는 URL<br>


###### 컨테이너 플랫폼 운영자 포털 서비스 브로커 등록
>`$ cf create-service-broker cp-portal-admin-service-broker admin cloudfoundry http://{K8S_MASTER_NODE_IP}:32704`   
###### 컨테이너 플랫폼 사용자 포털 서비스 브로커 등록     
>`$ cf create-service-broker cp-portal-user-service-broker admin cloudfoundry http://{K8S_MASTER_NODE_IP}:32705`

```
$ cf create-service-broker cp-portal-admin-service-broker admin cloudfoundry http://xx.xxx.xxx.xx:32704
Creating service broker cp-portal-admin-service-broker as admin...
OK

$ cf create-service-broker cp-portal-user-service-broker admin cloudfoundry http://xx.xxx.xxx.xx:32705
Creating service broker cp-portal-user-service-broker as admin...
OK
```    


##### 등록된 컨테이너 플랫폼 포털 서비스 브로커를 확인한다.
>`$ cf service-brokers`
```
$ cf service-brokers
Getting service brokers as admin...
name                             url
cp-portal-admin-service-broker   http://xx.xxx.xxx.xx:32704
cp-portal-user-service-broker    http://xx.xxx.xxx.xx:32705
```

##### 특정 조직에 해당 서비스 접근 허용을 할당한다.

###### 컨테이너 플랫폼 운영자 포털 서비스 접근 허용 할당  
>`$ cf enable-service-access cp-portal-admin-service-broker`   
###### 컨테이너 플랫폼 사용자 포털 서비스 접근 허용 할당     
>`$ cf enable-service-access cp-portal-user-service-broker`

```
$ cf enable-service-access cp-portal-admin-service-broker
Enabling access to all plans of service offering cp-portal-admin-service-broker for all orgs as admin...
OK

$ cf enable-service-access cp-portal-user-service-broker
Enabling access to all plans of service offering cp-portal-user-service-broker for all orgs as admin...
OK
```


##### 접근 가능한 서비스 목록을 확인한다.
>`$ cf service-access`

```
$ cf service-access
Getting service access as admin...

broker: cp-portal-admin-service-broker
   offering                         plan       access   orgs
   cp-portal-admin-service-broker   Advenced   all

broker: cp-portal-user-service-broker
   offering                        plan       access   orgs
   cp-portal-user-service-broker   Advenced   all
   cp-portal-user-service-broker   Micro      all
   cp-portal-user-service-broker   Small      all
```

<br>

### <div id='5.2'>5.2. 컨테이너 플랫폼 포털 서비스 조회 설정
해당 설정은 PaaS-TA 포털에서 컨테이너 플랫폼 포털 서비스를 조회하고 신청할 수 있도록 하기 위한 설정이다.

##### PaaS-TA 운영자 포털에 접속한다.
![image 007]


##### 메뉴 [운영관리]-[카탈로그] 에서 앱서비스 탭 안에 Container Platform Admin Portal, Container Platform User Portal 서비스를 선택하여 설정을 변경한다.
![image 008]

##### Container Platform Admin Portal 서비스를 선택하여 아래와 같이 설정 변경 후 저장한다.
>`'서비스' 항목 : 'cp-portal-admin-service-broker' 로 선택` <br>
>`'공개' 항목 : 'Y' 로 체크`

![image 009]

##### Container Platform User Portal 서비스를 선택하여 아래와 같이 설정 변경 후 저장한다.
>`'서비스' 항목 : 'cp-portal-user-service-broker' 로 선택` <br>
>`'공개' 항목 : 'Y' 로 체크`

![image 010]    

<br>

#### :bulb: 컨테이너 플랫폼 운영자 포털 서비스 신청 시 유의사항
- 컨테이너 플랫폼 운영자 포털 서비스의 경우 조직명 **'portal'** 조직에서만 신청 가능하다.
- 컨테이너 플랫폼 운영자 포털 서비스는 전체 조직 내 한 조직에서만 신청 가능하며 이는 PaaS-TA Portal 배포 시 디폴트로 생성되는 조직 **'portal'** 로 지정하였다.
- 서비스 신청 시 조직 **'portal'** 이 없는 경우 **'portal'** 명으로 조직 생성 후 서비스 신청이 필요하다.

<br>

>`컨테이너 플랫폼 운영자 포털 서비스 신청 시 조직 명 'portal' 확인 후 신청 필요`     

![image 011]       

<br>

### <div id='5.3'/>5.3. 컨테이너 플랫폼 사용자/운영자 포털 사용 가이드
- 컨테이너 플랫폼 포털 사용방법은 아래 사용가이드를 참고한다.  
  + [컨테이너 플랫폼 운영자 포털 사용 가이드](../../use-guide/portal/container-platform-admin-portal-guide.md)    
  + [컨테이너 플랫폼 사용자 포털 사용 가이드](../../use-guide/portal/container-platform-user-portal-guide.md)


<br>

## <div id='6'>6. 컨네이너 플랫폼 포털 참고

### <div id='6.1'>6.1. 운영자 Cluster Role Token 생성
Cluster Role을 가진 운영자의 Service Account를 생성하고 해당 Service Account의 Token 값을 획득한다.<br>
획득한 Token 값은 컨테이너 플랫폼 포털 배포 시 사용된다.

- Service Account를 생성한다.
```
## {SERVICE_ACCOUNT} : 생성할 Service Account 명

$ kubectl create serviceaccount {SERVICE_ACCOUNT} -n kube-system
(ex. kubectl create serviceaccount k8sadmin -n kube-system)
```

- 생성한 Service Account와 kubernetes에서 제공하는 ClusterRole 'cluster-admin'을 바인딩한다.
```
$ kubectl create clusterrolebinding {SERVICE_ACCOUNT} --clusterrole=cluster-admin --serviceaccount=kube-system:{SERVICE_ACCOUNT}
(ex. kubectl create clusterrolebinding k8sadmin --clusterrole=cluster-admin --serviceaccount=kube-system:k8sadmin)
```

- Service Account의 Mountable secrets 값을 확인한다.
```
$ kubectl describe serviceaccount {SERVICE_ACCOUNT} -n kube-system
(ex. kubectl describe serviceaccount k8sadmin -n kube-system)

...

Mountable secrets:   k8sadmin-token-xxxx
```

- Service Account의 Token을 획득한다.

```
## {SECRET_NAME} : Mountable secrets 값 입력

$ kubectl describe secret {SECRET_NAME} -n kube-system | grep -E '^token' | cut -f2 -d':' | tr -d " "
```

<br>

### <div id='6.2'>6.2. Kubernetes 리소스 생성 시 주의사항

컨테이너 플랫폼 이용 중 리소스 생성 시 다음과 같은 prefix를 사용하지 않도록 주의한다.

|Resource 명|생성 시 제외해야 할 prefix|
|---|---|
|전체 Resource|kube*|
|Namespace|all|
||kubernetes-dashboard|
||cp-portal-temp-namespace|
|Role|cp-init-role|
||cp-admin-role|
|ResourceQuota|cp-low-resourcequota|
||cp-medium-resourcequota|
||cp-high-resourcequota|
|LimitRanges|cp-low-limitrange|
||cp-medium-limitrange|
||cp-high-limitrange|
|Pod|nodes|
||resources|

<br>

### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Install](/install-guide/Readme.md) > 서비스형 배포 포털 설치 가이드

[image 001]:images/cp-001.png
[image 002]:images/cp-002.png
[image 003]:images/cp-003.png
[image 004]:images/cp-004.png
[image 005]:images/cp-005.png
[image 006]:images/cp-006.png
[image 007]:images/cp-007.png
[image 008]:images/cp-008.png
[image 009]:images/cp-009.png
[image 010]:images/cp-010.png
[image 011]:images/cp-011.png