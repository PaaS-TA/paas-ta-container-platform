### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Use](/use-guide/Readme.md) > 사용자 포털 사용 가이드

<br>

## Table of Contents

1. [문서 개요](#1)
    * [1.1. 목적](#1-1)
    * [1.2. 범위](#1-2)
2. [컨테이너 플랫폼 사용자포털 접속](#2)
    * [2.1. 컨테이너 플랫폼 사용자포털 회원가입](#2-1)
    * [2.2. 컨테이너 플랫폼 사용자포털 로그인](#2-2)    
3. [컨테이너 플랫폼 사용자포털 메뉴얼](#3)
    * [3.1. 컨테이너 플랫폼 사용자포털 메뉴 구성](#3-1)
    * [3.2. 컨테이너 플랫폼 사용자포털 메뉴 설명](#3-2)
    * [3.2.1. Intro](#3-2-1)
    * [3.2.1.1. Overview](#3-2-1-1)
    * [3.2.1.2. Access](#3-2-1-2)
    * [3.2.1.3. Private Repository](#3-2-1-3)
    * [3.2.2. Namespaces](#3-2-1-3)
    * [3.2.2.1. Namespace 상세 조회](#3-2-2-1)
    * [3.2.3. Nodes](#3-2-3)
    * [3.2.3.1. Node 상세 조회](#3-2-3-1)
    * [3.2.4. Users](#3-2-2)
    * [3.2.4.1. User 목록 조회](#3-2-4-1)
    * [3.2.4.2. User Role 변경](#3-2-4-2)
    * [3.2.5. Roles](#3-2-5)
    * [3.2.5.1 Role 목록 조회](#3-2-5-1)
    * [3.2.5.2 Role 상세 조회](#3-2-5-2)
    * [3.2.6. Workloads](#3-2-6)
    * [3.2.6.1. Deployments](#3-2-6-1)
    * [3.2.6.1.1. Deployment 목록 조회](#3-2-6-1-1)
    * [3.2.6.1.2. Deployment 상세 조회](#3-2-6-1-2)
    * [3.2.6.1.3. Deployment 생성](#3-2-6-1-3)
    * [3.2.6.1.4. Deployment 수정](#3-2-6-1-4)
    * [3.2.6.1.5. Deployment 삭제](#3-2-6-1-5)
    * [3.2.6.2. Pods](#3-2-6-2)
    * [3.2.6.2.1. Pod 목록 조회](#3-2-6-2-1)
    * [3.2.6.2.2. Pod 상세 조회](#3-2-6-2-2)
    * [3.2.6.2.3. Pod 생성](#3-2-6-2-3)
    * [3.2.6.2.4. Pod 수정](#3-2-6-2-4)
    * [3.2.6.2.5. Pod 삭제](#3-2-6-2-5)
    * [3.2.6.3. Replica Sets](#3-2-6-3)
    * [3.2.6.3.1. Replica Set 목록 조회](#3-2-6-3-1)
    * [3.2.6.3.2. Replica Set 상세 조회](#3-2-6-3-2)
    * [3.2.6.3.3. Replica Set 생성](#3-2-6-3-3)
    * [3.2.6.3.4. Replica Set 수정](#3-2-6-3-4)
    * [3.2.6.3.5. Replica Set 삭제](#3-2-6-3-5)
    * [3.2.7. Services](#3-2-7)
    * [3.2.7.1. Service 목록 조회](#3-2-7-1)
    * [3.2.7.2. Service 상세 조회](#3-2-7-2)
    * [3.2.7.3. Service 생성](#3-2-7-3)
    * [3.2.7.4. Service 수정](#3-2-7-4)
    * [3.2.7.5. Service 삭제](#3-2-7-5)
    * [3.2.8. Storages](#3-2-8)
    * [3.2.8.1. Persistent Volume Claim 목록 조회](#3-2-8-1)
    * [3.2.8.2. Persistent Volume Claim 상세 조회](#3-2-8-2)
    * [3.2.8.3. Persistent Volume Claim 생성](#3-2-8-3)
    * [3.2.8.4. Persistent Volume Claim 수정](#3-2-8-4)
    * [3.2.8.5. Persistent Volume Claim 삭제](#3-2-8-5)


----

# <div id='1'/> 1. 문서 개요

## <div id='1-1'/> 1.1. 목적
본 문서는 컨테이너 플랫폼 사용자포털 사용 방법에 대해 기술하였다.

## <div id='1-2'/> 1.2. 범위
본 문서는 Windows 환경을 기준으로 컨테이너 플랫폼 사용자포털의 사용 방법에 대해 기술하였다.

<br>


# <div id='2'/> 2. 컨테이너 플랫폼 사용자포털 접속
컨테이너 플랫폼 사용자포털은 아래 주소로 접속 가능하다.<br>
{K8S_MASTER_NODE_IP} 값은 **Kubernetes Master Node Public IP** 값을 입력한다.

- 컨테이너 플랫폼 사용자포털 접속 URI : **http://{K8S_MASTER_NODE_IP}:32702** <br>

<br>

### <div id='2-1'/> 2.1. 컨테이너 플랫폼 사용자포털 회원가입

#### 사용자 회원가입    
- http://{K8S_MASTER_NODE_IP}:32702에 접속한다.
- 하단의 'Register' 버튼을 클릭한다.

![IMG_001]


- 등록할 사용자 계정정보를 입력 후 'Register' 버튼을 클릭하여 컨테이너 플랫폼 사용자포털에 회원가입한다.

![IMG_002]

- 컨테이너 플랫폼 사용자포털은 회원가입 후 바로 이용이 불가하며 Cluster 관리자 혹은 Namespace 관리자로부터 해당 사용자가 이용할 Namespace와 Role을 할당 받은 후 포털 이용이 가능하다.   

![IMG_003]


### <div id='2-2'/> 2.2. 컨테이너 플랫폼 사용자포털 로그인
- http://{K8S_MASTER_NODE_IP}:32702에 접속한다.
- 회원가입을 통해 등록된 계정으로 컨테이너 플랫폼 사용자포털에 로그인한다.

![IMG_108]

<br>

## <div id='3'/> 3. 컨테이너 플랫폼 사용자포털 메뉴얼


## <div id='3-1'/> 3.1. 컨테이너 플랫폼 사용자포털 메뉴 구성
| <center>메뉴</center> | <center>분류</center> | <center>설명</center> |
| :--- | :--- | :--- |
| Intro | Overview | 컨테이너 플랫폼 사용자포털 대시보드 |
|| Access | 컨테이너 플랫폼 사용자포털 CLI 사용을 위한 환경 설정 정보 관리 |
|| Private Repository | Private Repository 를 컨테이너 상에 배포 및 사용하기 위한 설정 정보 관리 |
| Namespaces | Namespaces | Namespaces 조회 |
| Nodes | Nodes | Nodes 조회 |
| Users | Users | 사용자 관리 |
| Roles | Roles | Roles 조회 |
| Workloads | Overview | Workloads 대시보드 |
|| Deployments | Deployments 정보 관리 |
|| Pods | Pods 정보 관리 |
|| Replica Sets | Replica Sets 정보 관리 |
| Services | Services | Services 정보 관리 |
| Storages | Persistent Volume Claims | Persistent Volume Claims 정보 관리 |



## <div id='3-2'/> 3.2. 컨테이너 플랫폼 사용자포털 메뉴 설명
본 장에서는 컨테이너 플랫폼 사용자포털의 메뉴에 대한 설명을 기술한다.

### <div id='3-2-1'/> 3.2.1. Intro

#### <div id='3-2-1-1'/> 3.2.1.1. Overview
- Namespace 정보, Resource Quota 정보, Limit Range 정보를 조회한다.

1. Intro의 Overview 탭을 클릭하여 Overview 페이지로 이동한다.

![IMG_004]


#### <div id='3-2-1-2'/> 3.2.1.2. Access
- 컨테이너 플랫폼의 CLI 사용을 위한 환경 설정 정보를 조회한다.

1. Intro의 Access 탭을 클릭하여 Access 페이지로 이동한다.

![IMG_005]


#### <div id='3-2-1-3'/> 3.2.1.3. Private Repository
- Private Repository의 정보 및 접속 링크를 포함한다.

1. Intro의 Private Repository 탭을 클릭하여 Private Repository 페이지로 이동한다.

![IMG_006]

### <div id='3-2-2'/> 3.2.2. Namespaces
#### <div id='3-2-2-1'/> 3.2.2.1. Namespace 상세 조회

- Namespace 상세 페이지는 Details, Events 탭으로 구성된다.

1. Intro의 Overview 탭에서 Namespace 명을 클릭하여 Namespace 상세 페이지로 이동한다.

#### Intro의 Overview 탭
![IMG_007]

#### Namespace 상세 페이지
![IMG_009]
![IMG_010]

### <div id='3-2-3'/> 3.2.3. Nodes
#### <div id='3-2-3-1'/> 3.2.3.1. Node 상세 조회

- Node 상세 페이지는 Summary, Details, Events 탭으로 구성된다.

1. Pods 목록에서 Node 명을 클릭하여 Node 상세 페이지로 이동한다.
#### Pod 목록
![IMG_011]

#### Node 상세 페이지
![IMG_012]
![IMG_013]
![IMG_014]


### <div id='3-2-4'/> 3.2.4. Users
-  사용자포털을 이용하는 사용자 계정 정보와 Role을 관리한다.

| <center>사용자 유형</center> | <center>기능</center> |
| :--- | :--- |
| Cluster 관리자 | 운영자 포털 접근, 사용자 Namespace/Role 할당  |
| Namespace 관리자 |사용자포털 접근, 사용자 Namespace/Role 할당  |
| 일반 사용자 | 사용자포털 접근|

- Cluster 관리자는 사용자에게 Namespace/Role을 할당 할 수 있다. 해당 작업은 운영자포털에서 가능하다.
- Namespace 관리자는 본인이 관리하는 Namespace 사용자의 Role 변경 및 해당 Namespace를 미사용하는 사용자에게 접근 권한을 할당할 수 있다.

#### <div id='3-2-4-1'/> 3.2.4.1. User 목록 조회
1. 상단 우측 아이콘 클릭 후 메뉴 'Users' 에 접속하여 해당 Namespace의 User 목록을 조회한다.

![IMG_015]
![IMG_017]


#### <div id='3-2-4-2'/> 3.2.4.2. User Role 변경
1. 사용자의 Role 변경은 **Namespace 관리자**만 수행 가능하다.

#### User 목록 페이지
![IMG_018]

#### User Role 설정 페이지
![IMG_019]

-  해당 Namespace 사용자의 Role을 변경 혹은 해당 Namespace 미사용자 User ID 좌측의 체크박스를 선택하여(접근 권한 할당) 저장버튼을 클릭한다. 

![IMG_020]
![IMG_021]

### <div id='3-2-5'/> 3.2.5. Roles
#### <div id='3-2-5-1'/> 3.2.5.1. Role 목록 조회

1.  Role 목록을 조회한다.

![IMG_022]


#### <div id='3-2-5-2'/> 3.2.5.2. Role 상세 조회

- Role 상세 페이지는 Details, Events, YAML 탭으로 구성된다.

1. Role 목록에서 Role 명을 클릭하여 Role 상세 페이지로 이동한다.

#### Role 목록 페이지
![IMG_023]

#### Role 상세 페이지
![IMG_024]
![IMG_025]
![IMG_026]

### <div id='3-2-6'/> 3.2.6. Workloads
-  Overview, Deployments, Pods, Replica Sets 목록을 조회한다.

![IMG_027]

#### <div id='3-2-6-1'/> 3.2.6.1. Deployments

##### <div id='3-2-6-1-1'/> 3.2.6.1.1. Deployment 목록 조회
1. Workloads의 Deployment 탭을 클릭하여 Deployment 목록 페이지로 이동한다.

![IMG_028]

##### <div id='3-2-6-1-2'/> 3.2.6.1.2. Deployment 상세 조회
- Deployment 상세 페이지는 Details, Events, YAML 탭으로 구성된다.


1. Deployment 목록에서 Deployment명을 클릭하여 Deployment 상세 페이지로 이동한다.

#### Deployment 목록 페이지
![IMG_029]

#### Deployment 상세 페이지
![IMG_030]
![IMG_031]
![IMG_032]

##### <div id='3-2-6-1-3'/> 3.2.6.1.3. Deployment 생성
1. Deployment 목록에서 생성 버튼을 클릭하여 Deployment 생성 페이지로 이동한다.

#### Deployment 목록 페이지
![IMG_033]

#### Deployment 생성 페이지
![IMG_034]
![IMG_035]
![IMG_036]


##### <div id='3-2-6-1-4'/> 3.2.6.1.4. Deployment 수정
1. Deployment 상세에서 수정 버튼을 클릭하여 Deployment 수정 페이지로 이동한다.

#### Deployment 상세 페이지
![IMG_037]

#### Deployment 수정 페이지
![IMG_038]
![IMG_039]
![IMG_040]

##### <div id='3-2-6-1-5'/> 3.2.6.1.5. Deployment 삭제
1. Deployment 상세에서 삭제 버튼을 클릭하면 Deployment 삭제 팝업창이 뜬다.

#### Deployment 상세 페이지
![IMG_041]

#### Deployment 삭제 팝업창
![IMG_042]
![IMG_043]

#### <div id='3-2-6-2'/> 3.2.6.2. Pods

##### <div id='3-2-6-2-1'/> 3.2.6.2.1. Pod 목록 조회
1. Workloads의 Pods 탭을 클릭하여 Pod 목록 페이지로 이동한다.

![IMG_044]

##### <div id='3-2-6-2-2'/> 3.2.6.2.2. Pod 상세 조회
- Pod 상세 페이지는 Details, Events, YAML 탭으로 구성된다.

1. Pod 목록에서 Pod 명을 클릭하여 Pod 상세 페이지로 이동한다.

#### Pod 목록 페이지
![IMG_045]

#### Pod 상세 페이지
![IMG_046]
![IMG_047]
![IMG_048]

##### <div id='3-2-6-2-3'/> 3.2.6.2.3. Pod 생성
1. Pod 목록에서 생성 버튼을 클릭하여 Pod 생성 페이지로 이동한다.

#### Pod 목록 페이지
![IMG_049]

#### Pod 생성 페이지
![IMG_050]
![IMG_051]
![IMG_052]

##### <div id='3-2-6-2-4'/> 3.2.6.2.4. Pod 수정
1. Pod 상세에서 수정 버튼을 클릭하여 Pod 수정 페이지로 이동한다.

#### Pod 상세 페이지
![IMG_053]

#### Pod 수정 페이지
![IMG_054]
![IMG_055]
![IMG_056]

##### <div id='3-2-6-2-5'/> 3.2.6.2.5. Pod 삭제
1. Pod 상세에서 삭제 버튼을 클릭하면 Pod 삭제 팝업창이 뜬다.

#### Pod 상세 페이지
![IMG_057]

#### Pod 삭제 팝업창
![IMG_058]
![IMG_059]


#### <div id='3-2-6-3'/> 3.2.6.3. Replica Sets

##### <div id='3-2-6-3-1'/> 3.2.6.3.1. Replica Set 목록 조회
1. Workloads의 Replica Sets 탭을 클릭하여 Replica Set 목록 페이지로 이동한다.

![IMG_060]

##### <div id='3-2-6-3-2'/> 3.2.6.3.2. Replica Set 상세 조회
- Replica Set 상세 페이지는 Details, Events, YAML 탭으로 구성된다.

1. Replica Set 목록에서 Replica Set 명을 클릭하여 Replica Set 상세 페이지로 이동한다.

#### Replica Set 목록 페이지
![IMG_061]

#### Replica Set 상세 페이지
![IMG_062]
![IMG_063]
![IMG_064]

##### <div id='3-2-6-3-3'/> 3.2.6.3.3. Replica Set 생성
1. Replica Set 목록에서 생성 버튼을 클릭하여 Replica Set 생성 페이지로 이동한다.

#### Replica Set 목록 페이지
![IMG_065]

#### Replica Set 생성 페이지
![IMG_066]
![IMG_067]
![IMG_068]

##### <div id='3-2-6-3-4'/> 3.2.6.3.4. Replica Set 수정
1. Replica Set 상세에서 수정 버튼을 클릭하여 Replica Set 수정 페이지로 이동한다.

#### Replica Set 상세 페이지
![IMG_069]

#### Replica Set 수정 페이지
![IMG_070]
![IMG_071]
![IMG_072]

##### <div id='3-2-6-3-5'/> 3.2.6.3.5. Replica Set 삭제
1. Replica Set 상세에서 삭제 버튼을 클릭하면 Replica Set 삭제 팝업창이 뜬다.

#### Replica Set 상세 페이지
![IMG_073]

#### Replica Set 삭제 팝업창
![IMG_074]
![IMG_075]


### <div id='3-2-7'/> 3.2.7. Services 메뉴

#### <div id='3-2-7-1'/> 3.2.7.1. Service 목록 조회
1. Services 메뉴를 클릭하여 Service 목록 페이지로 이동한다.

![IMG_076]


#### <div id='3-2-7-2'/> 3.2.7.2. Service 상세 조회
- Service 상세 페이지는 Details, Events, YAML 탭으로 구성된다.

1. Service 목록에서 Service 명을 클릭하여 Service 상세 페이지로 이동한다.

#### Service 목록 페이지
![IMG_077]

#### Service 상세 페이지
![IMG_078]
![IMG_079]
![IMG_080]

##### <div id='3-2-7-3'/> 3.2.7.3. Service 생성
1. Service 목록에서 생성 버튼을 클릭하여 Service 생성 페이지로 이동한다.

#### Service 목록 페이지
![IMG_081]

#### Service 생성 페이지
![IMG_082]
![IMG_083]
![IMG_084]

##### <div id='3-2-7-4'/> 3.2.7.4. Service 수정
1. Service 상세에서 수정 버튼을 클릭하여 Service 수정 페이지로 이동한다.

#### Service 상세 페이지
![IMG_085]

#### Service 수정 페이지
![IMG_086]
![IMG_087]
![IMG_088]

##### <div id='3-2-7-5'/> 3.2.7.5. Service 삭제
1. Service 상세에서 삭제 버튼을 클릭하면 Service 삭제 팝업창이 뜬다.

#### Service 상세 페이지
![IMG_089]

#### Service 삭제 팝업창
![IMG_090]
![IMG_091]


### <div id='3-2-8'/> 3.2.8. Storages 메뉴

#### <div id='3-2-8-1'/> 3.2.8.1. Persistent Volume Claim 목록 조회
1. Storages 메뉴를 클릭하여 Persistent Volume Claim 목록 페이지로 이동한다.

![IMG_092]

#### <div id='3-2-8-2'/> 3.2.8.2. Persistent Volume Claim 상세 조회
- Persistent Volume Claim 상세 페이지는 Details, Events, YAML 탭으로 구성된다.

1. Persistent Volume Claim 목록에서 Persistent Volume Claim 명을 클릭하여 Persistent Volume Claim 상세 페이지로 이동한다.

#### Persistent Volume Claim 목록 페이지
![IMG_093]

#### Persistent Volume Claim 상세 페이지
![IMG_094]
![IMG_095]
![IMG_096]

##### <div id='3-2-8-3'/> 3.2.8.3. Persistent Volume Claim 생성
1. Persistent Volume Claim 목록에서 생성 버튼을 클릭하여 Persistent Volume Claim 생성 페이지로 이동한다.

#### Persistent Volume Claim 목록 페이지
![IMG_097]

#### Persistent Volume Claim 생성 페이지
![IMG_098]
![IMG_099]
![IMG_100]


##### <div id='3-2-8-4'/> 3.2.8.4. Persistent Volume Claim 수정
1. Persistent Volume Claim 상세에서 수정 버튼을 클릭하여 Persistent Volume Claim 수정 페이지로 이동한다.

#### Persistent Volume Claim 상세 페이지
![IMG_101]

#### Persistent Volume Claim 수정 페이지
![IMG_102]
![IMG_103]
![IMG_104]

##### <div id='3-2-8-5'/> 3.2.8.5. Persistent Volume Claim 삭제
1. Persistent Volume Claim 상세에서 삭제 버튼을 클릭하면 Persistent Volume Claim 삭제 팝업창이 뜬다.

#### Persistent Volume Claim 상세 페이지
![IMG_105]

#### Persistent Volume Claim 삭제 팝업창
![IMG_106]
![IMG_107]

<br>

### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Use](/use-guide/Readme.md) > 사용자 포털 사용 가이드

----


[IMG_001]:../images/v1.2/container-platform-portal/user/cp-001.png
[IMG_002]:../images/v1.2/container-platform-portal/user/cp-002.png
[IMG_003]:../images/v1.2/container-platform-portal/user/cp-003.png
[IMG_004]:../images/v1.2/container-platform-portal/user/cp-004.png
[IMG_005]:../images/v1.2/container-platform-portal/user/cp-005.png
[IMG_006]:../images/v1.2/container-platform-portal/user/cp-006.png
[IMG_007]:../images/v1.2/container-platform-portal/user/cp-007.png
[IMG_008]:../images/v1.2/container-platform-portal/user/cp-008.png
[IMG_009]:../images/v1.2/container-platform-portal/user/cp-009.png
[IMG_010]:../images/v1.2/container-platform-portal/user/cp-010.png
[IMG_011]:../images/v1.2/container-platform-portal/user/cp-011.png
[IMG_012]:../images/v1.2/container-platform-portal/user/cp-012.png
[IMG_013]:../images/v1.2/container-platform-portal/user/cp-013.png
[IMG_014]:../images/v1.2/container-platform-portal/user/cp-014.png
[IMG_015]:../images/v1.2/container-platform-portal/user/cp-015.png
[IMG_016]:../images/v1.2/container-platform-portal/user/cp-016.png
[IMG_017]:../images/v1.2/container-platform-portal/user/cp-017.png
[IMG_018]:../images/v1.2/container-platform-portal/user/cp-018.png
[IMG_019]:../images/v1.2/container-platform-portal/user/cp-019.png
[IMG_020]:../images/v1.2/container-platform-portal/user/cp-020.png
[IMG_021]:../images/v1.2/container-platform-portal/user/cp-021.png
[IMG_022]:../images/v1.2/container-platform-portal/user/cp-022.png
[IMG_023]:../images/v1.2/container-platform-portal/user/cp-023.png
[IMG_024]:../images/v1.2/container-platform-portal/user/cp-024.png
[IMG_025]:../images/v1.2/container-platform-portal/user/cp-025.png
[IMG_026]:../images/v1.2/container-platform-portal/user/cp-026.png
[IMG_027]:../images/v1.2/container-platform-portal/user/cp-027.png
[IMG_028]:../images/v1.2/container-platform-portal/user/cp-028.png
[IMG_029]:../images/v1.2/container-platform-portal/user/cp-029.png
[IMG_030]:../images/v1.2/container-platform-portal/user/cp-030.png
[IMG_031]:../images/v1.2/container-platform-portal/user/cp-031.png
[IMG_032]:../images/v1.2/container-platform-portal/user/cp-032.png
[IMG_033]:../images/v1.2/container-platform-portal/user/cp-033.png
[IMG_034]:../images/v1.2/container-platform-portal/user/cp-034.png
[IMG_035]:../images/v1.2/container-platform-portal/user/cp-035.png
[IMG_036]:../images/v1.2/container-platform-portal/user/cp-036.png
[IMG_037]:../images/v1.2/container-platform-portal/user/cp-037.png
[IMG_038]:../images/v1.2/container-platform-portal/user/cp-038.png
[IMG_039]:../images/v1.2/container-platform-portal/user/cp-039.png
[IMG_040]:../images/v1.2/container-platform-portal/user/cp-040.png
[IMG_041]:../images/v1.2/container-platform-portal/user/cp-041.png
[IMG_042]:../images/v1.2/container-platform-portal/user/cp-042.png
[IMG_043]:../images/v1.2/container-platform-portal/user/cp-043.png
[IMG_044]:../images/v1.2/container-platform-portal/user/cp-044.png
[IMG_045]:../images/v1.2/container-platform-portal/user/cp-045.png
[IMG_046]:../images/v1.2/container-platform-portal/user/cp-046.png
[IMG_047]:../images/v1.2/container-platform-portal/user/cp-047.png
[IMG_048]:../images/v1.2/container-platform-portal/user/cp-048.png
[IMG_049]:../images/v1.2/container-platform-portal/user/cp-049.png
[IMG_050]:../images/v1.2/container-platform-portal/user/cp-050.png
[IMG_051]:../images/v1.2/container-platform-portal/user/cp-051.png
[IMG_052]:../images/v1.2/container-platform-portal/user/cp-052.png
[IMG_053]:../images/v1.2/container-platform-portal/user/cp-053.png
[IMG_054]:../images/v1.2/container-platform-portal/user/cp-054.png
[IMG_055]:../images/v1.2/container-platform-portal/user/cp-055.png
[IMG_056]:../images/v1.2/container-platform-portal/user/cp-056.png
[IMG_057]:../images/v1.2/container-platform-portal/user/cp-057.png
[IMG_058]:../images/v1.2/container-platform-portal/user/cp-058.png
[IMG_059]:../images/v1.2/container-platform-portal/user/cp-059.png
[IMG_060]:../images/v1.2/container-platform-portal/user/cp-060.png
[IMG_061]:../images/v1.2/container-platform-portal/user/cp-061.png
[IMG_062]:../images/v1.2/container-platform-portal/user/cp-062.png
[IMG_063]:../images/v1.2/container-platform-portal/user/cp-063.png
[IMG_064]:../images/v1.2/container-platform-portal/user/cp-064.png
[IMG_065]:../images/v1.2/container-platform-portal/user/cp-065.png
[IMG_066]:../images/v1.2/container-platform-portal/user/cp-066.png
[IMG_067]:../images/v1.2/container-platform-portal/user/cp-067.png
[IMG_068]:../images/v1.2/container-platform-portal/user/cp-068.png
[IMG_069]:../images/v1.2/container-platform-portal/user/cp-069.png
[IMG_070]:../images/v1.2/container-platform-portal/user/cp-070.png
[IMG_071]:../images/v1.2/container-platform-portal/user/cp-071.png
[IMG_072]:../images/v1.2/container-platform-portal/user/cp-072.png
[IMG_073]:../images/v1.2/container-platform-portal/user/cp-073.png
[IMG_074]:../images/v1.2/container-platform-portal/user/cp-074.png
[IMG_075]:../images/v1.2/container-platform-portal/user/cp-075.png
[IMG_076]:../images/v1.2/container-platform-portal/user/cp-076.png
[IMG_077]:../images/v1.2/container-platform-portal/user/cp-077.png
[IMG_078]:../images/v1.2/container-platform-portal/user/cp-078.png
[IMG_079]:../images/v1.2/container-platform-portal/user/cp-079.png
[IMG_080]:../images/v1.2/container-platform-portal/user/cp-080.png
[IMG_081]:../images/v1.2/container-platform-portal/user/cp-081.png
[IMG_082]:../images/v1.2/container-platform-portal/user/cp-082.png
[IMG_083]:../images/v1.2/container-platform-portal/user/cp-083.png
[IMG_084]:../images/v1.2/container-platform-portal/user/cp-084.png
[IMG_085]:../images/v1.2/container-platform-portal/user/cp-085.png
[IMG_086]:../images/v1.2/container-platform-portal/user/cp-086.png
[IMG_087]:../images/v1.2/container-platform-portal/user/cp-087.png
[IMG_088]:../images/v1.2/container-platform-portal/user/cp-088.png
[IMG_089]:../images/v1.2/container-platform-portal/user/cp-089.png
[IMG_090]:../images/v1.2/container-platform-portal/user/cp-090.png
[IMG_091]:../images/v1.2/container-platform-portal/user/cp-091.png
[IMG_092]:../images/v1.2/container-platform-portal/user/cp-092.png
[IMG_093]:../images/v1.2/container-platform-portal/user/cp-093.png
[IMG_094]:../images/v1.2/container-platform-portal/user/cp-094.png
[IMG_095]:../images/v1.2/container-platform-portal/user/cp-095.png
[IMG_096]:../images/v1.2/container-platform-portal/user/cp-096.png
[IMG_097]:../images/v1.2/container-platform-portal/user/cp-097.png
[IMG_098]:../images/v1.2/container-platform-portal/user/cp-098.png
[IMG_099]:../images/v1.2/container-platform-portal/user/cp-099.png
[IMG_100]:../images/v1.2/container-platform-portal/user/cp-100.png
[IMG_101]:../images/v1.2/container-platform-portal/user/cp-101.png
[IMG_102]:../images/v1.2/container-platform-portal/user/cp-102.png
[IMG_103]:../images/v1.2/container-platform-portal/user/cp-103.png
[IMG_104]:../images/v1.2/container-platform-portal/user/cp-104.png
[IMG_105]:../images/v1.2/container-platform-portal/user/cp-105.png
[IMG_106]:../images/v1.2/container-platform-portal/user/cp-106.png
[IMG_107]:../images/v1.2/container-platform-portal/user/cp-107.png
[IMG_108]:../images/v1.2/container-platform-portal/user/cp-108.png