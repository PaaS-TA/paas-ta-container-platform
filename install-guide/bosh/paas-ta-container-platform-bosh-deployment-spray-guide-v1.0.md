## Table of Contents

1. [문서 개요](#1)  
    1.1. [목적](#1.1)  
    1.2. [범위](#1.2)  
    1.3. [시스템 구성도](#1.3)  
    1.4. [참고자료](#1.4)  

2. [Container Platform 설치](#2)  
    2.1. [Prerequisite](#2.1)  
    2.2. [Stemcell 확인](#2.2)  
    2.3. [Deployment 다운로드](#2.3)  
    2.4. [Deployment 파일 수정](#2.4)  
    2.5. [Release  설치](#2.5)  
    2.6. [Release  설치 확인](#2.6)

3. [Container Platform 배포](#3)  
    3.1. [kubernetes Cluster 설정](#3.1)  
    3.2. [Container Platform 이미지 업로드](#3.2)  
    3.3. [Secret 생성](#3.3)  
    3.4. [Deployment 배포](#3.4)  
    3.4.1. [paas-ta-container-platform-common-api 배포](#3.4.1)  
    3.4.2. [paas-ta-container-platform-api 배포](#3.4.2)    
    3.4.3. [paas-ta-container-platform-webuser 배포](#3.4.3)    
    3.4.4. [paas-ta-container-platform-webadmin 배포](#3.4.4)    
    3.4.5. [배포 확인](#3.4.5)    

4. [CVE 조치사항 적용](#4)     

## <div id='1'>1. 문서 개요
### <div id='1.1'>1.1. 목적
본 문서(Container 서비스 설치 가이드)는 단독배포된 Kubernetes를 사용하기 위해 Bosh 기반 Release 설치 방법을 기술하였다.

PaaS-TA 3.5 버전부터는 Bosh 2.0 기반으로 배포(deploy)를 진행한다.

### <div id='1.2'>1.2. 범위
설치 범위는 Kubernetes 단독 배포를 기준으로 작성하였다.

### <div id='1.3'>1.3. 시스템 구성도
본 문서의 설치된 시스템 구성도이다.
![image 001]

### <div id='1.4'>1.4. 참고 자료
> http://bosh.io/docs
> http://docs.cloudfoundry.storage

## <div id='2'>2. Container Platform 설치
### <div id='2.1'>2.1. Prerequisite
본 설치 가이드는 Ubuntu환경에서 설치하는 것을 기준으로 작성하였다. 단독 배포를 위해서는 BOSH 2.0이 설치되어 있어야 한다.
- [BOSH 2.0 설치가이드](https://github.com/PaaS-TA/Guide-5.0-Ravioli/blob/working-5.1/install-guide/bosh/PAAS-TA_BOSH2_INSTALL_GUIDE_V5.0.md)

### <div id='2.2'>2.2. Stemcell 확인
Stemcell 목록을 확인하여 서비스 설치에 필요한 Stemcell 이 업로드 되어 있는 것을 확인한다. (PaaS-TA 5.5 와 동일 stemcell 사용)
- Stemcell 업로드 및 Cloud Config 설정 부분은 [PaaS-TA 5.5 설치가이드](https://github.com/PaaS-TA/Guide/blob/working-5.1/install-guide/paasta/PAAS-TA_CORE_INSTALL_GUIDE_V5.0.md)를 참고 한다.
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
  IPS - k8s_auth_bearer : [Kubespray 설치 가이드 - Cluster Role 운영자 생성 및 Token 획득 참고](https://github.com/PaaS-TA/paas-ta-container-platform/blob/dev/install-guide/standalone/paas-ta-container-platform-standalone-deployment-guide-v1.0.md#-41-cluster-role-%EC%9A%B4%EC%98%81%EC%9E%90-%EC%83%9D%EC%84%B1-%EB%B0%8F-token-%ED%9A%8D%EB%93%9D)
  
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

```    
#!/bin/bash

# SET VARIABLES
export CONTAINER_DEPLOYMENT_NAME='paasta-container-platform'   # deployment name
export CONTAINER_BOSH2_NAME="<BOSH_NAME>"                     # bosh name (e.g. micro-bosh)
export CONTAINER_BOSH2_UUID=`bosh int <(bosh -e ${CONTAINER_BOSH2_NAME} environment --json) --path=/Tables/0/Rows/0/uuid`

# DEPLOY
bosh -e ${CONTAINER_BOSH2_NAME} -n -d ${CONTAINER_DEPLOYMENT_NAME} deploy --no-redact manifests/paasta-container-service-deployment-{IAAS}.yml \
    -l manifests/paasta-container-service-vars-{IAAS}.yml \
    -o manifests/ops-files/paasta-container-service/network-{IAAS}.yml \
    -o manifests/ops-files/misc/first-time-deploy.yml \   
    -v deployment_name=${CONTAINER_DEPLOYMENT_NAME} \
    -v director_name=${CONTAINER_BOSH2_NAME} \
    -v director_uuid=${CONTAINER_BOSH2_UUID}
```
### <div id='2.5'>2.5. Release 설치
- Release 설치에 필요한 릴리스 파일을 다운로드 받아 Local machine의 Release 설치 작업 경로로 위치시킨다.  
  + 설치 릴리즈 파일 다운로드 :  
   [paasta-container-platform-1.0.tgz](http://45.248.73.44/index.php/s/eNrX3oTMkdSfZ7k/download)  
```

# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta/release/service
$ cd ~/workspace/paasta/release/service

# 릴리즈 파일 다운로드 및 파일 경로 확인
$ wget --content-disposition http://45.248.73.44/index.php/s/eNrX3oTMkdSfZ7k/download
$ ls ~/workspace/paasta/release/service
  paasta-container-platform-1.0.tgz
```

- Release를 설치한다.
```
$ cd ~/workspace/paasta/deployment/paas-ta-container-platform-deployment/bosh  
$ ./deploy-{IAAS}.sh
```

### <div id='2.6'>2.6. Release 설치 확인
설치 완료된 Release를 확인한다.
> $ bosh -e micro-bosh -d paasta-container-platform vms
```
Using environment '10.0.1.6' as client 'admin'

Task 2983. Done

Deployment 'paasta-container-platform'

Instance                                                       Process State  AZ  IPs           VM CID               VM Type  Active
haproxy/32d1ff4e-1007-4e9a-8ebd-ffb33ba37348                   running        z7  10.0.0.121    i-0e6c374f2377ecf12  small    true
                                                                                  3.35.95.75
mariadb/42657509-69b6-4b4e-a006-20690e5ce2ea                   running        z5  10.0.161.121  i-0a8c71fb43ba3f34a  small    true
private-image-repository/2803b9a6-d797-4afb-9a34-65ce15853a9e  running        z7  10.0.0.122    i-0d5e4c451075e446b  small    true

3 vms
Succeeded
```

## <div id='3'>3. Container Platform 배포
kubernetes에서 PaaS-TA용 Container Platform을 사용하기 위해서는 Bosh Release 배포 후 Repository에 등록된 이미지를 Kubernetes에 배포하여 사용하여야 한다.

### <div id='3.1'>3.1. kubernetes Cluster 설정
> 단독배포용 Kubernetes Master Node, Worker Node에서 daemon.json 에 insecure-registries 로 Private Image Repository URL 설정 후 Docker를 재시작한다.
```
$ sudo vi /etc/docker/daemon.json
{
        "insecure-registries": ["{HAProxy_IP}:5001"]
}

# docker 재시작
$ sudo systemctl restart docker
```

### <div id='3.2'>3.2. Container Platform 이미지 업로드
Private Repository에 이미지 등록을 위해 Container Platform 이미지 파일을 다운로드 받아 아래 경로로 위치시킨다.<br>
해당 내용은 Kubernetes Master Node에서 실행한다.
 
+ Container Platform 이미지 파일 다운로드 :  
   [cp-standalone-images.tar](http://45.248.73.44/index.php/s/MDBn89G78fnXd4W/download)  

```
# 이미지 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta/container-platform/image
$ cd ~/workspace/paasta/container-platform

# 이미지 파일 다운로드 및 파일 경로 확인
$ wget --content-disposition http://45.248.73.44/index.php/s/MDBn89G78fnXd4W/download

$ ls ~/workspace/paasta/container-platform
  cp-standalone-images.tar  image

# 이미지 다운로드 파일 압축 해제
$ tar -xvf cp-standalone-images.tar -C image
$ cd ~/workspace/paasta/container-platform/image
$ ls ~/workspace/paasta/container-platform/image
  container-platform-api.tar.gz         container-platform-webadmin.tar.gz  image-upload-standalone.sh
  container-platform-common-api.tar.gz  container-platform-webuser.tar.gz
   
 ```
 
 + Private Repository에 이미지를 업로드한다.
 ```
 $ chmod +x *.sh  
 $ ./image-upload-standalone.sh {HAProxy_IP}:5001 
 ```
 
 + Private Repository에 업로드 된 이미지 목록을 확인한다.
 
 ```
 $ curl -H 'Authorization:Basic YWRtaW46YWRtaW4=' http://{HAProxy_IP}:5001/v2/_catalog
 
{"repositories":["container-platform-api","container-platform-common-api","container-platform-webadmin","container-platform-webuser"]}
```


### <div id='3.3'>3.3. Secret 생성
Private Repository에 등록된 이미지를 활용하기 위해 Kubernetes에 secret을 생성한다.
```
$ kubectl create secret docker-registry cp-secret --docker-server={HAProxy_IP}:5001 --docker-username=admin --docker-password=admin --namespace=default
```

### <div id='3.4'>3.4. Deployment 배포

#### <div id='3.4.1'>3.4.1. paas-ta-container-platform-common-api 배포

> vi paas-ta-container-platform-common-api.yml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: common-api-deployment
  labels:
    app: common-api
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: common-api
  template:
    metadata:
      labels:
        app: common-api
    spec:
      containers:
      - name: common-api
        image: {HAProxy_IP}:5001/container-platform-common-api:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 3334
        env:
        - name: HAPROXY_IP
          value: "{HAProxy_IP}"
        - name: CONTAINER_PLATFORM_API_URL
          value: "api-deployment.default.svc.cluster.local:3333"  
        - name: MARIADB_USER_ID
          value: {MARIADB_USER_ID}           # (e.g. cp-admin)
        - name: MARIADB_USER_PASSWORD
          value: {MARIADB_USER_PASSWORD}     # (e.g. PaaS-TA@2020)              
      imagePullSecrets:
        - name: cp-secret
---
apiVersion: v1
kind: Service
metadata:
  name: common-api-deployment
  labels:
    app: common-api
  namespace: default
spec:
  ports:
  - nodePort: 30334
    port: 3334
    protocol: TCP
    targetPort: 3334
  selector:
    app: common-api
  type: NodePort

```
#### <div id='3.4.2'>3.4.2. paas-ta-container-platform-api 배포

> vi paas-ta-container-platform-api.yml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
  labels:
    app: api
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: {HAProxy_IP}:5001/container-platform-api:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 3333
        env:
        - name: K8S_IP
          value: "{K8S_IP}"                                           # {K8S_IP} : K8S Master Node Public IP
        - name: CLUSTER_NAME
          value: "{CLUSTER_NAME}"
        - name: CONTAINER_PLATFORM_COMMON_API_URL
          value: "common-api-deployment.default.svc.cluster.local:3334"  
      imagePullSecrets:
        - name: cp-secret
---
apiVersion: v1
kind: Service
metadata:
  name: api-deployment
  labels:
    app: api
  namespace: default
spec:
  ports:
  - nodePort: 30333
    port: 3333
    protocol: TCP
    targetPort: 3333
  selector:
    app: api
  type: NodePort
```

Deployment YAML 내 정의한 환경변수(env) 중 CLUSTER_NAME 값은 배포 후 운영자 포탈 회원가입 시 Kubernetes Cluster Name 항목에 동일한 값으로  입력이 필요하다.<br>
> ex) "{CLUSTER_NAME}" 에 "cp-cluster" 값으로 정의 후 배포할 시, 운영자 포탈 회원가입 kubernetes Cluster Name 항목에 "cp-cluster" 값 입력 필요 

![image 005]

#### <div id='3.4.3'>3.4.3. paas-ta-container-platform-webuser 배포

> vi paas-ta-container-platform-webuser.yml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webuser-deployment
  labels:
    app: webuser
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webuser
  template:
    metadata:
      labels:
        app: webuser
    spec:
      containers:
      - name: webuser
        image: {HAProxy_IP}:5001/container-platform-webuser:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8091
        env:
        - name: K8S_IP
          value: "{K8S_IP}"                                           # {K8S_IP} : K8S Master Node Public IP
        - name: CONTAINER_PLATFORM_COMMON_API_URL
          value: "common-api-deployment.default.svc.cluster.local:3334"
        - name: CONTAINER_PLATFORM_API_URL
          value: "api-deployment.default.svc.cluster.local:3333"     
      imagePullSecrets:
        - name: cp-secret
---
apiVersion: v1
kind: Service
metadata:
  name: webuser-deployment
  labels:
    app: webuser
  namespace: default
spec:
  ports:
  - nodePort: 32091
    port: 8091
    protocol: TCP
    targetPort: 8091
  selector:
    app: webuser
  type: NodePort

```
#### <div id='3.4.4'>3.4.4. paas-ta-container-platform-webadmin 배포

> vi paas-ta-container-platform-webadmin.yml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webadmin-deployment
  labels:
    app: webadmin
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webadmin
  template:
    metadata:
      labels:
        app: webadmin
    spec:
      containers:
      - name: webadmin
        image: {HAProxy_IP}:5001/container-platform-webadmin:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
      imagePullSecrets:
        - name: cp-secret
---
apiVersion: v1
kind: Service
metadata:
  name: webadmin-deployment
  labels:
    app: webadmin
  namespace: default
spec:
  ports:
  - nodePort: 32080
    port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    app: webadmin
  type: NodePort
```
```
$ kubectl apply -f paas-ta-container-platform-common-api.yml
deployment.apps/common-api-deployment created
service/common-api-deployment created

$ kubectl apply -f paas-ta-container-platform-api.yml
deployment.apps/api-deployment created
service/api-deployment created

$ kubectl apply -f paas-ta-container-platform-webuser.yml
deployment.apps/webuser-deployment created
service/webuser-deployment created

$ kubectl apply -f paas-ta-container-platform-webadmin.yml
deployment.apps/webadmin-deployment created
service/webadmin-deployment created
```

#### <div id='3.4.5'>3.4.5. 배포 확인
배포된 Deployment, Pod, Service를 확인한다.

```
$ kubectl get deployments
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
api-deployment          1/1     1            1           59s
common-api-deployment   1/1     1            1           77s
webadmin-deployment     1/1     1            1           29s
webuser-deployment      1/1     1            1           42s

$ kubectl get pods
NAME                                     READY   STATUS    RESTARTS   AGE
api-deployment-5fc8bcbdbf-qb6pr          1/1     Running   0          74s
common-api-deployment-68dd87f5ff-2plnn   1/1     Running   0          92s
webadmin-deployment-54cd8b8687-mgznp     1/1     Running   0          44s
webuser-deployment-7ddd64b5b9-c74mx      1/1     Running   0          57s

$ kubectl get svc
NAME                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
api-deployment          NodePort    xxx.xxx.xxx.xxx  <none>        3333:30333/TCP   103s
common-api-deployment   NodePort    xxx.xxx.xxx.xxx  <none>        3334:30334/TCP   2m1s
webadmin-deployment     NodePort    xxx.xxx.xxx.xxx  <none>        8080:32080/TCP   73s
webuser-deployment      NodePort    xxx.xxx.xxx.xxx  <none>        8091:32091/TCP   86s

```


## <div id='4'>4. CVE 조치사항 적용  
#### TCP timestamp responses 비활성화 설정  
 - 일시 적용  
```
 $ sudo sysctl -w net.ipv4.tcp_timestamps=0
```
 - 영구 적용  
```
 $ sudo vi /etc/sysctl.conf
 ----------------------------------------
 ## Add at the bottom
 net.ipv4.tcp_timestamps=0
 ----------------------------------------
 $ sudo reboot
```

----
[image 001]:images/cp-001.png
[image 005]:images/cp-005.png
