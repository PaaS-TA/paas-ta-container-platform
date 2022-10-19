### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Install](https://github.com/PaaS-TA/paas-ta-container-platform/tree/master/install-guide/Readme.md) > Pipeline 설치 가이드

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
    2.3. [클러스터 환경](#2.3)
        
3. [컨테이너 플랫폼 파이프라인 배포](#3)      
    3.1. [컨테이너 플랫폼 파이프라인 Deployment 파일 다운로드](#3.1)    
    3.2. [컨테이너 플랫폼 파이프라인 변수 정의](#3.2)    
    3.3. [컨테이너 플랫폼 파이프라인 배포 스크립트 실행](#3.3)    
    3.4. [(참조) 컨테이너 플랫폼 파이프라인 리소스 삭제](#3.4)    

4. [컨테이너 플랫폼 파이프라인 접속](#4)      
    4.1. [컨테이너 플랫폼 파이프라인 관리자 로그인](#4.1)      
    4.2. [컨테이너 플랫폼 파이프라인 사용자 회원가입/로그인](#4.2)  
    4.3. [컨테이너 플랫폼 파이프라인 사용 가이드](#4.3)           



## <div id='1'>1. 문서 개요
### <div id='1.1'>1.1. 목적
본 문서(Container Platform Pipeline 단독 배포 설치 가이드)는 Kubernetes  Cluster 및 컨테이너 플랫폼 단독 배포 형 포탈을 설치하고 컨테이너 플랫폼 단독 배포형 파이프라인 배포 방법을 기술하였다.<br>

<br>

### <div id='1.2'>1.2. 범위
설치 범위는 Kubernetes Cluster 배포를 기준으로 작성하였다.

<br>

### <div id='1.3'>1.3. 시스템 구성도
![image](https://user-images.githubusercontent.com/80228983/146350860-3722c081-7338-438d-b7ec-1fdac09160c4.png)
<br>
시스템 구성은 Kubernetes Cluster(Master, Worker) 환경과 데이터 관리를 위한 네트워크 파일 시스템(NFS) 스토리지 서버로 구성되어 있다. 
Kubespray를 통해 설치된 Kubernetes Cluster 환경에 컨테이너 플랫폼 파이프라인 이미지 및 Helm Chart를 관리하는 Harbor, 컨테이너 플랫폼 파이프라인 사용자 인증을 관리하는 Keycloak, 컨테이너 플랫폼 파이프라인 메타 데이터를 관리하는 MariaDB(RDBMS)가 컨테이너 플랫폼 포탈을 통해서 제공된다.
 컨테이너 플랫폼 파이프라인에서는 지속적 통합과 배포 기능을 관리하는 Jenkins 서버(Ci-Server) 와 정적 분석을 위한 Sonarqube(Inspection-Server), 배포되는 애플리케이션의 Config를 관리하는 Spring Config Server(Config-Server) 등 파이프라인 동작에 필요한 환경을 컨테이너로 제공한다. 
총 필요한 VM 환경으로는 Master Node VM: 1개, Worker Node VM: 1개 이상, NFS Server : 1개가 필요하고 본 문서는 Kubernetes Cluster에 컨테이너 플랫폼 파이프라인 환경을 배포하는 내용이다. 네트워크 파일 시스템(NFS) 은 컨테이너 플랫폼에서 기본으로 제공하는 스토리지로 사용자 환경에 따라 다양한 종류의 스토리지를 사용할 수 있다.

### <div id='1.4'>1.4. 참고 자료
> https://kubernetes.io/ko/docs  

<br>

## <div id='2'>2. Prerequisite
    
### <div id='2.1'>2.1. NFS 서버 설치
컨테이너 플랫폼 파이프라인에서 사용할 스토리지 **NFS Storage Server** 설치가 사전에 진행되어야 한다.<br>
NFS Storage Server 설치는 아래 가이드를 참조한다.  
> [NFS 서버 설치](../nfs-server-install-guide.md)      
    
### <div id='2.2'>2.2. 컨테이너 플랫폼 포탈 설치
컨테이너 플랫폼 파이프라인에서 사용할 인프라로 인증서버 **KeyCloak Server**, 데이터베이스 **Maria DB**, 레포지토리 서버 **Harbor** 설치가 사전에 진행되어야 한다.
파스타 컨테이너 플랫폼 포탈 배포 시 해당 인프라를 모두 설치한다.
컨테이너 플랫폼 인프라 설치는 아래 가이드를 참조한다.
> [파스타 컨테이너 플랫폼 포탈 배포](../container-platform-portal/paas-ta-container-platform-portal-deployment-standalone-guide.md)     


### <div id='2.3'>2.3. Cluster 환경
컨테이너 플랫폼 배포를 위해서는 sonarqube, postgresql 등의 image를 public network에서 다운받기 때문에 **외부 네트워크 통신**이 가능한 환경에서 설치해야 한다. <br>
컨테이너 플랫폼 파이프라인 설치 완료 시 idle 상태에서의 사용 resource는 다음과 같다.
```
NAME                                                     CPU(cores)   MEMORY(bytes)
cp-pipeline-api-deployment-bb6f7bd46-nl4j4               1m           224Mi
cp-pipeline-common-api-deployment-54c646c95c-87k5g       2m           255Mi
cp-pipeline-config-server-deployment-78675b565d-8kxf9    2m           170Mi
cp-pipeline-inspection-api-deployment-6bf9c4479d-d6xgb   1m           158Mi
cp-pipeline-jenkins-deployment-779c6d7bc9-pn782          3m           1319Mi
cp-pipeline-postgresql-postgresql-0                      4m           58Mi
cp-pipeline-sonarqube-sonarqube-6d9c6b579f-2xkkw         7m           1744Mi
cp-pipeline-ui-deployment-5db955b77b-snkpl               1m           337Mi
```
컨테이너 플랫폼 파이프라인을 설치할 클러스터 환경에는 클러스터 총합 최소 **4Gi**의 여유 메모리를 권장한다.

컨테이너 플랫폼 파이프라인 설치 완료 시 Persistent Volume 사용 resource는 다음과 같다.    
```
NAME                                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS
cp-pipeline-jenkins-pv                     Bound    pvc-4bf64900-d25c-482f-9aa3-baa07c11cdd1   20Gi       RWO            cp-nfs-storageclass
data-cp-pipeline-postgresql-postgresql-0   Bound    pvc-f61096ac-5e2b-4105-9ed3-04a9a7d999cb   8Gi        RWX            cp-nfs-storageclass

```
컨테이너 플랫폼 파이프라인을 설치할 클러스터 환경에는 NFS 스토리지 용량 **28Gi**의 여유 용량을 권장한다.<br>        
    
## <div id='3'>3. 컨테이너 플랫폼 파이프라인 배포
    
### <div id='3.1'>3.1. 컨테이너 플랫폼 파이프라인 Deployment 파일 다운로드
컨테이너 플랫폼 파이프라인 배포를 위해 컨테이너 플랫폼 파이프라인 Deployment 파일을 다운로드 받아 아래 경로로 위치시킨다.<br>
:bulb: 해당 내용은 Kubernetes **Master Node**에서 진행한다.

+ 컨테이너 플랫폼 파이프라인 Deployment 파일 다운로드 :  
   [cp-pipeline-deployment-v1.3.2.tar.gz](https://nextcloud.paas-ta.org/index.php/s/CSBqkwJYwJpiR9z)    

```
# Deployment 파일 다운로드 경로 생성
$ mkdir -p ~/workspace/container-platform
$ cd ~/workspace/container-platform

# Deployment 파일 다운로드 및 파일 경로 확인
$ wget --content-disposition https://nextcloud.paas-ta.org/index.php/s/CSBqkwJYwJpiR9z/download

$ ls ~/workspace/container-platform
  ...
    cp-pipeline-deployment-v1.3.2.tar.gz
  ...
  
# Deployment 파일 압축 해제
$ tar xvfz cp-pipeline-deployment-v1.3.2.tar.gz
```

- Deployment 파일 디렉토리 구성
```
├── script          # 컨테이너 플랫폼 파이프라인 배포 관련 변수 및 스크립트 파일 위치
├── images          # 컨테이너 플랫폼 파이프라인 이미지 파일 위치
├── charts          # 컨테이너 플랫폼 파이프라인 Helm Charts 파일 위치
├── values_orig     # 컨테이너 플랫폼 파이프라인 Helm Charts values.yaml 원본 파일 위치 
```

<br>

### <div id='3.2'>3.2. 컨테이너 플랫폼 파이프라인 변수 정의
컨테이너 플랫폼 파이프라인을 배포하기 전 변수 값 정의가 필요하다. 배포에 필요한 정보를 확인하여 변수를 설정한다.

```
$ cd ~/workspace/container-platform/cp-pipeline-deployment/script
$ vi cp-pipeline-vars.sh
```

```                                                     
# COMMON VARIABLE
K8S_MASTER_NODE_IP="{k8s master node public ip}"                 # Kubernetes master node public ip
PROVIDER_TYPE="{container platform pipeline provider type}"        # Container platform pipeline provider type (Please enter 'standalone' or 'service')
....    
```
```    
# Example
K8S_MASTER_NODE_IP="xx.xxx.xxx.xx"                                       
PROVIDER_TYPE="standalone"
```

- **K8S_MASTER_NODE_IP** <br>Kubernetes Master Node Public IP 입력<br><br>
- **PROVIDER_TYPE** <br>컨테이너 플랫폼 파이프라인 제공 타입 입력 <br>
   + 본 가이드는 단독 배포 설치 가이드로 **'standalone'** 값 입력 필요<br><br>
- **CF_API_URL** <br>단독 배포 버젼에서는 입력할 필요 없음 <br>    

<br>

:bulb: Keycloak 기본 배포 방식은 **HTTP**이며 인증서를 통한 **HTTPS**를 설정되어 있는 경우
> [Keycloak TLS 설정](../container-platform-portal/paas-ta-container-platform-portal-deployment-keycloak-tls-setting-guide.md)

컨테이너 플랫폼 파이프라인 변수 파일 내 아래 내용을 수정한다.
```
$ vi cp-pipeline-vars.sh  
```    
```
# KEYCLOAK_URL 값 http -> https 로 변경 
# Domain으로 nip.io를 사용하는 경우 아래와 같이 변경
    
....  
# KEYCLOAK    
KEYCLOAK_URL="https://${K8S_MASTER_NODE_IP}.nip.io:32710"   #if apply TLS, https://
....     
```

### <div id='3.3'>3.3. 컨테이너 플랫폼 파이프라인 배포 스크립트 실행
컨테이너 플랫폼 파이프라인 배포를 위한 배포 스크립트를 실행한다.

```
$ chmod +x deploy-cp-pipeline.sh
$ ./deploy-cp-pipeline.sh
```

```

...
...
Pushing cp-pipeline-configmap-1.3.tgz to cp-pipeline-repository...
Done.
Pushing cp-pipeline-jenkins-1.3.tgz to cp-pipeline-repository...
Done.
Pushing cp-pipeline-app-1.3.tgz to cp-pipeline-repository...
Done.
Pushing sonarqube-1.3.tgz to cp-pipeline-repository...
Done.
Pushing postgresql-1.3.tgz to cp-pipeline-repository...
Done.
...
...
Update Complete. ⎈Happy Helming!⎈
cp-pipeline-configmap deployed
cp-pipeline-api deployed
cp-pipeline-common-api deployed
cp-pipeline-ui deployed
cp-pipeline-inspection-api deployed
cp-pipeline-jenkins deployed
cp-pipeline-config-server deployed
cp-pipeline-postgresql deployed
cp-pipeline-sonarqube deployed
NAME                            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
cp-pipeline-api                 cp-pipeline     1               2022-05-03 08:11:37.229869039 +0000 UTC deployed        cp-pipeline-app-1.3             1.16.0
cp-pipeline-common-api          cp-pipeline     1               2022-05-03 08:11:37.627641739 +0000 UTC deployed        cp-pipeline-app-1.3             1.16.0
cp-pipeline-config-server       cp-pipeline     1               2022-05-03 08:11:40.242660784 +0000 UTC deployed        cp-pipeline-app-1.3             1.16.0
cp-pipeline-configmap           cp-pipeline     1               2022-05-03 08:11:35.69429441 +0000 UTC  deployed        cp-pipeline-configmap-1.3       1.16.0
cp-pipeline-inspection-api      cp-pipeline     1               2022-05-03 08:11:39.131875192 +0000 UTC deployed        cp-pipeline-app-1.3             1.16.0
cp-pipeline-jenkins             cp-pipeline     1               2022-05-03 08:11:39.592099347 +0000 UTC deployed        cp-pipeline-jenkins-1.3         1.16.0
cp-pipeline-postgresql          cp-pipeline     1               2022-05-03 08:11:41.543610908 +0000 UTC deployed        postgresql-1.3                  11.14.0
cp-pipeline-sonarqube           cp-pipeline     1               2022-05-03 08:11:42.629622004 +0000 UTC deployed        sonarqube-1.3                   8.5.1-community
cp-pipeline-ui                  cp-pipeline     1               2022-05-03 08:11:38.607580498 +0000 UTC deployed        cp-pipeline-app-1.3             1.16.0
NAME                                                         READY   STATUS              RESTARTS   AGE
pod/cp-pipeline-api-deployment-bb6f7bd46-xmtxx               1/1     Running             0          6s
pod/cp-pipeline-common-api-deployment-54c646c95c-pr8d4       1/1     Running             0          6s
pod/cp-pipeline-config-server-deployment-78675b565d-jsg6z    0/1     ContainerCreating   0          3s
pod/cp-pipeline-inspection-api-deployment-6bf9c4479d-qvt2s   1/1     Running             0          4s
pod/cp-pipeline-jenkins-deployment-779c6d7bc9-fphrv          0/1     ContainerCreating   0          4s
pod/cp-pipeline-postgresql-postgresql-0                      0/1     ContainerCreating   0          0s
pod/cp-pipeline-sonarqube-sonarqube-6d9c6b579f-ndjmj         0/1     Init:0/1            0          0s
pod/cp-pipeline-ui-deployment-5db955b77b-6zgtg               1/1     Running             0          5s

NAME                                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/cp-pipeline-api-service              NodePort    10.233.33.178   <none>        8082:30082/TCP   6s
service/cp-pipeline-common-api-service       NodePort    10.233.42.55    <none>        8081:30081/TCP   6s
service/cp-pipeline-config-server-service    NodePort    10.233.29.96    <none>        8080:30088/TCP   3s
service/cp-pipeline-inspection-api-service   NodePort    10.233.18.126   <none>        8085:30085/TCP   4s
service/cp-pipeline-jenkins-service          NodePort    10.233.43.30    <none>        8080:30086/TCP   4s
service/cp-pipeline-postgresql               ClusterIP   10.233.27.243   <none>        5432/TCP         2s
service/cp-pipeline-postgresql-headless      ClusterIP   None            <none>        5432/TCP         2s
service/cp-pipeline-sonarqube-sonarqube      NodePort    10.233.52.4     <none>        9000:30087/TCP   1s
service/cp-pipeline-ui-service               NodePort    10.233.57.132   <none>        8084:30084/TCP   5s

NAME                                                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cp-pipeline-api-deployment              1/1     1            1           6s
deployment.apps/cp-pipeline-common-api-deployment       1/1     1            1           6s
deployment.apps/cp-pipeline-config-server-deployment    1/1     1            1           3s
deployment.apps/cp-pipeline-inspection-api-deployment   1/1     1            1           4s
deployment.apps/cp-pipeline-jenkins-deployment          0/1     1            0           4s
deployment.apps/cp-pipeline-sonarqube-sonarqube         0/1     1            0           0s
deployment.apps/cp-pipeline-ui-deployment               1/1     1            1           5s

NAME                                                               DESIRED   CURRENT   READY   AGE
replicaset.apps/cp-pipeline-api-deployment-bb6f7bd46               1         1         1       6s
replicaset.apps/cp-pipeline-common-api-deployment-54c646c95c       1         1         1       6s
replicaset.apps/cp-pipeline-config-server-deployment-78675b565d    1         1         1       3s
replicaset.apps/cp-pipeline-inspection-api-deployment-6bf9c4479d   1         1         1       4s
replicaset.apps/cp-pipeline-jenkins-deployment-779c6d7bc9          1         1         0       4s
replicaset.apps/cp-pipeline-sonarqube-sonarqube-6d9c6b579f         1         1         0       0s
replicaset.apps/cp-pipeline-ui-deployment-5db955b77b               1         1         1       5s

NAME                                                 READY   AGE
statefulset.apps/cp-pipeline-postgresql-postgresql   0/1     1s

```


<br>

- **컨테이너 플랫폼 파이프라인**

```
# 파이프라인 리소스 확인
$ kubectl get all -n cp-pipeline
```

```
NAME                                                         READY   STATUS    RESTARTS      AGE
pod/cp-pipeline-api-deployment-bb6f7bd46-xmtxx               1/1     Running   0             71s
pod/cp-pipeline-common-api-deployment-54c646c95c-pr8d4       1/1     Running   0             71s
pod/cp-pipeline-config-server-deployment-78675b565d-jsg6z    1/1     Running   0             68s
pod/cp-pipeline-inspection-api-deployment-6bf9c4479d-qvt2s   1/1     Running   0             69s
pod/cp-pipeline-jenkins-deployment-779c6d7bc9-fphrv          1/1     Running   0             69s
pod/cp-pipeline-postgresql-postgresql-0                      1/1     Running   0             65s
pod/cp-pipeline-sonarqube-sonarqube-6d9c6b579f-ndjmj         0/1     Running   0             65s
pod/cp-pipeline-ui-deployment-5db955b77b-6zgtg               1/1     Running   0             70s

NAME                                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/cp-pipeline-api-service              NodePort    10.233.33.178   <none>        8082:30082/TCP   71s
service/cp-pipeline-common-api-service       NodePort    10.233.42.55    <none>        8081:30081/TCP   71s
service/cp-pipeline-config-server-service    NodePort    10.233.29.96    <none>        8080:30088/TCP   68s
service/cp-pipeline-inspection-api-service   NodePort    10.233.18.126   <none>        8085:30085/TCP   69s
service/cp-pipeline-jenkins-service          NodePort    10.233.43.30    <none>        8080:30086/TCP   69s
service/cp-pipeline-postgresql               ClusterIP   10.233.27.243   <none>        5432/TCP         67s
service/cp-pipeline-postgresql-headless      ClusterIP   None            <none>        5432/TCP         67s
service/cp-pipeline-sonarqube-sonarqube      NodePort    10.233.52.4     <none>        9000:30087/TCP   66s
service/cp-pipeline-ui-service               NodePort    10.233.57.132   <none>        8084:30084/TCP   70s

NAME                                                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cp-pipeline-api-deployment              1/1     1            1           71s
deployment.apps/cp-pipeline-common-api-deployment       1/1     1            1           71s
deployment.apps/cp-pipeline-config-server-deployment    1/1     1            1           68s
deployment.apps/cp-pipeline-inspection-api-deployment   1/1     1            1           69s
deployment.apps/cp-pipeline-jenkins-deployment          1/1     1            1           69s
deployment.apps/cp-pipeline-sonarqube-sonarqube         0/1     1            0           65s
deployment.apps/cp-pipeline-ui-deployment               1/1     1            1           70s

NAME                                                               DESIRED   CURRENT   READY   AGE
replicaset.apps/cp-pipeline-api-deployment-bb6f7bd46               1         1         1       71s
replicaset.apps/cp-pipeline-common-api-deployment-54c646c95c       1         1         1       71s
replicaset.apps/cp-pipeline-config-server-deployment-78675b565d    1         1         1       68s
replicaset.apps/cp-pipeline-inspection-api-deployment-6bf9c4479d   1         1         1       69s
replicaset.apps/cp-pipeline-jenkins-deployment-779c6d7bc9          1         1         1       69s
replicaset.apps/cp-pipeline-sonarqube-sonarqube-6d9c6b579f         1         1         0       65s
replicaset.apps/cp-pipeline-ui-deployment-5db955b77b               1         1         1       70s

NAME                                                 READY   AGE
statefulset.apps/cp-pipeline-postgresql-postgresql   1/1     66s

```    

### <div id='3.4'>3.4. (참조) 컨테이너 플랫폼 파이프라인 리소스 삭제
배포된 컨테이너 플랫폼 파이프라인 리소스의 삭제를 원하는 경우 아래 스크립트를 실행한다.<br>

```
$ cd ~/workspace/container-platform/cp-pipeline-deployment/script
$ chmod +x uninstall-cp-pipeline.sh
$ ./uninstall-cp-pipeline.sh
Are you sure you want to delete the container platform pipeline? <y/n> # y 입력

```
```
...

release "cp-pipeline-api" uninstalled
release "cp-pipeline-common-api" uninstalled
release "cp-pipeline-ui" uninstalled
release "cp-pipeline-inspection-api" uninstalled
release "cp-pipeline-jenkins" uninstalled
release "cp-pipeline-config-server" uninstalled
release "cp-pipeline-postgresql" uninstalled
release "cp-pipeline-sonarqube" uninstalled
namespace "cp-pipeline" deleted
...
...
```

<br>

## <div id='4'>4. 컨테이너 플랫폼 파이프라인 접속  
컨테이너 플랫폼 파이프라인 페이지는 아래 주소로 접속 가능하다.<br>
{K8S_MASTER_NODE_IP} 값은 **Kubernetes Master Node Public IP** 값을 입력한다.

- 컨테이너 플랫폼 파이프라인 standalone 접속 URI : **http://{K8S_MASTER_NODE_IP}:30084** <br>

<br>
    
### <div id='4.1'/>4.1. 컨테이너 플랫폼 파이프라인 관리자 로그인
컨테이너 플랫폼 파이프라인 접속 초기 정보는 아래와 같다.
- http://{K8S_MASTER_NODE_IP}:30084에 접속한다.   
- username : **admin** / password : **admin** 계정으로 컨테이너 플랫폼 파이프라인에 로그인한다.
![image](https://user-images.githubusercontent.com/80228983/146140178-76e85cbb-03a0-4a84-9059-7e5074c1d90e.png)

<br>    


### <div id='4.2'/>4.2. 컨테이너 플랫폼 파이프라인 사용자 회원가입/로그인
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
- http://{K8S_MASTER_NODE_IP}:30084에 접속한다.
- 회원가입을 통해 등록된 계정으로 컨테이너 플랫폼 파이프라인에 로그인한다.
    
<br>    

### <div id='4.3'/>4.3. 컨테이너 플랫폼 파이프라인 사용 가이드
- 컨테이너 플랫폼 파이프라인 사용방법은 아래 사용가이드를 참고한다.  
  + [컨테이너 플랫폼 파이프라인 사용 가이드](../../use-guide/pipeline/paas-ta-container-platform-pipeline-use-guide.md)    

<br>

### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Install](https://github.com/PaaS-TA/paas-ta-container-platform/tree/master/install-guide/Readme.md) > Pipeline 설치 가이드