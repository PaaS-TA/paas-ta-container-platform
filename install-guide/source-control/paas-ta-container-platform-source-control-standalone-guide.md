### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Install](https://github.com/PaaS-TA/paas-ta-container-platform/tree/master/install-guide/Readme.md) > SourceControl 설치 가이드

<br>

## Table of Contents

1. [문서 개요](#1)  
    1.1. [목적](#1.1)  
    1.2. [범위](#1.2)  
    1.3. [시스템 구성도](#1.3)  
    1.4. [참고 자료](#1.4)  

2. [Prerequisite](#2)  
    2.1. [NFS 서버 설치](#2.1)  
    2.2. [컨테이너 플랫폼 포탈 설치](#2.2)  
        
3. [컨테이너 플랫폼 소스 컨트롤 배포](#3)  
    3.1. [컨테이너 플랫폼 소스 컨트롤 Deployment 파일 다운로드](#3.1)  
    3.2. [컨테이너 플랫폼 소스 컨트롤 변수 정의](#3.2)    
    3.3. [컨테이너 플랫폼 소스 컨트롤 배포 스크립트 실행](#3.3)    
    3.4. [(참조) 컨테이너 플랫폼 소스 컨트롤 리소스 삭제](#3.4)    

4. [컨테이너 플랫폼 소스 컨트롤 접속](#4)      
    4.1. [컨테이너 플랫폼 소스 컨트롤 관리자 로그인](#4.1)      
    4.2. [컨테이너 플랫폼 소스 컨트롤 사용자 회원가입/로그인](#4.2)  
    4.3. [컨테이너 플랫폼 소스 컨트롤 사용 가이드](#4.3)           



## <div id='1'>1. 문서 개요
### <div id='1.1'>1.1. 목적
본 문서(컨테이너 플랫폼 소스 컨트롤 단독 배포 설치 가이드)는 단독배포된 Kubernetes Cluster 환경에서 컨테이너 플랫폼 포탈이 배포된 환경에서 소스 컨트롤 단독 배포 방법을 기술하였다.<br>

<br>

### <div id='1.2'>1.2. 범위
설치 범위는 Kubernetes 단독 배포를 기준으로 작성하였다.

<br>

### <div id='1.3'>1.3. 시스템 구성도
시스템 구성은 Kubernetes Cluster(Master, Worker)와 Cluster 내부(DBMS, HAProxy, Private Repository, Keycloak)환경으로 구성되어 있다. <br>
Kubespray를 통해 Kubernetes Cluster를 설치하고 컨테이너 플랫폼 포탈 로 Database, Private Repository 등 미들웨어 환경을 제공하여 Docker Image로 Kubernetes Cluster에 컨테이너 플랫폼 포탈 환경을 배포한다. <br>
총 필요한 VM 환경으로는 **Master Node VM**: 1개, Worker Node VM: 1개 이상 필요하고 본 문서는 Kubernetes Cluster에 컨테이너 플랫폼 소스 컨트롤을 배포하는 내용이다.

![image](https://user-images.githubusercontent.com/80228983/146350860-3722c081-7338-438d-b7ec-1fdac09160c4.png)

    
<br>    

### <div id='1.4'>1.4. 참고 자료
> https://kubernetes.io/ko/docs  

<br>

## <div id='2'>2. Prerequisite
    
### <div id='2.1'>2.1. NFS 서버 설치
컨테이너 플랫폼 소스 컨트롤에서 사용할 스토리지 **NFS Storage Server** 설치가 사전에 진행되어야 한다.<br>
NFS Storage Server 설치는 아래 가이드를 참조한다.  
> [NFS 서버 설치](../nfs-server-install-guide.md)      
    
### <div id='2.2'>2.2. 컨테이너 플랫폼 포탈 설치
컨테이너 플랫폼 소스 컨트롤에서 사용할 인프라로 인증서버 **KeyCloak Server**, 데이터베이스 **Maria DB**, 레포지토리 서버 **Harbor** 설치가 사전에 진행되어야 한다.
파스타 컨테이너 플랫폼 포탈 배포 시 해당 인프라를 모두 설치한다.
컨테이너 플랫폼 인프라 설치는 아래 가이드를 참조한다.
> [파스타 컨테이너 플랫폼 포탈 배포](../container-platform-portal/paas-ta-container-platform-portal-deployment-standalone-guide.md)     


## <div id='3'>3. 컨테이너 플랫폼 소스 컨트롤 배포
    
### <div id='3.1'>3.1. 컨테이너 플랫폼 소스 컨트롤 Deployment 파일 다운로드
컨테이너 플랫폼 소스 컨트롤 배포를 위해 컨테이너 플랫폼 소스 컨트롤 Deployment 파일을 다운로드 받아 아래 경로로 위치시킨다.<br>
:bulb: 해당 내용은 Kubernetes **Master Node**에서 진행한다.

+ 컨테이너 플랫폼 소스 컨트롤 Deployment 파일 다운로드 :  
   [paas-ta-container-platform-source-control-deployment_v1.3.tar.gz](https://nextcloud.paas-ta.org/index.php/s/FSMcxmQ88kbBRHT)  

```
# Deployment 파일 다운로드 경로 생성
$ mkdir -p ~/workspace/container-platform
$ cd ~/workspace/container-platform

# Deployment 파일 다운로드 및 파일 경로 확인
$ wget --content-disposition https://nextcloud.paas-ta.org/index.php/s/FSMcxmQ88kbBRHT/download

$ ls ~/workspace/container-platform
  ...
  cp-source-control-deployment-v1.3.tar.gz
  ...

# Deployment 파일 압축 해제
$ tar xvfz cp-source-control-deployment-v1.3.tar.gz
```

- Deployment 파일 디렉토리 구성
```
├── script          # 컨테이너 플랫폼 소스 컨트롤 배포 관련 변수 및 스크립트 파일 위치
├── images          # 컨테이너 플랫폼 소스 컨트롤 이미지 파일 위치
├── charts          # 컨테이너 플랫폼 소스 컨트롤 Helm Charts 파일 위치
├── values_orig     # 컨테이너 플랫폼 소스 컨트롤 Helm Charts values.yaml 원본 파일 위치 
```

<br>

### <div id='3.2'>3.2. 컨테이너 플랫폼 소스 컨트롤 변수 정의
컨테이너 플랫폼 소스 컨트롤을 배포하기 전 변수 값 정의가 필요하다. 배포에 필요한 정보를 확인하여 변수를 설정한다.

```
$ cd ~/workspace/container-platform/cp-source-control-deployment/script
$ vi cp-source-control-vars.sh
```

```                                                     
# COMMON VARIABLE
K8S_MASTER_NODE_IP="{k8s master node public ip}"                 # Kubernetes master node public ip
PROVIDER_TYPE="{container platform source control provider type}"        # Container platform source-control provider type (Please enter 'standalone' or 'service')
....    
```
```    
# Example
K8S_MASTER_NODE_IP="xx.xxx.xxx.xx"                                       
PROVIDER_TYPE="standalone"           
```

- **K8S_MASTER_NODE_IP** <br>Kubernetes Master Node Public IP 입력<br><br>
- **PROVIDER_TYPE** <br>컨테이너 플랫폼 소스 컨트롤 제공 타입 입력 <br>
   + 본 가이드는 단독 배포 설치 가이드로 **'standalone'** 값 입력 필요
<br>    

:bulb: Keycloak 기본 배포 방식은 **HTTP**이며 인증서를 통한 **HTTPS**를 설정되어 있는 경우
> [Keycloak TLS 설정](../container-platform-portal/paas-ta-container-platform-portal-deployment-keycloak-tls-setting-guide.md)

컨테이너 플랫폼 소스 컨트롤 변수 파일 내 아래 내용을 수정한다.
```
$ vi container-platform-source-control-vars.sh    
```    
```
# KEYCLOAK_URL 값 http -> https 로 변경 
# Domain으로 nip.io를 사용하는 경우 아래와 같이 변경
    
....  
# KEYCLOAK    
KEYCLOAK_URL="https://${K8S_MASTER_NODE_IP}.nip.io:32710"   #if apply TLS, https://
....     
```

### <div id='3.3'>3.3. 컨테이너 플랫폼 소스 컨트롤 배포 스크립트 실행
컨테이너 플랫폼 소스 컨트롤 배포를 위한 배포 스크립트를 실행한다.

```
$ chmod +x deploy-cp-source-control.sh
$ ./deploy-cp-source-control.sh
```

```

...
...
namespace/cp-source-control created
secret/cp-secret created
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "cp-pipeline-repository" chart repository
...Successfully got an update from the "cp-portal-repository" chart repository
...Successfully got an update from the "cp-source-control-repository" chart repository
Update Complete. ⎈Happy Helming!⎈
cp-source-control-configmap deployed
cp-source-control-api deployed
cp-source-control-manager deployed
cp-source-control-ui deployed
...
...

```

<br>
    
- **컨테이너 플랫폼 소스 컨트롤**

```
# 소스 컨트롤 리소스 확인
$ kubectl get all -n cp-source-control
```
```
    
NAME                                                       READY   STATUS    RESTARTS   AGE
pod/cp-source-control-api-deployment-76c8c5d8d9-dxh7n      1/1     Running   0          51s
pod/cp-source-control-manager-deployment-8ff6cb694-p4w25   1/1     Running   0          51s
pod/cp-source-control-ui-deployment-bbfff5bd8-hl4fg        1/1     Running   0          51s

NAME                                        TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/cp-source-control-api-service       NodePort   10.233.41.43    <none>        8091:30091/TCP   110s
service/cp-source-control-manager-service   NodePort   10.233.55.178   <none>        8080:30092/TCP   102s
service/cp-source-control-ui-service        NodePort   10.233.15.193   <none>        8094:30094/TCP   94s

NAME                                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cp-source-control-api-deployment       1/1     1            1           108s
deployment.apps/cp-source-control-manager-deployment   0/1     1            0           102s
deployment.apps/cp-source-control-ui-deployment        0/1     1            0           94s

NAME                                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/cp-source-control-api-deployment-76c8c5d8d9      1         1         1       51s
replicaset.apps/cp-source-control-manager-deployment-8ff6cb694   1         1         0       51s
replicaset.apps/cp-source-control-ui-deployment-bbfff5bd8        1         1         0       51s




```    

<br>

### <div id='3.4'>3.4. (참조) 컨테이너 플랫폼 소스 컨트롤 리소스 삭제
배포된 컨테이너 플랫폼 소스 컨트롤 리소스의 삭제를 원하는 경우 아래 스크립트를 실행한다.<br>

```
$ cd ~/workspace/container-platform/cp-source-control-deployment/script
$ chmod +x uninstall-cp-source-control.sh
$ ./uninstall-cp-source-control.sh

```
```
Are you sure you want to delete the container platform source control? <y/n> # y 입력
release "cp-source-control-api" uninstalled
release "cp-source-control-manager" uninstalled
release "cp-source-control-broker" uninstalled
release "cp-source-control-ui" uninstalled
namespace "cp-source-control" deleted
...
...
```

## <div id='4'>4. 컨테이너 플랫폼 소스 컨트롤 접속  
컨테이너 플랫폼 소스 컨트롤 페이지는 아래 주소로 접속 가능하다.<br>
{K8S_MASTER_NODE_IP} 값은 **Kubernetes Master Node Public IP** 값을 입력한다.

- 컨테이너 플랫폼 소스 컨트롤 standalone 접속 URI : **http://{K8S_MASTER_NODE_IP}:30094** <br>

<br>
    
### <div id='4.1'/>4.1. 컨테이너 플랫폼 소스 컨트롤 관리자 로그인
컨테이너 플랫폼 소스 컨트롤 접속 초기 정보는 아래와 같다.
- http://{K8S_MASTER_NODE_IP}:30094에 접속한다.   
- username : **admin** / password : **admin** 계정으로 컨테이너 플랫폼 소스 컨트롤에 로그인한다.
![image](https://user-images.githubusercontent.com/80228983/146140178-76e85cbb-03a0-4a84-9059-7e5074c1d90e.png)

<br>    


### <div id='4.2'/>4.2. 컨테이너 플랫폼 소스 컨트롤 사용자 회원가입/로그인
#### 사용자 회원가입    
- Keycloak(http://{K8S_MASTER_NODE_IP}:32710)에 접속한다.
- Administration Console(관리자 페이지)로 접속한다. <br>
    ![image](https://user-images.githubusercontent.com/80228983/146140243-b01fe7b7-c610-4c74-b520-839b581ca178.png)
<br>

- username : **admin** / password : **admin** 계정으로 접속한다. <br>
    ![image](https://user-images.githubusercontent.com/80228983/146140270-06c6bc41-94cd-4947-8376-f6ade73b61ac.png)
<br>

- 좌측 메뉴 하단의 'Users' 목록을 클릭한다. <br>
    ![image](https://user-images.githubusercontent.com/80228983/146140350-c2bed5ab-0683-47cf-838b-6c970e492605.png)
<br>

- 오른쪽 버튼인 Add User를 클릭한다. <br>
    ![image](https://user-images.githubusercontent.com/80228983/146140392-1eb2d2e4-47d7-4fd2-8370-9d3e5b2a9871.png)
<br>

- Username 을 입력하고, Email Verified 스위치를 On으로 변경한다. 그 후 Save를 누른다. <br>
    ![image](https://user-images.githubusercontent.com/80228983/146140503-3ad5e8f7-613b-4583-83fe-3f6623736286.png)
<br>

- Credentials 탭으로 이동한다.
- Password / PassWord Confirmation을 입력하여 비밀번호를 설정한다.
- 임시번호가 아니라면 Temporary 스위치를 Off로 설정한다.<br>
    ![image](https://user-images.githubusercontent.com/80228983/146140746-54e57681-584c-43b3-93f1-f172205d34d2.png)
 <br>

####  로그인   
- http://{K8S_MASTER_NODE_IP}:30094에 접속한다.
- 회원가입을 통해 등록된 계정으로 컨테이너 플랫폼 소스 컨트롤에 로그인한다.
    
<br>    

### <div id='4.3'/>4.3. 컨테이너 플랫폼 소스 컨트롤 사용 가이드
- 컨테이너 플랫폼 소스컨트롤 사용 방법은 아래 사용가이드를 참고한다.  
  + [컨테이너 플랫폼 소스 컨트롤 사용 가이드](../../use-guide/source-control/paas-ta-container-platform-source-control-use-guide.md)   

<br>

### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Install](https://github.com/PaaS-TA/paas-ta-container-platform/tree/master/install-guide/Readme.md) > SourceControl 설치 가이드