### Table of Contents
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

## <div id='1'>1. 문서 개요
### <div id='1.1'>1.1. 목적
본 문서(Container 서비스 설치 가이드)는 단독배포된 Kubernetes를 사용하기 위해 Bosh 기반 Release의 설치 및 서비스를 등록하는 방법을 기술하였다.

PaaS-TA 3.5 버전부터는 Bosh 2.0 기반으로 배포(deploy)를 진행한다.

### <div id='1.2'>1.2. 범위
설치 범위는 Kubernetes 단독배포를 기준으로 작성하였다.

### <div id='1.3'>1.3. 시스템 구성도
본 문서의 설치된 시스템 구성도이다.
![image 001]

### <div id='1.4'>1.4. 참고 자료
> http://bosh.io/docs
> http://docs.cloudfoundry.storage

## <div id='2'>2. Container 서비스 설치
### <div id='2.1'>2.1. Prerequisite
본 설치 가이드는 Linux환경에서 설치하는 것을 기준으로 작성하였다. 서비스팩 설치를 위해서는 BOSH 2.0과 PaaS-TA 5.1이 설치되어 있어야 한다.
- [BOSH 2.0 설치가이드](https://github.com/PaaS-TA/Guide/blob/working-5.1/install-guide/bosh/PAAS-TA_BOSH2_INSTALL_GUIDE_V5.0.md)
- [PaaS-TA 5.1 설치가이드](https://github.com/PaaS-TA/Guide/tree/working-5.1)

### <div id='2.2'>2.2. Stemcell 확인
Stemcell 목록을 확인하여 서비스 설치에 필요한 Stemcell 이 업로드 되어 있는 것을 확인한다.(bosh-aws-xen-hvm-ubuntu-xenial-go_agent/621.78)
> $ bosh -e micro-bosh stemcells
```
Using environment '10.0.1.6' as client 'admin'

Name                                     Version  OS             CPI  CID
bosh-aws-xen-hvm-ubuntu-xenial-go_agent  621.78   ubuntu-xenial  -    ami-0694eb07c57faca73

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
(e.g. {IAAS} :: openstack)
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
vm_type_container_small: "small"                                                   # vm type small for caas's etc
vm_type_container_small_api: "small"                                               # vm type small for caas's api

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
mariadb_port: "3306"                                                         # mariadb port (e.g. 13306)-- Do Not Use "3306"
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
    -o manifests/ops-files/add-jenkins-service-broker.yml \
    -o manifests/ops-files/add-service-broker.yml \
    -v deployment_name=${CONTAINER_DEPLOYMENT_NAME} \
    -v director_name=${CONTAINER_BOSH2_NAME} \
    -v director_uuid=${CONTAINER_BOSH2_UUID}
```
> paasta와 연동하지 않을 경우(서비스로설치)에는 아래 두개 행은 제거한다.
  -o manifests/ops-files/add-jenkins-service-broker.yml \
  -o manifests/ops-files/add-service-broker.yml \



### <div id='2.5'>2.5. Release 설치
> 서비스형태의 단독배포 시

- 서비스 설치에 필요한 릴리스 파일을 다운로드 받아 Local machine의 서비스 설치 작업 경로로 위치시킨다.  
  + 설치 릴리즈 파일 다운로드 :
  [paasta-container-platform-release-svc-1.0.tgz](http://45.248.73.44/index.php/s/7iBrNFHqNBnBtxr/download) [docker.35.3.4.tgz](http://45.248.73.44/index.php/s/yRbGQkMLZ4CJAx9/download)          


```
# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.5/release/service
$ cd ~/workspace/paasta-5.5/release/service

# 릴리즈 파일 다운로드(paasta-container-platform-release-1.0.tgz) 및 파일 경로 확인
# 서비스형태의 단독배포 시
$ wget --content-disposition http://45.248.73.44/index.php/s/7iBrNFHqNBnBtxr/download
$ wget --content-disposition http://45.248.73.44/index.php/s/yRbGQkMLZ4CJAx9/download
$ ls ~/workspace/paasta-5.5/release/service
paasta-container-platform-release-svc-1.0.tgz
$ mv paasta-container-platform-release-svc-1.0.tgz paasta-container-platform-release-1.0.tgz
```

> 일반 단독배포 시

- 서비스 설치에 필요한 릴리스 파일을 다운로드 받아 Local machine의 서비스 설치 작업 경로로 위치시킨다.  
  + 설치 릴리즈 파일 다운로드 :
  [paasta-container-platform-release-1.0.tgz](http://45.248.73.44/index.php/s/nDdJiRfZHACozob/download)
  [docker.35.3.4.tgz](http://45.248.73.44/index.php/s/yRbGQkMLZ4CJAx9/download)  


```
# 릴리즈 다운로드 파일 위치 경로 생성
$ mkdir -p ~/workspace/paasta-5.5/release/service
$ cd ~/workspace/paasta-5.5/release/service

# 릴리즈 파일 다운로드(paasta-container-platform-release-1.0.tgz) 및 파일 경로 확인
# 서비스형태의 단독배포 시
$ wget --content-disposition http://45.248.73.44/index.php/s/nDdJiRfZHACozob
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
설치된 Release 를 확인한다.
> $ bosh -e micro-bosh -d paasta-container-platform vms
```
Using environment '10.0.1.6' as client 'admin'

Task 2983. Done

Deployment 'paasta-container-platform'

Instance                                                       Process State  AZ  IPs           VM CID               VM Type  Active
container-jenkins-broker/ff84ac36-8c24-4dcf-88e7-fc700e777936  running        z6  10.0.201.121  i-0c50e8bef11a7d5d8  small    true
container-service-broker/7bc8e449-2e95-4f54-aa94-c59e3767c907  running        z6  10.0.201.122  i-04c934cc859998219  small    true
haproxy/32d1ff4e-1007-4e9a-8ebd-ffb33ba37348                   running        z7  10.0.0.121    i-0e6c374f2377ecf12  small    true
                                                                                  3.35.95.75
mariadb/42657509-69b6-4b4e-a006-20690e5ce2ea                   running        z5  10.0.161.121  i-0a8c71fb43ba3f34a  small    true
private-image-repository/2803b9a6-d797-4afb-9a34-65ce15853a9e  running        z7  10.0.0.122    i-0d5e4c451075e446b  small    true

5 vms
Succeeded
```

## 3. Container 서비스 브로커
Container 서비스 형태로 설치하는 경우에 CF와 배포된 K8s와의 연동을 위해서는 Container 서비스 브로커를 등록해 주어야 한다.
PaaS-TA 운영자 포탈을 통해 서비스를 등록하고 공개하면, PaaS-TA 사용자 포탈을 통해 서비스를 신청하여 사용할 수 있다.

### 3.1 Container 서비스 브로커 등록

서비스 브로커 등록 시 개방형 클러스터 플랫폼에서 서비스 브로커를 등록할 수 있는 사용자로 로그인이 되어 있어야 한다.


 - 서비스 브로커 목록을 확인한다.
 ```
$ cf service-brokers
Getting service brokers as admin...

name                               url
mysql-service-broker               http://10.0.121.71:8080
 ```
  - Container 서비스 브로커를 등록한다.
  > $ create-service-broker {서비스팩 이름} {서비스팩 사용자ID} {서비스팩 사용자비밀번호} http://{서비스팩 URL}
  > - 서비스팩 이름 : 서비스 팩 관리를 위해 개방형 클라우드 플랫폼에서 보여지는 명칭
  > - 서비스팩 사용자 ID/비밀번호 : 서비스팩에 접근할 수 있는 사용자 ID/비밀번호
  > - 서비스팩 URL : 서비스팩이 제공하는 API를 사용할 수 있는 URL
   ```
  $ cf create-service-broker container-service-broker admin cloudfoundry http://xxx.xxx.xxx.xxx:8888
   ```
 - 등록된 Container 서비스 브로커를 확인한다.
  ```
  $ cf service-brokers
Getting service brokers as admin...

name                       url
container-service-broker   http://xxx.xxx.xxx.xxx:8888
mysql-service-broker       http://10.0.121.71:8080
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

### 3.2 PaaS-TA 포탈에서 Container 서비스 조회 설정

 해당 설정은 PaaS-TA 포탈에 Container 서비스 상의 자원들을 간략하게 조회하기 위한 설정이다.

  1. PaaS-TA Admin 포탈에 접속한다.

  ![image 002]

  2. 왼쪽 네비게이션 바에서 [설정]-[설정정보] 를 클릭한 후 나타나는 페이지의 오른쪽 상단 [인프라 등록] 버튼을 클릭하여 해당 정보들을 입력한다.
   - 해당 정보를 입력하기 위해 필요한 값들을 찾는다.
   > $ bosh -e micro-bosh -d paasta-portal-api vms
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
container-jenkins-broker/a458f442-2bc3-4004-afb5-a6f378fa527e  running        z6  10.0.201.132  i-023f9cf68fbde2ede  small    true
container-service-broker/312de3ad-d072-4d38-aff2-db3c8139b7af  running        z6  10.0.201.133  i-09aa099d393009ad4  small    true
haproxy/446ce2a6-5344-4335-a94c-e3448f48ada4                   running        z7  10.0.0.124    i-0cc170becd2f44b64  small    true
                                                                                  3.35.95.75
mariadb/b70e1276-66bc-4328-bd37-edc52e66f960                   running        z5  10.0.161.121  i-08a1b5dcc278226be  small    true
private-image-repository/54597eb7-1157-4c44-8e23-e9a3785f2005  running        z7  10.0.0.125    i-0412c393c9e95ce52  small    true

5 vms
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
## 4. Jenkins 서비스 브로커(Optional)
해당 설정은 Jenkins 서비스에서 설치된 jenkins 서비스를 이용하기 위한 설정이다.

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

2. 배포된 Jenkins 서비스 VM 목록을 확인
> $ bosh -e micro-bosh -d paasta-container-platform
```
Deployment 'paasta-container-platform'

Instance                                                       Process State  AZ  IPs           VM CID               VM Type  Active
container-jenkins-broker/4181e787-8971-48a7-99fe-3b9c79ea83c5  running        z6  10.0.201.121  i-08070edaad67d4264  small    true
container-service-broker/1ffe82c1-ef1c-4282-b143-59b3f5b8aa44  running        z6  10.0.201.122  i-05cffd02f3ccbe9d9  small    true
haproxy/be936a47-0477-4983-8aed-94b3fce9b98d                   running        z7  10.0.0.122    i-062798eeb848b85ac  small    true
                                                                                  3.35.95.75
mariadb/a935fac7-4b23-47af-8cc2-bd20cf4bb2b5                   running        z5  10.0.161.121  i-0b8efeb5d74428142  small    true
private-image-repository/9c9e88e4-b16a-4046-901e-08946508bb47  running        z7  10.0.0.123    i-0d5ca33b08c7541e3  small    true

5 vms
```

3. Jenkins 서비스 브로커를 등록한다.
- 브로커 목록을 확인한다.
```
$ cf service-brokers
Getting service brokers as admin...

name                               url
mysql-service-broker               http://10.0.121.71:8080
```
 - Jenkins 서비스 브로커를 등록한다.
> $ create-service-broker {서비스팩 이름} {서비스팩 사용자ID} {서비스팩 사용자비밀번호} http://{서비스팩 URL}
> - 서비스팩 이름 : 서비스 팩 관리를 위해 개방형 클라우드 플랫폼에서 보여지는 명칭
> - 서비스팩 사용자 ID/비밀번호 : 서비스팩에 접근할 수 있는 사용자 ID/비밀번호
> - 서비스팩 URL : 서비스팩이 제공하는 API를 사용할 수 있는 URL
 ```
$ cf create-service-broker jenkins-service-broker admin cloudfoundry http://xxx.xxx.xxx.xxx:8787
 ```
  - 등록된 Jenkins 서비스 브로커를 확인한다.
 ```
 $ cf service-brokers
Getting service brokers as admin...

name                       url
container-service-broker   http://xxx.xxx.xxx.xxx:8888
mysql-service-broker       http://10.0.121.71:8080
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

## 5. Kubernetes에 Container Platform API 배포
단독 배포된 kubernetes에서 PaaS-TA용 Container Platform 을 사용하기 위해서는 Bosh Release 배포 후 Repository에 등록된 이미지를 Kubernetes에 배포하여 사용하여야 한다.


### 5.1 단독배포 시 Deployment

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

3. API 배포
- container-platform-common-api
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
- container-platform-api
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
- container-platform-webuser
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
- container-platform-webadmin
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
### 5.2 서비스배포 시 Deployment
> PaaS-TA 사용자포탈에서 CaaS서비스를 추가하기 전에 Deployment가 미리 배포되어 있어야 한다.
- container-service-common-api
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
        image: {HAProxy_IP}:5000/container-platform/container-service-common-api:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 3334
        env:
        - name: MYSQL_IP
          value: {HAProxy_IP}
      imagePullSecrets:
        - name: paasta
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
- container-service-api
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
        image: {HAProxy_IP}:5000/container-service-api:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 3333
        env:
        - name: K8S_IP
          value: {K8S_IP}
      imagePullSecrets:
        - name: paasta
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
- container-service-dashboard
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
        image: {HAProxy_IP}:5000/container-service-dashboard:latest
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
        - name: paasta
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

----
[image 001]:images/cp-001.png
[image 002]:images/cp-002.png
[image 003]:images/cp-003.png
[image 004]:images/cp-004.png
