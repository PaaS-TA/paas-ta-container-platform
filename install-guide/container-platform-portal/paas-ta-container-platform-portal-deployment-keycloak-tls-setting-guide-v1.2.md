### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Install](/install-guide/Readme.md) > Keycloak TLS 설정 가이드

<br>

## Table of Contents

1. [문서 개요](#1)  
    1.1. [목적](#1.1)  
    1.2. [범위](#1.2)  
    1.3. [시스템 구성도](#1.3)  
    1.4. [참고 자료](#1.4)  

2. [Keycloak TLS 설정](#2)  
    2.1. [컨테이너 플랫폼 포털 Deployment 파일 변경](#2.1)  

<br>

## <div id='1'>1. 문서 개요
### <div id='1.1'>1.1. 목적
본 문서(컨테이너 플랫폼 단독 배포 형 포털 설치 가이드)는 Kubernetes Cluster를 설치하고 컨테이너 플랫폼 포털 배포 시 Keyclaok TLS 설정 방법을 기술하였다.
<br>

### <div id='1.2'>1.2. 범위
설치 범위는 Kubernetes Cluster 배포를 기준으로 작성하였다.

<br>

### <div id='1.3'>1.3. 시스템 구성도
<p align="center"><img src="images-v1.2/cp-001.png"></p>    

시스템 구성은 **Kubernetes Cluster(Master, Worker)** 환경과 데이터 관리를 위한 **네트워크 파일 시스템(NFS)** 스토리지 서버로 구성되어 있다. Kubespray를 통해 설치된 Kubernetes Cluster 환경에 컨테이너 플랫폼 포털 이미지 및 Helm Chart를 관리하는 **Harbor**, 컨테이너 플랫폼 포털 사용자 인증을 관리하는 **Keycloak**, 컨테이너 플랫폼 포털 메타 데이터를 관리하는 **MariaDB(RDBMS)** 등 미들웨어 환경을 컨테이너로 제공한다. 총 필요한 VM 환경으로는 **Master Node VM: 1개, Worker Node VM: 1개 이상, NFS Server : 1개**가 필요하고 본 문서는 Kubernetes Cluster에 컨테이너 플랫폼 포털 환경을 배포하는 내용이다. **네트워크 파일 시스템(NFS)** 은 컨테이너플랫폼에서 기본으로 제공하는 스토리지로 사용자 환경에 따라 다양한 종류의 스토리지를 사용할 수 있다.  

<br>    

### <div id='1.4'>1.4. 참고 자료
> https://kubernetes.io/ko/docs<br>
> https://goharbor.io/docs<br>
> https://www.keycloak.org/documentation

<br>


## <div id='2'>2. Keycloak TLS 설정
본 가이드는 컨테이너 플랫폼 포털 배포 전 설정이 진행되어야 한다.
단독형 배포 포털 설치 가이드, 서비스형 배포 포털 설치 가이드 본문의 **3.2.1. 컨테이너 플랫폼 포털 Deployment 파일 다운로드** 이후 설정 변경을 진행한다.

### <div id='2.1'>2.1. 컨테이너 플랫폼 포털 Deployment 파일 변경
컨테이너 플랫폼 포털 배포 전 TLS 인증서 파일 (ex: tls.key, tls.crt)이 사전에 준비되어야 한다.
Keycloak 관련 설정 변경 후 포털 설치 가이드의 **3.2.2. 컨테이너 플랫폼 포털 변수 정의** 과정을 진행한다.

- KeyCloak Dockerfile 내 인증서 파일 복사를 추가한다.
```
$ cd ~/workspace/container-platform/paas-ta-container-platform-portal-deployment/keycloak

$ vi Dockerfile
```

```
### TLS_FILE_PATH : TLS 인증서 파일이 위치한 Master Node 내 디렉토리 경로

...
COPY {TLS_FILE_PATH}/* /etc/x509/https/
...
```

- 컨테이너 플랫폼 포털 Keycloak 변수를 수정한다.
```
$ cd ~/workspace/container-platform/paas-ta-container-platform-portal-deployment/values

$ vi paas-ta-container-platform-keycloak-values.yaml
```

```
## Service의 targetPort를 8443으로 변경하여 https로 접속

...
service:
  type: NodePort
  protocol: TCP
  port: 8080
  https:
    port: 8443
  targetPort: 8443 (수정)
  nodePort: 32710
...
```

- 컨테이너 플랫폼 운영자 포털, 사용자 포털, 브로커 변수를 수정한다.
```
## 각 yaml 파일에 아래 url 정보를 모두 수정

$ vi paas-ta-container-platform-admin-service-broker-values.yaml
$ vi paas-ta-container-platform-user-service-broker-values.yaml
$ vi paas-ta-container-platform-webadmin-values.yaml
$ vi paas-ta-container-platform-webuser-values.yaml
```

```
## url 정보를 http > https로 수정
## DOMAIN_NAME : TLS 인증서에 적용된 Domain Name 정보로 수정

...
  keycloak:
    url: "https://{DOMAIN_NAME}" (수정)
...
```

<br>

### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Install](/install-guide/Readme.md) > Keycloak TLS 설정 가이드
