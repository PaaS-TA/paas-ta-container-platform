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
    3.1. [CRI-O insecure-registry 설정](#3.1)  
    3.2. [컨테이너 플랫폼 파이프라인 배포](#3.2)  
    3.2.1. [컨테이너 플랫폼 파이프라인 Deployment 파일 다운로드](#3.2.1)  
    3.2.2. [컨테이너 플랫폼 파이프라인 변수 정의](#3.2.2)    
    3.2.3. [컨테이너 플랫폼 파이프라인 배포 스크립트 실행](#3.2.3)    
    3.2.4. [(참조) 컨테이너 플랫폼 파이프라인 리소스 삭제](#3.2.4)    

4. [컨테이너 플랫폼 파이프라인 서비스 브로커](#4)   
    4.1. [컨테이너 플랫폼 파이프라인 사용자 인증 서비스 구성](#4.1)   
    4.2. [컨테이너 플랫폼 파이프라인 서비스 브로커 등록](#4.2)  
    4.3. [컨테이너 플랫폼 파이프라인 서비스 조회 설정](#4.3)    
    4.4. [컨테이너 플랫폼 파이프라인 사용 가이드](#4.4)       



## <div id='1'>1. 문서 개요
### <div id='1.1'>1.1. 목적
본 문서(Container Platform Pipeline 서비스 배포 설치 가이드)는 Kubernetes  Cluster 및 컨테이너 플랫폼 서비스 배포 형 포탈을 설치하고 컨테이너 플랫폼 서비스 배포형 파이프라인 배포 방법을 기술하였다.<br>

<br>

### <div id='1.2'>1.2. 범위
설치 범위는 Kubernetes Cluster 배포를 기준으로 작성하였다.

<br>

### <div id='1.3'>1.3. 시스템 구성도
![image](https://user-images.githubusercontent.com/80228983/146350860-3722c081-7338-438d-b7ec-1fdac09160c4.png)<br>
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
컨테이너 플랫폼 포탈 설치는 아래 가이드를 참조한다.
> [파스타 컨테이너 플랫폼 포탈 배포](../container-platform-portal/paas-ta-container-platform-portal-deployment-service-guide-v1.2.md)     


### <div id='2.3'>2.3. Cluster 환경
컨테이너 플랫폼 파이프라인 배포를 위해서는 sonarqube, postgresql 등의 image를 public network에서 다운받기 때문에 **외부 네트워크 통신**이 가능한 환경에서 설치해야 한다. <br>
컨테이너 플랫폼 파이프라인 설치 완료 시 idle 상태에서의 사용 resource는 다음과 같다.
```
NAME                                                              CPU(cores)   MEMORY(bytes)
container-platform-pipeline-api-deployment-67bc5b4d9b-s6455       1m           168Mi
container-platform-pipeline-broker-deployment-c7d5cc56-xgsf2      2m           181Mi
container-platform-pipeline-common-api-deployment-6677c494bfjjj   2m           242Mi
container-platform-pipeline-config-server-deployment-58fc95prx2   2m           178Mi
container-platform-pipeline-inspection-api-deployment-6f7c6sfbp   1m           141Mi
container-platform-pipeline-jenkins-deployment-5595ff67b5-7snrn   2m           905Mi
container-platform-pipeline-ui-deployment-c88df8f74-jc9wv         1m           173Mi
paas-ta-container-platform-postgresql-postgresql-0                4m           41Mi
paas-ta-container-platform-sonarqube-sonarqube-5c799d8c97-pltdn   13m          1566Mi

```
컨테이너 플랫폼 파이프라인을 설치할 클러스터 환경에는 클러스터 총합 최소 **4Gi**의 여유 메모리를 권장한다.<br>

컨테이너 플랫폼 파이프라인 설치 완료 시 Persistent Volume 사용 resource는 다음과 같다.    
```
NAME                                                      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS                                  AGE
container-platform-pipeline-jenkins-pv                    Bound    pvc-9faf103f-5462-4a76-9f4b-f9bd81e1471b   20Gi        RWO            paas-ta-container-platform-nfs-storageclass   30h
data-paas-ta-container-platform-postgresql-postgresql-0   Bound    pvc-327312f3-35b9-4e4e-aa2a-0f094f5fdd0a   8Gi        RWX            paas-ta-container-platform-nfs-storageclass   30h

```
컨테이너 플랫폼 파이프라인을 설치할 클러스터 환경에는 NFS 스토리지 용량 **28Gi**의 여유 용량을 권장한다.<br>    
    
    
## <div id='3'>3. 컨테이너 플랫폼 파이프라인 배포

### <div id='3.1'>3.1. CRI-O insecure-registry 설정
컨테이너 플랫폼 파이프라인 배포 시 이미지 및 패키지 파일 업로드는 클러스터에 설치된 Private Repository에 한다.
컨테이너 플랫폼 포탈 설치 시 배포된 Private Repository(Harbor)에 컨테이너 플랫폼 파이프라인 관련 이미지 및 패키지 파일 업로드한다. 

Private Repository 배포에 필요한 CRI-O insecure-registry 설정은 아래 가이드를 참조한다.
> [CRI-O insecure-registry 설정](../container-platform-portal/paas-ta-container-platform-portal-deployment-service-guide-v1.2.md#3.1)     

### <div id='3.2'>3.2. 컨테이너 플랫폼 파이프라인 배포
    
#### <div id='3.2.1'>3.2.1. 컨테이너 플랫폼 파이프라인 Deployment 파일 다운로드
컨테이너 플랫폼 파이프라인 배포를 위해 컨테이너 플랫폼 파이프라인 Deployment 파일을 다운로드 받아 아래 경로로 위치시킨다.<br>
:bulb: 해당 내용은 Kubernetes **Master Node**에서 진행한다.

+ 컨테이너 플랫폼 파이프라인 Deployment 파일 다운로드 :  
   [paas-ta-container-platform-pipeline-deployment.tar](https://nextcloud.paas-ta.org/index.php/s/6BDzar68ck5jryq)  

```
# Deployment 파일 다운로드 경로 생성
$ mkdir -p ~/workspace/container-platform
$ cd ~/workspace/container-platform

# Deployment 파일 다운로드 및 파일 경로 확인
$ wget --content-disposition https://nextcloud.paas-ta.org/index.php/s/6BDzar68ck5jryq/download

$ ls ~/workspace/container-platform
  ...
  paas-ta-container-platform-pipeline-deployment.tar.gz
  ...
# Deployment 파일 압축 해제
$ tar xvfz paas-ta-container-platform-pipeline-deployment.tar.gz
```

- Deployment 파일 디렉토리 구성
```
├── script          # 컨테이너 플랫폼 파이프라인 배포 관련 변수 및 스크립트 파일 위치
├── images          # 컨테이너 플랫폼 파이프라인 이미지 파일 위치
├── charts          # 컨테이너 플랫폼 파이프라인 Helm Charts 파일 위치
├── values_orig     # 컨테이너 플랫폼 파이프라인 Helm Charts values.yaml 원본 파일 위치 
```

<br>

#### <div id='3.2.2'>3.2.2. 컨테이너 플랫폼 파이프라인 변수 정의
컨테이너 플랫폼 파이프라인을 배포하기 전 변수 값 정의가 필요하다. 배포에 필요한 정보를 확인하여 변수를 설정한다.

```
$ cd ~/workspace/container-platform/paas-ta-container-platform-pipeline-deployment/script
$ vi container-platform-pipeline-vars.sh
```

```                                                     
# COMMON VARIABLE
K8S_MASTER_NODE_IP="{k8s master node public ip}"                 # Kubernetes master node public ip
PROVIDER_TYPE="{container platform pipeline provider type}"        # Container platform pipeline provider type (Please enter 'standalone' or 'service')
CF_API_URL="https:\/\/{paas-ta-api-domain}"                      # e.g) https:\/\/api.10.0.0.120.nip.io, PaaS-TA API Domain, PROVIDER_TYPE=service 인 경우 입력
....    
```
```    
# Example
K8S_MASTER_NODE_IP="xx.xxx.xxx.xx"                                       
PROVIDER_TYPE="service"
CF_API_URL="https:\/\/api.xx.xxx.xxx.xx.nip.io"
```

- **K8S_MASTER_NODE_IP** <br>Kubernetes Master Node Public IP 입력<br><br>
- **PROVIDER_TYPE** <br>컨테이너 플랫폼 파이프라인 제공 타입 입력 <br>
   + 본 가이드는 서비스 배포 설치 가이드로 **'service'** 값 입력 필요<br><br>
- **CF_API_URL** <br>서비스 연동할 PaaS-TA의 api domain 입력 <br>
<br>    

:bulb: Keycloak 기본 배포 방식은 **HTTP**이며 인증서를 통한 **HTTPS**를 설정되어 있는 경우
> [Keycloak TLS 설정](../container-platform-portal/paas-ta-container-platform-portal-deployment-keycloak-tls-setting-guide-v1.2.md)

컨테이너 플랫폼 파이프라인 변수 파일 내 아래 내용을 수정한다.
```
$ vi container-platform-pipeline-vars.sh    
```    
```
# KEYCLOAK_URL 값 http -> https 로 변경 
# Domain으로 nip.io를 사용하는 경우 아래와 같이 변경
    
....  
# KEYCLOAK    
KEYCLOAK_URL="https:\/\/${K8S_MASTER_NODE_IP}.nip.io:32710"   # Keycloak url (include http:\/\/, if apply TLS, https:\/\/)
....     
```

#### <div id='3.2.3'>3.2.3. 컨테이너 플랫폼 파이프라인 배포 스크립트 실행
컨테이너 플랫폼 파이프라인 배포를 위한 배포 스크립트를 실행한다.

```
$ chmod +x deploy-container-platform-pipeline.sh
$ ./deploy-container-platform-pipeline.sh
```

```

...
...
NAME: paas-ta-container-platform-pipeline-api
LAST DEPLOYED: Tue Dec 14 04:23:06 2021
NAMESPACE: paas-ta-container-platfrom-pipeline
STATUS: deployed
REVISION: 1
TEST SUITE: None
...
...
NAME: paas-ta-container-platform-sonarqube
LAST DEPLOYED: Tue Dec 14 04:23:12 2021
NAMESPACE: paas-ta-container-platfrom-pipeline
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export NODE_PORT=$(kubectl get --namespace paas-ta-container-platfrom-pipeline -o jsonpath="{.spec.ports[0].nodePort}" services paas-ta-container-platform-sonarqube-sonarqube)
  export NODE_IP=$(kubectl get nodes --namespace paas-ta-container-platfrom-pipeline -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT

```


<br>
    
- **컨테이너 플랫폼 파이프라인**

```
# 파이프라인 리소스 확인
$ kubectl get all -n paas-ta-container-platform-pipeline
```

```
NAME                                                                  READY   STATUS    RESTARTS   AGE
pod/container-platform-pipeline-api-deployment-67bc5b4d9b-s6455       1/1     Running   0          119s
pod/container-platform-pipeline-broker-deployment-c7d5cc56-xgsf2      1/1     Running   1          118s
pod/container-platform-pipeline-common-api-deployment-6677c494bfjjj   1/1     Running   0          118s
pod/container-platform-pipeline-config-server-deployment-58fc95prx2   1/1     Running   0          113s
pod/container-platform-pipeline-inspection-api-deployment-6f7c6sfbp   1/1     Running   0          116s
pod/container-platform-pipeline-jenkins-deployment-5595ff67b5-7snrn   1/1     Running   0          115s
pod/container-platform-pipeline-ui-deployment-c88df8f74-jc9wv         1/1     Running   0          117s
pod/paas-ta-container-platform-postgresql-postgresql-0                1/1     Running   0          112s
pod/paas-ta-container-platform-sonarqube-sonarqube-5c799d8c97-pltdn   1/1     Running   0          111s

NAME                                                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/container-platform-pipeline-api-service              NodePort    10.233.10.130   <none>        8082:30082/TCP   119s
service/container-platform-pipeline-broker-service           NodePort    10.233.6.98     <none>        8083:30083/TCP   118s
service/container-platform-pipeline-common-api-service       NodePort    10.233.47.49    <none>        8081:30081/TCP   118s
service/container-platform-pipeline-config-server-service    NodePort    10.233.51.40    <none>        8080:30088/TCP   114s
service/container-platform-pipeline-inspection-api-service   NodePort    10.233.55.123   <none>        8085:30085/TCP   116s
service/container-platform-pipeline-jenkins-service          NodePort    10.233.18.195   <none>        8080:30086/TCP   115s
service/container-platform-pipeline-ui-service               NodePort    10.233.49.219   <none>        8084:30084/TCP   117s
service/paas-ta-container-platform-postgresql                ClusterIP   10.233.46.68    <none>        5432/TCP         112s
service/paas-ta-container-platform-postgresql-headless       ClusterIP   None            <none>        5432/TCP         112s
service/paas-ta-container-platform-sonarqube-sonarqube       NodePort    10.233.47.187   <none>        9000:30087/TCP   111s

NAME                                                                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/container-platform-pipeline-api-deployment              1/1     1            1           119s
deployment.apps/container-platform-pipeline-broker-deployment           1/1     1            1           118s
deployment.apps/container-platform-pipeline-common-api-deployment       1/1     1            1           118s
deployment.apps/container-platform-pipeline-config-server-deployment    1/1     1            1           114s
deployment.apps/container-platform-pipeline-inspection-api-deployment   1/1     1            1           116s
deployment.apps/container-platform-pipeline-jenkins-deployment          1/1     1            1           115s
deployment.apps/container-platform-pipeline-ui-deployment               1/1     1            1           117s
deployment.apps/paas-ta-container-platform-sonarqube-sonarqube          1/1     1            1           111s

NAME                                                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/container-platform-pipeline-api-deployment-67bc5b4d9b             1         1         1       119s
replicaset.apps/container-platform-pipeline-broker-deployment-c7d5cc56            1         1         1       118s
replicaset.apps/container-platform-pipeline-common-api-deployment-6677c494b       1         1         1       118s
replicaset.apps/container-platform-pipeline-config-server-deployment-58fc9bb8b4   1         1         1       113s
replicaset.apps/container-platform-pipeline-inspection-api-deployment-6f7cbc558   1         1         1       116s
replicaset.apps/container-platform-pipeline-jenkins-deployment-5595ff67b5         1         1         1       115s
replicaset.apps/container-platform-pipeline-ui-deployment-c88df8f74               1         1         1       117s
replicaset.apps/paas-ta-container-platform-sonarqube-sonarqube-5c799d8c97         1         1         1       111s

NAME                                                                READY   AGE
statefulset.apps/paas-ta-container-platform-postgresql-postgresql   1/1     112s


```    

#### <div id='3.2.4'>3.2.4. (참조) 컨테이너 플랫폼 파이프라인 리소스 삭제
배포된 컨테이너 플랫폼 파이프라인 리소스의 삭제를 원하는 경우 아래 스크립트를 실행한다.<br>

```
$ cd ~/workspace/container-platform/paas-ta-container-platform-pipeline-deployment/script
$ chmod +x uninstall-container-platform-pipeline.sh
$ ./uninstall-container-platform-pipeline.sh

```
```
...

replicaset.apps "container-platform-pipeline-common-api-deployment-5d8c66f94c" deleted
replicaset.apps "container-platform-pipeline-config-server-deployment-859fc5fd85" deleted
replicaset.apps "container-platform-pipeline-inspection-api-deployment-56945ffc96" deleted
replicaset.apps "container-platform-pipeline-jenkins-deployment-7466bbf878" deleted
replicaset.apps "container-platform-pipeline-ui-deployment-7698cc79c8" deleted
...
...
namespace "paas-ta-container-platform-pipeline" deleted
...
...
```

<br>
  
## <div id='4'>4. 컨테이너 플랫폼 파이프라인 서비스 브로커
컨테이너 플랫폼 PaaS-TA 서비스 형 파이프라인으로 설치하는 경우 CF와 Kubernetes에 배포된 컨테이너 플랫폼 파이프라인 서비스 연동을 위해서 브로커를 등록해 주어야 한다.
PaaS-TA 운영자 포탈을 통해 서비스를 등록하고 공개하면, PaaS-TA 사용자 포탈을 통해 서비스를 신청하여 사용할 수 있다.
  
## <div id='4.1'>4.1. 컨테이너 플랫폼 파이프라인 사용자 인증 서비스 구성
컨테이너 플랫폼 파이프라인을 서비스로 사용하기 위해서는 **사용자 인증 서비스** 구성이 사전에 진행되어야 한다.<br>
사용자 인증 서비스 구성은 아래 가이드를 참조한다.
> [사용자 인증 서비스 구성](../container-platform-portal/paas-ta-container-platform-portal-deployment-service-guide-v1.2.md#4)      
컨테이너 플랫폼 포탈 사용자 인증 서비스 구성 시, 파이프라인에도 적용된다.

### <div id='4.2'>4.2. 컨테이너 플랫폼 파이프라인 서비스 브로커 등록
:bulb: 해당 내용은 PaaS-TA 포털이 설치된 **BOSH Inception**에서 진행한다.
서비스 브로커 등록 시 개방형 클라우드 플랫폼에서 서비스 브로커를 등록할 수 있는 사용자로 로그인이 되어있어야 한다.

##### 서비스 브로커 목록을 확인한다.
>`$ cf service-brokers` 
```
$ cf service-brokers
Getting service brokers as admin...

name   url
No service brokers found
```
    
    
##### 컨테이너 플랫폼 파이프라인 서비스 브로커를 등록한다.
>`$ cf create-service-broker {서비스팩 이름} {서비스팩 사용자ID} {서비스팩 사용자비밀번호} http://{서비스팩 URL}`

서비스팩 이름 : 서비스 팩 관리를 위해 개방형 클라우드 플랫폼에서 보여지는 명칭<br>
서비스팩 사용자 ID/비밀번호 : 서비스팩에 접근할 수 있는 사용자 ID/비밀번호<br>
서비스팩 URL : 서비스팩이 제공하는 API를 사용할 수 있는 URL<br>


###### 컨테이너 플랫폼 파이프라인 서비스 브로커 등록 
>`$ cf create-service-broker container-platform-pipeline-service-broker admin cloudfoundry http://{K8S_MASTER_NODE_IP}:30083`   


```
$ cf create-service-broker container-platform-pipeline-service-broker admin cloudfoundry http://xx.xxx.xxx.xx:30083
Creating service broker container-platform-pipeline-service-broker as admin...
OK
```    

    
##### 등록된 컨테이너 플랫폼 파이프라인 서비스 브로커를 확인한다.
>`$ cf service-brokers` 
```
$ cf service-brokers 
Getting service brokers as admin... 
name                                         url 
container-platform-pipeline-service-broker   http://xx.xxx.xxx.xx:30083
```

    
##### 접근 가능한 서비스 목록을 확인한다.
>`$ cf service-access`     
```
$ cf service-access 
Getting service access as admin... 
broker: container-platform-pipeline-service-broker 
   offering                      plan                                 access   orgs 
   container-platform-pipeline   container-platform-pipeline-shared   none

```

        
##### 특정 조직에 해당 서비스 접근 허용을 할당한다.

###### 컨테이너 플랫폼 파이프라인 서비스 접근 허용 할당  
>`$ cf enable-service-access container-platform-pipeline`   

```
$ cf enable-service-access container-platform-pipeline 
Enabling access to all plans of service offering container-platform-pipeline for all orgs as admin... 
OK
```
        
##### 접근 가능한 서비스 목록을 확인한다.
>`$ cf service-access` 

```
$ cf service-access 
Getting service access as admin... 
broker: container-platform-pipeline-service-broker 
   offering                      plan                                 access   orgs 
   container-platform-pipeline   container-platform-pipeline-shared   all
```

<br>
    
### <div id='4.3'>4.3. 컨테이너 플랫폼 파이프라인 서비스 조회 설정
해당 설정은 PaaS-TA 포탈에서 컨테이너 플랫폼 파이프라인 서비스를 조회하고 신청할 수 있도록 하기 위한 설정이다.

##### PaaS-TA 운영자 포탈에 접속한다.


##### 메뉴 [운영관리]-[카탈로그] 에서 앱서비스 탭 안에 Container Platform Pipeline 서비스를 선택하여 설정을 변경한다.
![image](https://user-images.githubusercontent.com/80228983/146296230-2e3a90fa-44ac-4e13-9472-dfb3a1655a98.png)

##### Container Platform Pipeline 서비스를 선택하여 아래와 같이 설정 변경 후 저장한다.
>`'서비스' 항목 : 'container-platform-pipeline' 으로 선택` <br>
>`'공개' 항목 : 'Y' 로 체크`    

![image](https://user-images.githubusercontent.com/80228983/146296316-3bbb70d4-ce31-42f6-9ec0-019c0f12d774.png)

##### PaaS-TA 사용자 포탈에 접속한다.

##### 메뉴 [카탈로그]-[서비스] 에서 서비스 탭 안에 Container Platform Pipeline 서비스를 선택하여 서비스를 생성한다.
![image](https://user-images.githubusercontent.com/80228983/146296949-fceac26c-86b6-40fb-b005-dcc84b3f081c.png)

<br>

    
### <div id='4.4'/>4.4. 컨테이너 플랫폼 파이프라인 사용 가이드
- 컨테이너 플랫폼 파이프라인 사용방법은 아래 사용가이드를 참고한다.  
  + [컨테이너 플랫폼 파이프라인 사용 가이드](../../use-guide/pipeline/paas-ta-container-platform-pipeline-use-guide.md)   

<br>

### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Install](https://github.com/PaaS-TA/paas-ta-container-platform/tree/master/install-guide/Readme.md) > Pipeline 설치 가이드