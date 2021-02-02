## Table of Contents

1. [문서 개요](#1)  
 1.1. [목적](#1.1)  
 1.2. [범위](#1.2)  
 1.3. [시스템 구성도](#1.3)  
 1.4. [참고자료](#1.4)  

2. [Container 서비스 설치](#2)  
 2.1. [Prerequisite](#2.1)  
 2.2. [Stemcell 확인](#2.2)  
 2.3. [Deployment 다운로드](#2.3)  
 2.4. [Deployment 파일 수정](#2.4)  
 2.5. [서비스 설치](#2.5)  
 2.6. [서비스 설치 확인](#2.6)

3. [Kubernetes Container 서비스 배포](#3)   
 3.1. [Kubernetes Cluster 설정](#3.1)   
 3.2. [Container 서비스 이미지 업로드](#3.2)   
 3.3. [Secret 생성](#3.3)  
 3.4. [Deployment 배포](#3.4)  

4. [Container 서비스 브로커](#4)  
 4.1. [Container 서비스 브로커 등록](#4.1)  
 4.2. [Container 서비스 UAA Client 등록](#4.2)   
 4.3. [PaaS-TA 포탈에서 Container 서비스 조회 설정](#4.3)      

5. [Jenkins 서비스 브로커(Optional)](#5)   
 5.1. [Kubernetes Cluster 설정](#5.1)   
 5.2. [Deployment 배포](#5.2)  
 5.3. [Jenkins 서비스 브로커 등록](#5.3)   

6. [CVE 조치사항 적용](#6)     

## <div id='1'>1. 문서 개요
### <div id='1.1'>1.1. 목적
본 문서(Container 서비스 설치 가이드)는 Kubernetes를 사용하기 위해 Bosh 기반 Release의 설치 및 서비스 등록 방법을 기술하였다.

PaaS-TA 3.5 버전부터는 Bosh 2.0 기반으로 배포(deploy)를 진행한다.

### <div id='1.2'>1.2. 범위
설치 범위는 Kubernetes 서비스 배포를 기준으로 작성하였다.

### <div id='1.3'>1.3. 시스템 구성도
시스템 구성은 Kubernetes Cluster(Master, Worker)와 BOSH Inception(DBMS, HAproxy, Private Registry)환경으로 구성되어 있다.<br>
Kubespary를 통해 Kubernetes Cluster를 설치하고 BOSH release로 Database, Private registry 등 미들웨어 환경을 제공하여 Docker Image로 Kubernetes Cluster에 서비스 환경을 배포한다. 
PaaS-TA Container Service를 통해 Kubernetes Cluster에 배포된 서비스를 등록하여 서비스 포털 환경을 사용한다. 총 필요한 VM 환경으로는 Master VM: 1개, Worker VM: 1개 이상, Inception VM: 1개가 필요하며 본 문서는 Inception 환경을 구성하기 위한 VM설치와 Kubernetes Cluster에 Container 서비스를 배포하는 내용이다.

![image 001]

### <div id='1.4'>1.4. 참고 자료
> http://bosh.io/docs
> http://docs.cloudfoundry.storage

## <div id='2'>2. Container 서비스 설치
### <div id='2.1'>2.1. Prerequisite
본 설치 가이드는 Ubuntu환경에서 설치하는 것을 기준으로 작성하였다. 서비스 설치를 위해서는 BOSH 2.0과 PaaS-TA 5.5, PaaS-TA 포털 API, PaaS-TA 포털 UI가 설치 되어 있어야 한다.
- [BOSH 2.0 설치 가이드](https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/working-5.1/install-guide/bosh/PAAS-TA_BOSH2_INSTALL_GUIDE_V5.0.md)
- [PaaS-TA 5.5 설치 가이드](https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/working-5.1/install-guide/paasta/PAAS-TA_CORE_INSTALL_GUIDE_V5.0.md)
- [PaaS-TA 포털 API 설치 가이드](https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/working-5.1/install-guide/portal/PAAS-TA_PORTAL_API_SERVICE_INSTALL_GUIDE_V1.0.md)
- [PaaS-TA 포털 UI 설치 가이드](https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/working-5.1/install-guide/portal/PAAS-TA_PORTAL_UI_SERVICE_INSTALL_GUIDE_V1.0.md)

### <div id='2.2'>2.2. Stemcell 확인
Stemcell 목록을 확인하여 서비스 설치에 필요한 Stemcell 이 업로드 되어 있는 것을 확인한다. (PaaS-TA 5.5 와 동일 Stemcell 사용)
- Stemcell 업로드 및 Cloud Config, Runtime Config 설정 부분은 [PaaS-TA 5.5 설치가이드](https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/working-5.1/install-guide/paasta/PAAS-TA_CORE_INSTALL_GUIDE_V5.0.md)를 참고 한다.
> $ bosh -e micro-bosh stemcells
```
Using environment '10.0.1.6' as client 'admin'

Name                                     Version  OS             CPI  CID
bosh-aws-xen-hvm-ubuntu-xenial-go_agent  621.94   ubuntu-xenial  -    ami-0694eb07c57faca73

(*) Currently deployed

1 stemcells

Succeeded
```

### <div id='2.3'>2.3. Deployment 다운로드
서비스 설치에 필요한 Deployment를 Git Repository에서 받아 서비스 설치 작업 경로로 위치시킨다.   
- Container Platform Deployment Git Repository URL : <br> https://github.com/PaaS-TA/paas-ta-container-platform-deployment/tree/dev

```
# Deployment 다운로드 파일 위치 경로 생성 및 이동
$ mkdir -p ~/workspace/paasta/deployment/
$ cd ~/workspace/paasta/deployment/

# Deployment 다운로드
$ git clone -b dev --single-branch https://github.com/PaaS-TA/paas-ta-container-platform-deployment.git

# bosh 배포 경로로 이동
$ cd paas-ta-container-platform-deployment/bosh/
```

### <div id='2.4'>2.4. Deployment 파일 수정
BOSH Deployment manifest는 Components 요소 및 배포의 속성을 정의한 YAML 파일이다. Deployment 파일에서 사용하는 network, vm_type, disk_type 등은 Cloud config를 활용하고, 활용 방법은 BOSH 2.0 가이드를 참고한다.
- Cloud config 설정 내용을 확인한다.
> $ bosh -e micro-bosh cloud-config
```
Using environment '10.0.1.6' as client 'admin'

azs:
- cloud_properties:
    availability_zone: ap-northeast-2a
  name: z1
- cloud_properties:
    availability_zone: ap-northeast-2a
  name: z2

... ((생략)) ...

disk_types:
- disk_size: 1024
  name: default
- disk_size: 1024
  name: 1GB

... ((생략)) ...

networks:
- name: default
  subnets:
  - az: z1
    cloud_properties:
      security_groups: paasta-security-group
      subnet: subnet-00000000000000000
    dns:
    - 8.8.8.8
    gateway: 10.0.1.1
    range: 10.0.1.0/24
    reserved:
    - 10.0.1.2 - 10.0.1.9
    static:
    - 10.0.1.10 - 10.0.1.120

... ((생략)) ...

vm_types:
- cloud_properties:
    ephemeral_disk:
      size: 3000
      type: gp2
    instance_type: t2.small
  name: minimal
- cloud_properties:
    ephemeral_disk:
      size: 10000
      type: gp2
    instance_type: t2.small
  name: small

... ((생략)) ...

Succeeded
```

> 일부 application의 경우 이중화를 위한 조치는 되어 있지 않으며 인스턴스 수 조정 시 신규로 생성되는 인스턴스에는 데이터의 반영이 안될 수 있으니, 1개의 인스턴스로 유지한다.

- Deployment YAML에서 사용하는 변수 파일을 서버 환경에 맞게 수정한다.
> $ vi ~/workspace/paasta/deployment/paas-ta-container-platform-deployment/bosh/manifests/paasta-container-service-vars-{IAAS}.yml
(e.g. {IAAS} :: aws)

> IPS - k8s_api_server_ip : Kubernetes Master Node Public IP<br>
  IPS - k8s_auth_bearer : [Kubespray 설치 가이드 - 4.1. Cluster Role 운영자 생성 및 Token 획득](https://github.com/PaaS-TA/paas-ta-container-platform/blob/dev/install-guide/standalone/paas-ta-container-platform-standalone-deployment-guide-v1.0.md#4.1)

```
# INCEPTION OS USER NAME
inception_os_user_name: "ubuntu"

# REQUIRED FILE PATH VARIABLE
paasta_version: "5.5"

# RELEASE
container_platform_release_name: "paasta-container-platform"
container_platform_release_version: "1.0"

# IAAS
kubernetes_cluster_tag: 'kubernetes'                                                # Do not update!

# STEMCELL
stemcell_os: "ubuntu-xenial"                                                        # stemcell os
stemcell_version: "621.94"                                                          # stemcell version
stemcell_alias: "xenial"                                                            # stemcell alias

# CREDHUB
credhub_server_url: "10.0.1.6:8844"
credhub_admin_client_secret: "eft2zkfaerzyt8g6eonj"

# VM_TYPE
vm_type_small: "small"                                                              # vm type small
vm_type_small_highmem_16GB: "small-highmem-16GB"                                    # vm type small highmem
vm_type_small_highmem_16GB_100GB: "small-highmem-16GB"                              # vm type small highmem_100GB
vm_type_container_small: "small"                                                    # vm type small for caas's etc
vm_type_container_small_api: "small"                                                # vm type small for caas's api

# NETWORK
service_private_nat_networks_name: "default"                                        # private network name
service_private_networks_name: "default"
service_public_networks_name: "vip"                                                 # public network name

# IPS
haproxy_public_url: "<HAPROXY_IP>"                                                  # haproxy's public IP
k8s_api_server_ip: "<KUBERNETES_API_SERVER_IP>"                                     # kubernetes master node IP
k8s_api_server_port: "6443"                                                      
k8s_auth_bearer: "<KUBERNETES_AUTH_KEY>"                                            # kubernetes bearer token

# HAPROXY
haproxy_http_port: 8080                                                             # haproxy port
haproxy_azs: [z7]                                                                   # haproxy azs

# MARIADB
mariadb_port: "13306"                                                               # mariadb port (e.g. 13306)-- Do Not Use "3306"
mariadb_azs: [z5]                                                                   # mariadb azs
mariadb_persistent_disk_type: "10GB"                                                # mariadb persistent disk type
mariadb_admin_user_id: "cp-admin"                                                   # mariadb admin user name (e.g. cp-admin)
mariadb_admin_user_password: "PaaS-TA@2020"                                         # mariadb admin user password (e.g. PaaS-TA@2020)
mariadb_role_set_administrator_code_name: "Administrator"                           # administrator role's code name (e.g. Administrator)
mariadb_role_set_administrator_code: "RS0001"                                       # administrator role's code (e.g. RS0001)
mariadb_role_set_regular_user_code_name: "Regular User"                             # regular user role's code name (e.g. Regular User)
mariadb_role_set_regular_user_code: "RS0002"                                        # regular user role's code (e.g. RS0002)
mariadb_role_set_init_user_code_name: "Init User"                                   # init user role's code name (e.g. Init User)
mariadb_role_set_init_user_code: "RS0003"                                           # init user role's code (e.g. RS0003)

# PRIVATE IMAGE REPOSITORY
private_image_repository_azs: [z7]                                                   # private image repository azs
private_image_repository_port: 5001                                                  # private image repository port (e.g. 5001)-- Do Not Use "5000"
private_image_repository_root_directory: "/var/vcap/data/private-image-repository"   # private image repository root directory
private_image_repository_persistent_disk_type: "10GB"                                # private image repository's persistent disk type

```
- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정한다.
> $ vi ~/workspace/paasta/deployment/paas-ta-container-platform-deployment/bosh/deploy-{IAAS}.sh  
(e.g. {IAAS} :: aws)

```    
#!/bin/bash

# SET VARIABLES
export CONTAINER_DEPLOYMENT_NAME='paasta-container-platform'   # deployment name
export CONTAINER_BOSH2_NAME='micro-bosh'                       # bosh name (e.g. micro-bosh)
export CONTAINER_BOSH2_UUID=`bosh int <(bosh -e ${CONTAINER_BOSH2_NAME} environment --json) --path=/Tables/0/Rows/0/uuid`

# DEPLOY
bosh -e ${CONTAINER_BOSH2_NAME} -n -d ${CONTAINER_DEPLOYMENT_NAME} deploy --no-redact manifests/paasta-container-service-deployment-aws.yml \
    -l manifests/paasta-container-service-vars-aws.yml \
    -o manifests/ops-files/paasta-container-service/network-aws.yml \
    -o manifests/ops-files/misc/first-time-deploy.yml \
    -v deployment_name=${CONTAINER_DEPLOYMENT_NAME} \
    -v director_name=${CONTAINER_BOSH2_NAME} \
    -v director_uuid=${CONTAINER_BOSH2_UUID}
```

### <div id='2.5'>2.5. 서비스 설치

- 서비스 설치에 필요한 릴리스 파일을 다운로드 받아 Local machine의 서비스 설치 작업 경로로 위치시킨다.  
  + 설치 릴리즈 파일 다운로드 :  
  [paasta-container-platform-1.0.tgz](http://45.248.73.44/index.php/s/zYjJg9yffxwSbFT/download)  
       
```
# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta/release/service
$ cd ~/workspace/paasta/release/service

# 릴리즈 파일 다운로드 및 파일 경로 확인
$ wget --content-disposition http://45.248.73.44/index.php/s/zYjJg9yffxwSbFT/download
$ ls ~/workspace/paasta/release/service
  paasta-container-platform-1.0.tgz  
```

- 서비스를 설치한다.
```
$ cd ~/workspace/paasta/deployment/paas-ta-container-platform-deployment/bosh
$ chmod +x *.sh
$ ./deploy-{IAAS}.sh
```

### <div id='2.6'>2.6. 서비스 설치 확인
설치 완료된 서비스를 확인한다.
> $ bosh -e micro-bosh -d paasta-container-platform vms

```
Using environment '10.0.1.6' as client 'admin'

Task 2983. Done

Deployment 'paasta-container-platform'

Instance                                                       Process State  AZ  IPs           VM CID               VM Type  Active
haproxy/cbd5d103-765d-47e0-ac5b-233a21108c77                   running        z7  10.0.0.122    i-0f49ce7431aaa2901  small    true
                                                                                  15.164.15.53
mariadb/448be54d-f2ff-4fc9-8bf1-621eda8e2577                   running        z5  10.0.161.121  i-09b27b184b7aea066  small    true
private-image-repository/561550fb-95de-4c12-95bf-94ac5fde53cc  running        z7  10.0.0.123    i-02ff1da176d1d0a16  small    true

3 vms

Succeeded
```

## <div id='3'>3. Kubernetes Container 서비스 배포
kubernetes에서 PaaS-TA용 Container 서비스를 사용하기 위해서는 Bosh Release 배포 후 Private Repository에 등록된 이미지를 Kubernetes에 배포하여 사용하여야 한다.

### <div id='3.1'>3.1. K8s Cluster 설정
> Container 서비스 배포용 Kubernetes Master Node, Worker Node에서 daemon.json 에 insecure-registries 로 Private Image Repository URL 설정 후 Docker를 재시작한다.

```
$ sudo vi /etc/docker/daemon.json
{
        "insecure-registries": ["{HAProxy_IP}:5001"]
}

# docker 재시작
$ sudo systemctl restart docker
```

### <div id='3.2'>3.2. Container 서비스 이미지 업로드
Private Repository에 이미지 등록을 위해 Container 서비스 이미지 파일을 다운로드 받아 아래 경로로 위치시킨다.<br>
해당 내용은 Kubernetes Master Node에서 실행한다.
 
+ Container 서비스 이미지 파일 다운로드 :  
   [cp-caas-images.tar](http://45.248.73.44/index.php/s/Dakicxt9jBkX56A/download)  

```
# 이미지 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta/container-platform
$ cd ~/workspace/paasta/container-platform

# 이미지 파일 다운로드 및 파일 경로 확인
$ wget --content-disposition http://45.248.73.44/index.php/s/Dakicxt9jBkX56A/download

$ ls ~/workspace/paasta/container-platform
  cp-caas-images.tar

# 이미지 다운로드 파일 압축 해제
$ tar -xvf cp-caas-images.tar
$ cd ~/workspace/paasta/container-platform/container-service-image
$ ls ~/workspace/paasta/container-platform/container-service-image
  container-jenkins-broker.tar.gz  container-service-broker.tar.gz      container-service-dashboard.tar.gz  paasta-jenkins.tar.gz
  container-service-api.tar.gz     container-service-common-api.tar.gz  image_upload_caas.sh 
 ```
 
 + Private Repository에 이미지를 업로드한다.
 ```
 $ chmod +x *.sh  
 $ ./image_upload_caas.sh {HAProxy_IP}:5001 
 ```
 
 + Private Repository에 업로드 된 이미지 목록을 확인한다.
 
 ```
 $ curl -H 'Authorization:Basic YWRtaW46YWRtaW4=' http://{HAProxy_IP}:5001/v2/_catalog
 
 {"repositories":["container-jenkins-broker","container-service-api","container-service-broker","container-service-common-api","container-service-dashboard","paasta_jenkins"]} 
```


### <div id='3.3'>3.3. Secret 생성
Private Repository에 등록된 이미지를 활용하기 위해 Kubernetes에 secret을 생성한다.
```
$ kubectl create secret docker-registry cp-secret --docker-server={HAProxy_IP}:5001 --docker-username=admin --docker-password=admin --namespace=default
```


### <div id='3.4'>3.4. Deployment 배포
PaaS-TA 사용자포탈에서 Container 서비스를 추가하기 전 Kubernetes에 아래의 Container Service Deployment가 미리 배포되어 있어야 한다.

- Container Platform yaml 파일 경로이동
```
$ cd ~/workspace/paasta/container-platform/container-service-yaml
$ ls ~/workspace/paasta/container-platform/container-service-yaml
  container-jenkins-broker.yml  container-service-broker.yml      container-service-dashboard.yml
  container-service-api.yml     container-service-common-api.yml
```

- container-service-common-api 배포

> $ vi container-service-common-api.yml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: service-common-api-deployment
  labels:
    app: service-common-api
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: service-common-api
  template:
    metadata:
      labels:
        app: service-common-api
    spec:
      containers:
      - name: service-common-api
        image: {HAProxy_IP}:5001/container-service-common-api:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 3334
        env:
        - name: HAPROXY_IP
          value: {HAProxy_IP}
        - name: MARIADB_USER_ID
          value: {MARIADB_USER_ID}           # (e.g. cp-admin)
        - name: MARIADB_USER_PASSWORD
          value: {MARIADB_USER_PASSWORD}     # (e.g. PaaS-TA@2020)          
        - name: MARIADB_PORT
          value: "13306"  
      imagePullSecrets:
        - name: cp-secret
---
apiVersion: v1
kind: Service
metadata:
  name: service-common-api-deployment
  labels:
    app: service-common-api
  namespace: default
spec:
  ports:
  - nodePort: 30334
    port: 3334
    protocol: TCP
    targetPort: 3334
  selector:
    app: service-common-api
  type: NodePort
```

- container-service-api 배포

> $ vi container-service-api.yml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: service-api-deployment
  labels:
    app: service-api
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: service-api
  template:
    metadata:
      labels:
        app: service-api
    spec:
      containers:
      - name: service-api
        image: {HAProxy_IP}:5001/container-service-api:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 3333
        env:
        - name: K8S_IP
          value: {K8S_IP}
      imagePullSecrets:
        - name: cp-secret
---
apiVersion: v1
kind: Service
metadata:
  name: service-api-deployment
  labels:
    app: service-api
  namespace: default
spec:
  ports:
  - nodePort: 30333
    port: 3333
    protocol: TCP
    targetPort: 3333
  selector:
    app: service-api
  type: NodePort
```

- container-service-dashboard 배포

> $ vi container-service-dashboard.yml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: service-dashboard-deployment
  labels:
    app: service-dashboard
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: service-dashboard
  template:
    metadata:
      labels:
        app: service-dashboard
    spec:
      containers:
      - name: service-dashboard
        image: {HAProxy_IP}:5001/container-service-dashboard:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8091
        env:
        - name: K8S_IP
          value: {K8S_IP}
        - name: SYSTEM_DOMAIN
          value: {PAASTA_SYSTEM_DOMAIN}
        - name: HAPROXY_IP
          value: {HAProxy_IP}
      imagePullSecrets:
        - name: cp-secret
---
apiVersion: v1
kind: Service
metadata:
  name: service-dashboard-deployment
  labels:
    app: service-dashboard
  namespace: default
spec:
  ports:
  - nodePort: 32091
    port: 8091
    protocol: TCP
    targetPort: 8091
  selector:
    app: service-dashboard
  type: NodePort
```

- container-service-broker 배포

> $ vi container-service-broker.yml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: service-broker-deployment
  labels:
    app: service-broker
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: service-broker
  template:
    metadata:
      labels:
        app: service-broker
    spec:
      containers:
      - name: service-broker
        image: {HAPROXY_IP}:5001/container-service-broker:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8091
        env:
        - name: K8S_IP
          value: {K8S_IP}
        - name: K8S_PORT
          value: "6443"
        - name: K8S_AUTH_BEARER
          value: {K8S_AUTH_BEARER}
        - name: HAPROXY_IP
          value: {HAPROXY_IP}
        - name: MARIADB_USER_ID
          value: {MARIADB_USER_ID}           # (e.g. cp-admin)
        - name: MARIADB_USER_PASSWORD
          value: {MARIADB_USER_PASSWORD}     # (e.g. PaaS-TA@2020)    
        - name: COMMON_API_ID
          value: admin
        - name: COMMON_API_PASSWORD
          value: PaaS-TA
        - name: LOGGGING_LEVEL
          value: INFO
        - name: REGISTRY_PORT
          value: "5001"
        - name: MARIADB_PORT
          value: "13306"
      imagePullSecrets:
        - name: cp-secret
---
apiVersion: v1
kind: Service
metadata:
  name: service-broker-deployment
  labels:
    app: service-broker
  namespace: default
spec:
  ports:
  - nodePort: 31888
    port: 8888
    protocol: TCP
    targetPort: 8888
  selector:
    app: service-broker
  type: NodePort
```

```
$ kubectl apply -f container-service-common-api.yml
deployment.apps/service-common-api-deployment created
service/service-common-api-deployment created

$ kubectl apply -f container-service-api.yml
deployment.apps/service-api-deployment created
service/service-api-deployment created

$ kubectl apply -f container-service-dashboard.yml
deployment.apps/service-dashboard-deployment created
service/service-dashboard-deployment created

$ kubectl apply -f container-service-broker.yml
deployment.apps/service-deployment-deployment created
service/service-deployment-deployment created
```
- 배포 확인

배포된 Deployment, Pod, Service를 확인한다.

```
#Deployment 배포 정상 확인
$ kubectl get deployments
NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
service-api-deployment          1/1     1            1           68s
service-common-api-deployment   1/1     1            1           78s
service-dashboard-deployment    1/1     1            1           56s
service-broker-deployment       1/1     1            1           112s

#Pod 배포 정상 확인
$ kubectl get pods
NAME                                            READY   STATUS    RESTARTS   AGE
service-api-deployment-7c556d9c59-ms66r         1/1     Running   0          97s
service-common-api-deployment-689cdc8df-dxsnb   1/1     Running   0          108s
service-dashboard-deployment-d4b5fdcdb-nwrgf    1/1     Running   0          85s
service-broker-deployment-7fb5dd69f6-pdhnq      1/1     Running   0          26h

#Service 배포 정상 확인
$ kubectl get svc
NAME                            TYPE        CLUSTER-IP        EXTERNAL-IP   PORT(S)          AGE
kubernetes                      ClusterIP   xxx.xxx.xxx.xxx   <none>        443/TCP          3d19h
service-api-deployment          NodePort    xxx.xxx.xxx.xxx   <none>        3333:30333/TCP   117s
service-common-api-deployment   NodePort    xxx.xxx.xxx.xxx   <none>        3334:30334/TCP   2m8s
service-dashboard-deployment    NodePort    xxx.xxx.xxx.xxx   <none>        8091:32091/TCP   105s
service-broker-deployment       NodePort    xxx.xxx.xxx.xxx   <none>        8888:31888/TCP   118s

```

## <div id='4'>4. Container 서비스 브로커
Container 서비스 형태로 설치하는 경우에 CF와 배포된 K8s와의 연동을 위해서는 Container 서비스 브로커를 등록해 주어야 한다. PaaS-TA 운영자 포탈을 통해 서비스를 등록하고 공개하면, PaaS-TA 사용자 포탈을 통해 서비스를 신청하여 사용할 수 있다.

### <div id='4.1'>4.1. Container 서비스 브로커 등록

서비스 브로커 등록 시 개방형 클러스터 플랫폼에서 서비스 브로커를 등록할 수 있는 사용자로 로그인이 되어 있어야 한다.


- 서비스 브로커 목록을 확인한다.

 ```
$ cf service-brokers
Getting service brokers as admin...

name                               url
mysql-service-broker               http://10.0.121.71:8080
 ```
  - Container 서비스 브로커를 등록한다.
  > $ create-service-broker {서비스팩 이름} {서비스팩 사용자ID} {서비스팩 사용자비밀번호} http://{K8S_IP}:31888
  > - 서비스팩 이름 : 서비스 팩 관리를 위해 개방형 클라우드 플랫폼에서 보여지는 명칭
  > - 서비스팩 사용자 ID/비밀번호 : 서비스팩에 접근할 수 있는 사용자 ID/비밀번호
  > - 서비스팩 URL : Kubernetes Master Node Public IP 와 배포된 Container 서비스 브로커 NodePort
   ```
  $ cf create-service-broker container-service-broker admin cloudfoundry http://{K8S_IP}:31888
   ```
 - 등록된 Container 서비스 브로커를 확인한다.
  ```
  $ cf service-brokers
Getting service brokers as admin...

name                       url
container-service-broker   http://xxx.xxx.xxx.xxx:31888
mysql-service-broker       http://10.0.121.71:8080
```
- 접근 가능한 서비스 목록을 확인한다.
```
$ cf service-access
Getting service access as admin...
broker: container-service-broker
   service             plan       access   orgs
   container-service   Advanced   none      
   container-service   Micro      none      
   container-service   Small      none      

broker: mysql-service-broker
   service    plan                 access   orgs
   Mysql-DB   Mysql-Plan1-10con    all      
   Mysql-DB   Mysql-Plan2-100con   all
```
 - 특정 조직에 해당 서비스 접근 허용을 할당한다.
```
$ cf enable-service-access container-service
Enabling access to all plans of service container-service for all orgs as admin...
OK
```
- 접근 가능한 서비스 목록을 확인한다.
```
$ cf service-access
Getting service access as admin...
broker: container-service-broker
   service             plan       access   orgs
   container-service   Advanced   all      
   container-service   Micro      all      
   container-service   Small      all      

broker: mysql-service-broker
   service    plan                 access   orgs
   Mysql-DB   Mysql-Plan1-10con    all      
   Mysql-DB   Mysql-Plan2-100con   all    
```

### <div id='4.2'> 4.2. Container 서비스 UAA Client 등록
UAA 포털 계정 등록 절차에 대한 순서를 확인한다.

- uaac server의 endpoint를 설정한다.

```
# endpoint 설정
$ uaac target https://uaa.<DOMAIN> --skip-ssl-validation

# target 확인
$ uaac target
Target: https://uaa.<DOMAIN>
Context: uaa_admin, from client uaa_admin

```

- uaac 로그인을 한다.

```
$ uaac token client get <UAA_ADMIN_CLIENT_ID> -s <UAA_ADMIN_CLIENT_SECRET>
Successfully fetched token via client credentials grant.
Target: https://uaa.<DOMAIN>
Context: admin, from client admin
```

- Container 서비스 계정 생성을 한다.

> $ uaac client add caasclient -s {클라이언트 비밀번호} --redirect_uri {http://<Kubernetes Master Node의 Public IP>:32091} --scope {퍼미션 범위} --authorized_grant_types {권한 타입} --authorities={권한 퍼미션} --autoapprove={자동승인권한}
  - <CF_UAA_CLIENT_ID> : uaac 클라이언트 id  
  - <CF_UAA_CLIENT_SECRET> : uaac 클라이언트 secret  
  - <Container 서비스 URI> : 성공적으로 리다이렉션 할 Container 서비스 접근 URI (http://<Kubernetes Master Node의 Public IP>:<Container 서비스 Dashboard의 NodePort>)  
  - <퍼미션 범위> : 클라이언트가 사용자를 대신하여 얻을 수있는 허용 범위 목록  
  - <권한 타입> : 서비스가 제공하는 API를 사용할 수 있는 권한 목록  
  - <권한 퍼미션> : 클라이언트에 부여 된 권한 목록  
  - <자동승인권한> : 사용자 승인이 필요하지 않은 권한 목록

```  
# e.g. Container 서비스 계정 생성
$ uaac client add caasclient -s clientsecret --redirect_uri "http://xxx.xxx.xxx.xxx:32091" --scope "cloud_controller_service_permissions.read , openid , cloud_controller.read , cloud_controller.write , cloud_controller.admin" --authorized_grant_types "authorization_code , client_credentials , refresh_token" --authorities="uaa.resource" --autoapprove="openid , cloud_controller_service_permissions.read"

# e.g. Container 서비스 계정 생성 확인
$ uaac clients
caasclient
    scope: cloud_controller.read cloud_controller.write cloud_controller_service_permissions.read openid cloud_controller.admin
    resource_ids: none
    authorized_grant_types: refresh_token client_credentials authorization_code
    redirect_uri: http://xxx.xxx.xxx.xxx:32091
    autoapprove: cloud_controller_service_permissions.read openid
    authorities: uaa.resource
    name: caasclient
    lastmodified: 1592962300888

```  

### <div id='4.3'>4.3. PaaS-TA 포탈에서 Container 서비스 조회 설정

 해당 설정은 PaaS-TA 포탈에 Container 서비스 상의 자원들을 간략하게 조회하기 위한 설정이다.

  1. PaaS-TA Admin 포탈에 접속한다.

  ![image 002]

  2. 왼쪽 네비게이션 바에서 [설정]-[설정정보] 를 클릭한 후 나타나는 페이지의 오른쪽 상단 [인프라 등록] 버튼을 클릭하여 해당 정보들을 입력한다.
   - 해당 정보를 입력하기 위해 필요한 값들을 찾는다.
   > $ bosh -e micro-bosh -d portal-api vms
    > haproxy의 IP를 찾아 Portal_Api_Uri에 입력한다.

```
Deployment 'paasta-portal-api'

Instance                                                          Process State  AZ  IPs            VM CID               VM Type        Active
binary_storage/acfc944b-19b9-487e-a447-c42cb2342f62               running        z6  10.0.201.122   i-0af1de35c9669d11a  portal_small   true
haproxy/8518a6c5-6ede-409d-8e51-39e8d2ecb39b                      running        z7  10.0.0.122     i-05613be8862607959  small          true
                                                                                     52.78.144.229
mariadb/d32412d3-ea66-42af-a714-9ce2af4416a5                      running        z6  10.0.201.121   i-0e6971c85e17575a5  portal_small   true
paas-ta-portal-api/992a0ca4-7857-4bc7-9e57-edc1d1ad643e           running        z6  10.0.201.125   i-0b2b78182049beec2  portal_medium  true
paas-ta-portal-common-api/895ffa41-b401-4abb-8316-ae3bc42b3e57    running        z6  10.0.201.126   i-0fa5873ed9092a4f8  portal_small   true
paas-ta-portal-gateway/107836f5-e07d-446f-bc24-d727a388e16a       running        z6  10.0.201.123   i-067c248baed2d807a  portal_small   true
paas-ta-portal-log-api/301d0a23-eccc-4565-9ff6-8dac9b113440       running        z6  10.0.201.128   i-045efbc8cd9f32dfd  portal_small   true
paas-ta-portal-registration/d70189cc-aacb-43da-876f-7fe551797792  running        z6  10.0.201.124   i-0e07cb4f02250316d  portal_small   true
paas-ta-portal-storage-api/20170f06-6b5b-4421-8238-9cac7a276618   running        z6  10.0.201.127   i-0b0ab24792fd3aa4d  portal_small   true

9 vms
```

  > $ bosh -e micro-bosh -d paasta-container-platform vms
    > haproxy의 IP를 찾아 CaaS_Api_Uri에 입력한다.

```
Deployment 'paasta-container-platform'

Instance                                                       Process State  AZ  IPs           VM CID               VM Type  Active
haproxy/cbd5d103-765d-47e0-ac5b-233a21108c77                   running        z7  10.0.0.122    i-0f49ce7431aaa2901  small    true
                                                                                  15.164.15.53
mariadb/448be54d-f2ff-4fc9-8bf1-621eda8e2577                   running        z5  10.0.161.121  i-09b27b184b7aea066  small    true
private-image-repository/561550fb-95de-4c12-95bf-94ac5fde53cc  running        z7  10.0.0.123    i-02ff1da176d1d0a16  small    true

3 vms

```

```
ex)
- NAME : PaaS-TA 5.0 (Openstack)
- Portal_Api_Uri : http://<portal_haproxy_IP>:2225
- UAA_Uri : https://api.<CF DOMAIN>
- Authorization : Basic YWRtaW46b3BlbnBhYXN0YQ==
- 설명 : PaaS-TA 5.0 install infra
- CaaS_Api_Uri : http://<container_service_haproxy_IP>
- CaaS_Authorization : Basic YWRtaW46UGFhUy1UQQ==
```



![image 003]

[운영관리]-[카탈로그] 메뉴에서 앱서비스 탭 안에 CaaS서비스를 선택 > 서비스항목을 Container_service로 변경 후 저장한다.

![image 004]
## <div id='5'>5. Jenkins 서비스 브로커(Optional)
해당 설정은 jenkins 서비스를 이용하기 위한 설정이다.

### <div id='5.1'>5.1. Kubernetes Cluster 설정
> Container 서비스 배포용 Kubernetes Master Node, Worker Node에서 daemon.json 에 insecure-registries 로 Private Image Repository URL 설정 후 Docker를 재시작한다.
```
$ sudo vi /etc/docker/daemon.json
{
        "insecure-registries": ["{HAProxy_IP}:5001"]
}

# docker 재시작
$ sudo systemctl restart docker
```

### <div id='5.2'>5.2. Deployment 배포
> PaaS-TA 사용자포탈에서 Jenkins 서비스를 추가하기 전 Kubernetes에 Jenkins 서비스 Deployment가 미리 배포되어 있어야 한다.

- Container Platform yaml 파일 경로이동
```
$ cd ~/workspace/paasta/container-platform/container-service-yaml
$ ls ~/workspace/paasta/container-platform/container-service-yaml
  container-jenkins-broker.yml  container-service-broker.yml      container-service-dashboard.yml
  container-service-api.yml     container-service-common-api.yml
```
-  container-jenkins-broker 배포

> $ vi container-jenkins-broker.yml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins-broker-deployment
  labels:
    app: jenkins-broker
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins-broker
  template:
    metadata:
      labels:
        app: jenkins-broker
    spec:
      containers:
      - name: jenkins-broker
        image: {HAPROXY_IP}:5001/container-jenkins-broker:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8091
        env:
        - name: K8S_IP
          value: {K8S_IP}
        - name: K8S_PORT
          value: "6443"
        - name: K8S_AUTH_BEARER
          value: {K8S_AUTH_BEARER}
        - name: HAPROXY_IP
          value: {HAPROXY_IP}
        - name: MARIADB_USER_ID
          value: {MARIADB_USER_ID}           # (e.g. cp-admin)
        - name: MARIADB_USER_PASSWORD
          value: {MARIADB_USER_PASSWORD}     # (e.g. PaaS-TA@2020)    
        - name: REGISTRY_PORT
          value: "5001"
        - name: MARIADB_PORT
          value: "13306"
      imagePullSecrets:
        - name: cp-secret
---
apiVersion: v1
kind: Service
metadata:
  name: jenkins-broker-deployment
  labels:
    app: jenkins-broker
  namespace: default
spec:
  ports:
  - nodePort: 31787
    port: 8787
    protocol: TCP
    targetPort: 8787
  selector:
    app: jenkins-broker
  type: NodePort
```

```
$ kubectl apply -f container-jenkins-broker.yml
deployment.apps/jenkins-broker-deployment created
service/jenkins-broker-deployment created
```

- 배포 확인

배포된 Deployment, Pod, Service를 확인한다.

```
#Deployment 배포 정상 확인
$ kubectl get deployments
NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
jenkins-broker-deployment       1/1     1            1           2m20s

#Pod 배포 정상 확인
$ kubectl get pods
NAME                                             READY   STATUS    RESTARTS   AGE
jenkins-broker-deployment-7f84f69cf8-wgzbv       1/1     Running   0          2m30s

#Service 배포 정상 확인
$ kubectl get svc
NAME                            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
jenkins-broker-deployment       NodePort    10.233.9.92     <none>        8787:31787/TCP   2m49s

```

### <div id='5.3'>5.3. Jenkins 서비스 브로커 등록

- 브로커 목록을 확인한다.

```
$ cf service-brokers
Getting service brokers as admin...

name                       url
container-service-broker   http://xxx.xxx.xxx.xxx:31888
```
 - Jenkins 서비스 브로커를 등록한다.
> $ create-service-broker {서비스팩 이름} {서비스팩 사용자ID} {서비스팩 사용자비밀번호} http://{K8S_IP}:31787
> - 서비스팩 이름 : 서비스 팩 관리를 위해 개방형 클라우드 플랫폼에서 보여지는 명칭
> - 서비스팩 사용자 ID/비밀번호 : 서비스팩에 접근할 수 있는 사용자 ID/비밀번호
> - 서비스팩 URL : Kubernetes Master Node Public IP 와 배포된 Jenkins 서비스 브로커 NodePort
 ```
$ cf create-service-broker jenkins-service-broker admin cloudfoundry http://{K8S_IP}:31787
 ```
  - 등록된 Jenkins 서비스 브로커를 확인한다.
 ```
 $ cf service-brokers
Getting service brokers as admin...

name                       url
container-service-broker   http://xxx.xxx.xxx.xxx:31888
jenkins-service-broker     http://xxx.xxx.xxx.xxx:31787
```
- 접근 가능한 서비스 목록을 확인한다.
```
$ cf service-access
Getting service access as admin...
broker: container-service-broker
  service             plan       access   orgs
  container-service   Advanced   all      
  container-service   Micro      all      
  container-service   Small      all      

broker: jenkins-service-broker
  service                     plan                        access   orgs
  container-jenkins-service   jenkins_20GB                limit
```
- 특정 조직에 해당 서비스 접근 허용을 할당한다.
```
$ cf enable-service-access container-jenkins-service
Enabling access to all plans of service container-jenkins-service for all orgs as admin...
OK
```
- 접근 가능한 서비스 목록을 확인한다.
```
$ cf service-access
Getting service access as admin...
broker: container-service-broker
  service             plan       access   orgs
  container-service   Advanced   all      
  container-service   Micro      all      
  container-service   Small      all      

broker: jenkins-service-broker
  service                     plan                     access   orgs
  container-jenkins-service   jenkins_20GB             all      
```

## <div id='6'>6. CVE 조치사항 적용  
#### TCP timestamp responses 비활성화 설정  
- /etc/sysctl.conf 파일 설정 변경, iptables에 정책 추가
```
 $ sudo vi /etc/sysctl.conf
 ----------------------------------------
 ## Add at the bottom
 net.ipv4.tcp_timestamps=0
 ----------------------------------------
 $ sudo reboot

 # iptables에 정책 추가
 $ sudo iptables -A INPUT -p icmp --icmp-type timestamp-request -j DROP
 $ sudo iptables -A OUTPUT -p icmp --icmp-type timestamp-reply -j DROP
```

----
[image 001]:images/cp-001.png
[image 002]:images/cp-002.png
[image 003]:images/cp-003.png
[image 004]:images/cp-004.png
