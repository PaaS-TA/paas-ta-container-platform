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

3. [Kubernetes에 Container Platform API 배포](#3)  
    3.1. [일반 단독배포 시 Deployment](#3.1)  
        3.1.1. [paas-ta-container-platform-common-api 배포](#3.1.1)  
        3.1.2. [paas-ta-container-platform-api 배포](#3.1.2)  
        3.1.3. [paas-ta-container-platform-webuser 배포](#3.1.3)  
        3.1.4. [paas-ta-container-platform-webadmin 배포](#3.1.4)  
        3.1.5. [배포 확인](#3.1.5)  
    

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

## <div id='2'>2. Container 서비스 설치
### <div id='2.1'>2.1. Prerequisite
본 설치 가이드는 Ubuntu환경에서 설치하는 것을 기준으로 작성하였다. 단독 배포를 위해서는 BOSH 2.0이 설치되어 있어야 한다.
- [BOSH 2.0 설치가이드](https://github.com/PaaS-TA/Guide/blob/working-5.1/install-guide/bosh/PAAS-TA_BOSH2_INSTALL_GUIDE_V5.0.md)

### <div id='2.2'>2.2. Stemcell 확인
Stemcell 목록을 확인하여 서비스 설치에 필요한 Stemcell 이 업로드 되어 있는 것을 확인한다. (PaaS-TA 5.5 과 동일 stemcell 사용)
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
- Container Platform Deployment Git Repository URL : https://github.com/PaaS-TA/paas-ta-container-platform-deployment/tree/dev

```
# Deployment 다운로드 파일 위치 경로 생성 및 이동
$ mkdir -p ~/workspace/paasta-5.5/deployment/
$ cd ~/workspace/paasta-5.5/deployment/

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

> 일부 application의 경우 이중화를 위한 조치는 되어 있지 않아 인스턴스 수 조정 시 신규로 생성되는 인스턴스에는 데이터의 반영이 안될 수 있으니, 1개의 인스턴스로 유지한다.

- Deployment YAML에서 사용하는 변수 파일을 서버 환경에 맞게 수정한다.
> $ vi ~/workspace/paasta-5.5/deployment/paas-ta-container-platform-deployment/bosh/manifests/paasta-container-service-vars-{IAAS}.yml
(e.g. {IAAS} :: AWS)
```
# BOSH NAME
director_name: "micro-bosh"                                                   # bosh name (caas_cluster_name에 필요.)

# IAAS
auth_url: 'http://<IAAS-IP>:5000/v3'                                          # auth url
openstack_domain: '<OPENSTACK_DOMAIN>'                                        # openstack domain
openstack_username: '<OPENSTACK_USERNAME>'                                    # openstack username
openstack_password: '<OPENSTACK_PASSWORD>'                                    # openstack password
openstack_project_id: '<OPENSTACK_PROJECT_ID>'                                # openstack project id
region: '<OPENSTACK_REGION>'                                                  # region
ignore-volume-az: true                                                        # ignore volume az (default : true)

# STEMCELL
stemcell_os: "ubuntu-xenial"                                                  # stemcell os
stemcell_version: "621.78"                                                    # stemcell version
stemcell_alias: "xenial"                                                      # stemcell alias

# VM_TYPE
vm_type_small: "small"                                                        # vm type small
vm_type_small_highmem_16GB: "small-highmem-16GB"                              # vm type small highmem
vm_type_small_highmem_16GB_100GB: "small-highmem-16GB"                        # vm type small highmem_100GB
vm_type_container_small: "small"                                              # vm type small for caas's etc
vm_type_container_small_api: "small"                                          # vm type small for caas's api

# NETWORK
private_networks_name: "default"                                              # private network name
public_networks_name: "vip"                                                   # public network name

# IPS
k8s_api_server_ip: "<K8S_API_SERVER_IP>"
k8s_api_server_port: "6443"
k8s_auth_bearer: "<K8S_AUTH_BEARER_VALUE>"
haproxy_public_url: "<HAPROXY_PUBLIC_URL>"                                    # haproxy's public IP

# HAPROXY
haproxy_http_port: 8080                                                       # haproxy port
haproxy_azs: [z7]                                                             # haproxy azs

# MARIADB
mariadb_port: "3306"                                                          # mariadb port (e.g. 13306)-- Do Not Use "3306"
mariadb_azs: [z5]                                                             # mariadb azs
mariadb_persistent_disk_type: "10GB"                                          # mariadb persistent disk type
mariadb_admin_user_id: "<MARIADB_ADMIN_USER_ID>"                              # mariadb admin user name (e.g. root)
mariadb_admin_user_password: "<MARIADB_ADMIN_USER_PASSWORD>"                  # mariadb admin user password (e.g. paasta!admin)
mariadb_role_set_administrator_code_name: "Administrator"                     # administrator role's code name (e.g. Administrator)
mariadb_role_set_administrator_code: "RS0001"                                 # administrator role's code (e.g. RS0001)
mariadb_role_set_regular_user_code_name: "Regular User"                       # regular user role's code name (e.g. Regular User)
mariadb_role_set_regular_user_code: "RS0002"                                  # regular user role's code (e.g. RS0002)
mariadb_role_set_init_user_code_name: "Init User"                             # init user role's code name (e.g. Init User)
mariadb_role_set_init_user_code: "RS0003"                                     # init user role's code (e.g. RS0003)

# SERVICE BROKER
container_service_broker_instances: 1
container_service_broker_port: 8888
container_service_broker_azs: [z6]

# PRIVATE IMAGE REPOSITORY
private_image_repository_azs: [z7]                                                     # private image repository azs
private_image_repository_port: 15001                                                   # private image repository port (e.g. 15001)-- Do Not Use "5000"
private_image_repository_root_directory: "/var/vcap/data/private-image-repository"     # private image repository root directory
private_image_repository_public_url: "<PRIVATE_IMAGE_REPOSITORY_PUBLIC_URL>"           # private image repository's public IP
private_image_repository_persistent_disk_type: "10GB"                                  # private image repository's persistent disk type

# JENKINS BROKER
jenkins_broker_instances: 1
jenkins_broker_port: 8787
jenkins_broker_azs: [z6]
jenkins_namespace: "jenkins-namespace"
jenkins_secret_file: "/var/vcap/jobs/container-jenkins-broker/data/docker-secret.yml"
jenkins_namespace_file: "/var/vcap/jobs/container-jenkins-broker/data/create-namespace.yml"

```
- 서버 환경에 맞추어 Deploy 스크립트 파일의 VARIABLES 설정을 수정한다.
> $ vi ~/workspace/paasta-5.5/deployment/paas-ta-container-platform-deployment/bosh/deploy-{IAAS}.sh

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
  [paasta-container-platform-1.0.tgz](http://45.248.73.44/index.php/s/nDdJiRfZHACozob/download)  
  [docker.35.3.4.tgz](http://45.248.73.44/index.php/s/yRbGQkMLZ4CJAx9/download)  
```

# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.5/release/service
$ cd ~/workspace/paasta-5.5/release/service

# 릴리즈 파일 다운로드 및 파일 경로 확인
$ wget --content-disposition http://45.248.73.44/index.php/s/nDdJiRfZHACozob/download
$ wget --content-disposition http://45.248.73.44/index.php/s/yRbGQkMLZ4CJAx9/download
$ ls ~/workspace/paasta-5.5/release/service
docker-35.3.4.tgz  paasta-container-platform-1.0.tgz
```

- Release를 설치한다.
```
$ cd ~/workspace/paasta-5.5/deployment/paas-ta-container-platform-deployment/bosh  
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

## <div id='3'>3. Kubernetes에 Container Platform API 배포
단독 배포된 kubernetes에서 PaaS-TA용 Container Platform 을 사용하기 위해서는 Bosh Release 배포 후 Repository에 등록된 이미지를 Kubernetes에 배포하여 사용하여야 한다.

1. K8s Cluster 설정
> k8s master, worker 에서 daemon.json 에 insecure-registries 로 private image repository url 설정 후 docker 재시작
```
$ sudo vi /etc/docker/daemon.json
{
        "insecure-registries": ["{HAProxy_IP}:5000"]
}

# docker restart
$ sudo systemctl restart docker
```

2. Private Repository에 등록된 이미지를 활용하기 위해서는 Kubernetes에 secret 생성

```
$ kubectl create secret docker-registry paasta --docker-server={HAProxy_IP}:5000 --docker-username=admin --docker-password=admin --namespace=default
```

### <div id='3.1.'>3.1. 단독 배포 시 Deployment

#### <div id='3.1.1'>3.1.1. paas-ta-container-platform-common-api 배포

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
        image: ${HAProxy_IP}:5000/container-platform-common-api:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 3334
        env:
        - name: HAPROXY_IP
          value: "{HAProxy_IP}"
      imagePullSecrets:
        - name: paasta
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
#### <div id='3.1.2'>3.1.2. paas-ta-container-platform-api 배포

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
        image: {HAProxy_IP}:5000/container-platform-api:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 3333
        env:
        - name: K8S_IP
          value: "{K8S_IP}"
      imagePullSecrets:
        - name: paasta
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
#### <div id='3.1.3'>3.1.3. paas-ta-container-platform-webuser 배포

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
        image: {HAProxy_IP}:5000/container-platform-webuser:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8091
        env:
        - name: K8S_IP
          value: "{K8S_IP}"
      imagePullSecrets:
        - name: paasta
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
#### <div id='3.1.4'>3.1.4. paas-ta-container-platform-webadmin 배포

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
        image: {HAProxy_IP}:5000/container-platform-webadmin:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
      imagePullSecrets:
        - name: paasta
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

#### <div id='3.1.5'>3.1.5. 배포 확인
배포된 Deployment, Service를 확인한다.

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

----
[image 001]:images/cp-001.png
