## Table of Contents

1. [문서 개요](#1)
    * [1.1. 목적](#1-1)
    * [1.2. 범위](#1-2)
2. [컨테이너 플랫폼 운영자포털 접속](#2)
    * [2.1. 컨테이너 플랫폼 운영자포털 회원가입](#2-1)
    * [2.2. 컨테이너 플랫폼 운영자포털 로그인](#2-2)    
3. [컨테이너 플랫폼 운영자포털 메뉴얼](#3)
    * [3.1. 컨테이너 플랫폼 운영자포털 메뉴 구성](#3-1)
    * [3.2. 컨테이너 플랫폼 운영자포털 메뉴 설명](#3-2)
    * [3.2.1. Overview](#3-2-1)
    * [3.2.1.1. Overview 목록 조회](#3-2-1-1)
    * [3.2.1.2. Overview Namespace 변경](#3-2-1-2)
    * [3.2.1.3. Overview My info 변경](#3-2-1-3)
    * [3.2.2. Clusters 메뉴](#3-2-2)
    * [3.2.2.1. Namespaces](#3-2-2-1)
    * [3.2.2.1.1. Namespace 목록 조회](#3-2-2-1-1)
    * [3.2.2.1.2. Namespace 상세 조회](#3-2-2-1-2)
    * [3.2.2.1.3. Namespace 생성](#3-2-2-1-3)
    * [3.2.2.1.4. Namespace 수정](#3-2-2-1-4)
    * [3.2.2.1.5. Namespace 삭제](#3-2-2-1-5)
    * [3.2.2.2. Nodes](#3-2-2-2)
    * [3.2.2.2.1. Node 목록 조회](#3-2-2-2-1)
    * [3.2.2.2.2. Node 상세 조회](#3-2-2-2-2)
    * [3.2.3. Workloads 메뉴](#3-2-3)
    * [3.2.3.1. Deployments](#3-2-3-1)
    * [3.2.3.1.1. Deployment 목록 조회](#3-2-3-1-1)
    * [3.2.3.1.2. Deployment 상세 조회](#3-2-3-1-2)
    * [3.2.3.1.3. Deployment 생성](#3-2-3-1-3)
    * [3.2.3.1.4. Deployment 수정](#3-2-3-1-4)
    * [3.2.3.1.5. Deployment 삭제](#3-2-3-1-5)
    * [3.2.3.2. Pods](#3-2-3-2)
    * [3.2.3.2.1. Pod 목록 조회](#3-2-3-2-1)
    * [3.2.3.2.2. Pod 상세 조회](#3-2-3-2-2)
    * [3.2.3.2.3. Pod 생성](#3-2-3-2-3)
    * [3.2.3.2.4. Pod 수정](#3-2-3-2-4)
    * [3.2.3.2.5. Pod 삭제](#3-2-3-2-5)
    * [3.2.3.3. Replica Sets](#3-2-3-3)
    * [3.2.3.3.1. Replica Set 목록 조회](#3-2-3-3-1)
    * [3.2.3.3.2. Replica Set 상세 조회](#3-2-3-3-2)
    * [3.2.3.3.3. Replica Set 생성](#3-2-3-3-3)
    * [3.2.3.3.4. Replica Set 수정](#3-2-3-3-4)
    * [3.2.3.3.5. Replica Set 삭제](#3-2-3-3-5)
    * [3.2.4. Services 메뉴](#3-2-4)
    * [3.2.4.1. Service 목록 조회](#3-2-4-1)
    * [3.2.4.2. Service 상세 조회](#3-2-4-2)
    * [3.2.4.3. Service 생성](#3-2-4-3)
    * [3.2.4.4. Service 수정](#3-2-4-4)
    * [3.2.4.5. Service 삭제](#3-2-4-5)
    * [3.2.5. Storages 메뉴](#3-2-5)
    * [3.2.5.1. Persistent Volumes](#3-2-5-1)
    * [3.2.5.1.1. Persistent Volume 목록 조회](#3-2-5-1-1)
    * [3.2.5.1.2. Persistent Volume 상세 조회](#3-2-5-1-2)
    * [3.2.5.1.3. Persistent Volume 생성](#3-2-5-1-3)
    * [3.2.5.1.4. Persistent Volume 수정](#3-2-5-1-4)
    * [3.2.5.1.5. Persistent Volume 삭제](#3-2-5-1-5)
    * [3.2.5.2. Persistent Volume Claims](#3-2-5-2)
    * [3.2.5.2.1. Persistent Volume Claim 목록 조회](#3-2-5-2-1)
    * [3.2.5.2.2. Persistent Volume Claim 상세 조회](#3-2-5-2-2)
    * [3.2.5.2.3. Persistent Volume Claim 생성](#3-2-5-2-3)
    * [3.2.5.2.4. Persistent Volume Claim 수정](#3-2-5-2-4)
    * [3.2.5.2.5. Persistent Volume Claim 삭제](#3-2-5-2-5)
    * [3.2.5.3. Storage Classes](#3-2-5-3)
    * [3.2.5.3.1. Storage Class 목록 조회](#3-2-5-3-1)
    * [3.2.5.3.2. Storage Class 상세 조회](#3-2-5-3-2)
    * [3.2.5.3.3. Storage Class 생성](#3-2-5-3-3)
    * [3.2.5.3.4. Storage Class 수정](#3-2-5-3-4)
    * [3.2.5.3.5. Storage Class 삭제](#3-2-5-3-5)
    * [3.2.6. Managements 메뉴](#3-2-6)
    * [3.2.6.1. Users](#3-2-6-1)
    * [3.2.6.1.1. 클러스터 관리자 조회](#3-2-6-1-1)  
    * [3.2.6.1.2. 클러스터 관리자 상세 조회 ](#3-2-6-1-2)  
    * [3.2.6.1.3. 일반 사용자 목록 조회](#3-2-6-1-3)  
    * [3.2.6.1.4. 일반 사용자 상세 조회](#3-2-6-1-4)  
    * [3.2.6.1.5. User 생성](#3-2-6-1-5)  
    * [3.2.6.1.6. User 수정](#3-2-6-1-6)  
    * [3.2.6.1.7. User 삭제](#3-2-6-1-7)  
    * [3.2.6.2. Roles](#3-2-6-2)  
    * [3.2.6.2.1. Role 목록 조회](#3-2-6-2-1)
    * [3.2.6.2.2. Role 상세 조회](#3-2-6-2-2)
    * [3.2.6.2.3. Role 생성](#3-2-6-2-3)
    * [3.2.6.2.4. Role 수정](#3-2-6-2-4)
    * [3.2.6.2.5. Role 삭제](#3-2-6-2-5)
    * [3.2.6.3. Resource Quotas](#3-2-6-3)
    * [3.2.6.3.1. Resource Quota 목록 조회](#3-2-6-3-1)
    * [3.2.6.3.2. Resource Quota 상세 조회](#3-2-6-3-2)
    * [3.2.6.3.3. Resource Quota 생성](#3-2-6-3-3)
    * [3.2.6.3.4. Resource Quota 수정](#3-2-6-3-4)
    * [3.2.6.3.5. Resource Quota 삭제](#3-2-6-3-5)
    * [3.2.6.4. Limit Ranges](#3-2-6-4)
    * [3.2.6.4.1. Limit Range 목록 조회](#3-2-6-4-1)
    * [3.2.6.4.2. Limit Range 상세 조회](#3-2-6-4-2)
    * [3.2.6.4.3. Limit Range 생성](#3-2-6-4-3)
    * [3.2.6.4.4. Limit Range 수정](#3-2-6-4-4)
    * [3.2.6.4.5. Limit Range 삭제](#3-2-6-4-5)



----

# <div id='1'/> 1. 문서 개요

## <div id='1-1'/> 1.1. 목적
본 문서는 컨테이너 플랫폼 운영자포털 사용 방법에 대해 기술하였다.

## <div id='1-2'/> 1.2. 범위
본 문서는 Windows 환경을 기준으로 컨테이너 플랫폼 운영자포털의 사용 방법에 대해 기술하였다.

# <div id='2'/> 2. 컨테이너 플랫폼 운영자포털 접속

## <div id='2-1'/> 2.1. 컨테이너 플랫폼 운영자포털 회원가입
1. 컨테이너 플랫폼 운영자포털에 접속하여 "회원가입" 버튼을 클릭한다.

![IMG_001]

2. Kubernetes Cluster 정보, 생성할 Namespace 명, User 정보를 입력 후 "회원가입" 버튼을 클릭하여 컨테이너 플랫폼 운영자포털에 회원가입을 한다.
> 아래 이미지는 이해를 돕기위한 예시 정보이다.

![IMG_002]
![IMG_003]

## <div id='2-2'/> 2.2. 컨테이너 플랫폼 운영자포털 로그인
1.  사용자 ID와 비밀번호를 입력하고 "로그인" 버튼을 클릭하여 컨테이너 플랫폼 운영자포털에 로그인 한다.

![IMG_004]

# <div id='3'/> 3. 컨테이너 플랫폼 운영자포털 메뉴얼


## <div id='3-1'/> 3.1. 컨테이너 플랫폼 운영자포털 메뉴 구성
| <center>메뉴</center> | <center>분류</center> | <center>설명</center> |
| :--- | :--- | :--- |
|| Overview | 컨테이너 플랫폼 대시보드 |
| Clusters | Namespaces | Namespaces 정보 관리 |
|| Nodes | Nodes 정보 관리 |
| Workloads | Deployments | Deployments 정보 관리 |
|| Pods | Pods 정보 관리 |
|| Replica Sets | Replica Sets 정보 관리 |
| Services | Services | Services 정보 관리 |
| Storages | Persistent Volumes | Persistent Volumes 정보 관리 |
|| Persistent Volume Claims | Persistent Volume Claims 정보 관리 |
|| Storage Classes | Storage Classes 정보 관리 |
| Managements | Users | 사용자 관리 |
|| Roles | Roles 관리 |
|| Resource Quotas | Resource Quotas 정보 관리 |
|| Limit Ranges | Limit Ranges 정보 관리 |


## <div id='3-2'/> 3.2. 컨테이너 플랫폼 운영자포털 메뉴 설명
본 장에서는 컨테이너 플랫폼 운영자포털의 메뉴에 대한 설명을 기술하였다.

### <div id='3-2-1'/> 3.2.1. Overview
#### <div id='3-2-1-1'/> 3.2.1.1. Overview 목록 조회
- Namespace, Deployment, Pod, User의 개수와 Deployment, Pod, ReplicaSet의 차트를 조회한다.

1. 로그인 후 첫 화면으로 Overview 페이지로 이동한다.

![IMG_005]

#### <div id='3-2-1-2'/> 3.2.1.2. Overview Namespace 변경
- 화면 상단 Select Box를 누른 후 전체 Namespace 목록에서 원하는 Namespace를 선택한다.

1. Select Box에서 Namespace를 선택하면 해당 Namespace에 대한 Overview 정보가 조회된다.

![IMG_006]
![IMG_007]

#### <div id='3-2-1-3'/> 3.2.1.3. Overview My info 변경
- 화면 우측상단 톱니바퀴 아이콘을 클릭한다.

1. My Info 팝업창에서 클러스터관리자 계정의 Password, E-mail 정보를 수정한다.

![IMG_008]

### <div id='3-2-2'/> 3.2.2. Clusters 메뉴
#### <div id='3-2-2-1'/> 3.2.2.1. Namespaces
##### <div id='3-2-2-1-1'/> 3.2.2.1.1. Namespace 목록 조회
1. Clusters 메뉴의 Namespaces를 클릭하여 Namespace 목록 페이지로 이동한다.

![IMG_009]

##### <div id='3-2-2-1-2'/> 3.2.2.1.2. Namespace 상세 조회
1. Namespace 목록에서 Namespace명을 클릭하여 Namespace 상세 페이지로 이동한다.

#### Namespace 상세 페이지
![IMG_010]

##### <div id='3-2-2-1-3'/> 3.2.2.1.3. Namespace 생성
- Namespace 생성 페이지에서 해당 Namespace의 관리자, Resource Quotas, Limit Ranges를 지정할 수 있다.

1. Namespace 목록에서 생성 버튼을 클릭하여 Namespace 생성 페이지로 이동한다.

#### Namespace 목록 페이지
![IMG_011]

#### Namespace 생성 페이지
![IMG_012]
![IMG_013]
![IMG_014]
![IMG_015]
![IMG_016]

##### <div id='3-2-2-1-4'/> 3.2.2.1.4. Namespace 수정
Namespace 수정 페이지에서 해당 Namespace의 관리자, Resource Quotas, Limit Ranges를 수정할 수 있다.

1. Namespace 상세에서 수정 버튼을 클릭하여 Namespace 수정 페이지로 이동한다.

#### Namespace 상세 페이지
![IMG_017]

#### Namespace 수정 페이지
![IMG_018]
![IMG_019]

##### <div id='3-2-2-1-5'/> 3.2.2.1.5. Namespace 삭제
1. Namespace 상세에서 삭제 버튼을 클릭하여 Namespace 삭제를 한다.

#### Namespace 상세 페이지
![IMG_020]

#### Namespace 삭제 팝업창
![IMG_021]
![IMG_022]

#### <div id='3-2-2-2'/> 3.2.2.2. Nodes
##### <div id='3-2-2-2-1'/> 3.2.2.2.1. Node 목록 조회
1. Clusters 메뉴의 Nodes를 클릭하여 Node 목록 페이지로 이동한다.
![IMG_023]

##### <div id='3-2-2-2-2'/> 3.2.2.2.2. Node 상세 조회
1. Node 목록에서 Node명을 클릭하여 Node 상세 페이지로 이동한다.
#### Node 상세 페이지
![IMG_024]

### <div id='3-2-3'/> 3.2.3. Workloads 메뉴
#### <div id='3-2-3-1'/> 3.2.3.1 Deployment
##### <div id='3-2-3-1-1'/> 3.2.3.1.1. Deployment 목록 조회
1. Workloads의 Deployments를 클릭하여 Deployment 목록 페이지로 이동한다.

![IMG_025]

##### <div id='3-2-3-1-2'/> 3.2.3.1.2. Deployment 상세 조회
1. Deployment 목록에서 Deployment명을 클릭하여 Deployment 상세 페이지로 이동한다.

#### Deployment 상세 페이지
![IMG_026]

##### <div id='3-2-3-1-3'/> 3.2.3.1.3. Deployment 생성
1. Deployment 목록에서 생성 버튼을 클릭할 시 Deployment 생성 팝업창이 뜬다.

#### Deployment 목록 페이지
![IMG_027]

#### Deployment 생성 팝업창
![IMG_028]

##### <div id='3-2-3-1-4'/> 3.2.3.1.4. Deployment 수정
1. Deployment 상세에서 수정 버튼을 클릭할 시 Deployment 수정 팝업창이 뜬다.

#### Deployment 상세 페이지
![IMG_029]

#### Deployment 수정 팝업창
![IMG_030]

##### <div id='3-2-3-1-5'/> 3.2.3.1.5. Deployment 삭제
1. Deployment 상세에서 삭제 버튼을 클릭할 시 Deployment가 삭제된다.

#### Deployment 상세 페이지
![IMG_031]

#### Deployment 삭제 팝업창
![IMG_032]

#### <div id='3-2-3-2'/> 3.2.3.2. Pods
##### <div id='3-2-3-2-1'/> 3.2.3.2.1. Pod 목록 조회
1. Workloads의 Pods를 클릭하여 Pod 목록 페이지로 이동한다.

![IMG_033]

##### <div id='3-2-3-2-2'/> 3.2.3.2.2. Pod 상세 조회
1. Pod 목록에서 Pod명을 클릭하여 Pod 상세 페이지로 이동한다.

#### Pod 상세 페이지
![IMG_034]

##### <div id='3-2-3-2-3'/> 3.2.3.2.3. Pod 생성
1. Pod 목록에서 생성 버튼을 클릭할 시 Pod 생성 팝업창이 뜬다.

#### Pod 목록 페이지
![IMG_035]

#### Pod 생성 팝업창
![IMG_036]

##### <div id='3-2-3-2-4'/> 3.2.3.2.4. Pod 수정
1. Pod 상세에서 수정 버튼을 클릭할 시 Pod 수정 팝업창이 뜬다.

#### Pod 상세 페이지
![IMG_037]

#### Pod 수정 팝업창
![IMG_038]

##### <div id='3-2-3-2-5'/> 3.2.3.2.5. Pod 삭제
1. Pod 상세에서 삭제 버튼을 클릭할 시 Pod 삭제가 삭제된다.

#### Pod 상세 페이지
![IMG_039]

#### Pod 삭제 팝업창
![IMG_040]


#### <div id='3-2-3-3'/> 3.2.3.3. Replica Sets
##### <div id='3-2-3-3-1'/> 3.2.3.3.1. Replica Set 목록 조회
1. Workloads의 Replica Sets을 클릭하여 Replica Set 목록 페이지로 이동한다.

![IMG_041]

##### <div id='3-2-3-3-2'/> 3.2.3.3.2. Replica Set 상세 조회
1. Replica Set 목록에서 Replica Set명을 클릭하여 Replica Set 상세 페이지로 이동한다.

#### Replica Set 상세 페이지
![IMG_042]

##### <div id='3-2-3-3-3'/> 3.2.3.3.3. Replica Set 생성
1. Replica Set 목록에서 생성 버튼을 클릭할 시 Replica Set 생성 팝업창이 뜬다.

#### Replica Set 목록 페이지
![IMG_043]

#### Replica Set  생성 팝업창
![IMG_044]

##### <div id='3-2-3-3-4'/> 3.2.3.3.4. Replica Set 수정
1. Replica Set 상세에서 수정 버튼을 클릭할 시 Replica Set 수정 팝업창이 뜬다.

#### Replica Set 상세 페이지
![IMG_045]

#### Replica Set 수정 팝업창
![IMG_046]

##### <div id='3-2-3-3-5'/> 3.2.3.3.5. Replica Set 삭제
1. Replica Set 상세에서 삭제 버튼을 클릭할 시 Replica Set이 삭제된다.

#### Replica Set 상세 페이지
![IMG_047]

#### Replica Set 삭제 팝업창
![IMG_048]

### <div id='3-2-4'/> 3.2.4. Services 메뉴
#### <div id='3-2-4-1'/> 3.2.4.1. Service 목록 조회
1. Services를 클릭하여 Service 목록 페이지로 이동한다.

![IMG_049]

#### <div id='3-2-4-2'/> 3.2.4.2. Service 상세 조회
1. Service 목록에서 Service명을 클릭하여 Service 상세 페이지로 이동한다.

#### Service 상세 페이지
![IMG_050]

#### <div id='3-2-4-3'/> 3.2.4.3. Service 생성
1. Service 목록에서 생성 버튼을 클릭할 시 Service 생성 팝업창이 뜬다.

#### Service 목록 페이지
![IMG_051]

#### Service 생성 팝업창
![IMG_052]

#### <div id='3-2-4-4'/> 3.2.4.4. Service 수정
1. Service 상세에서 수정 버튼을 클릭할 시 Service 수정 팝업창이 뜬다.

#### Service 상세 페이지
![IMG_053]

#### Service 수정 팝업창
![IMG_054]

#### <div id='3-2-4-5'/> 3.2.4.5. Service 삭제

1. Service 상세에서 삭제 버튼을 클릭할 시 Service가 삭제된다.

#### Service 상세 페이지
![IMG_055]

#### Service 삭제 팝업창
![IMG_056]

### <div id='3-2-5'/> 3.2.5. Storages 메뉴
#### <div id='3-2-5-1'/> 3.2.5.1. Persistent Volumes
##### <div id='3-2-5-1-1'/> 3.2.5.1.1. Persistent Volume 목록 조회
1. Storages의 Persistent Volumes를 클릭하여 Persistent Volume 목록 페이지로 이동한다.
![IMG_057]

##### <div id='3-2-5-1-2'/> 3.2.5.1.2. Persistent Volume 상세 조회
1. Persistent Volume 목록에서 Persistent Volume명을 클릭하여 Persistent Volume 상세 페이지로 이동한다.

#### Persistent Volume 상세 페이지
![IMG_058]

##### <div id='3-2-5-1-3'/> 3.2.5.1.3. Persistent Volumee 생성
1. Persistent Volume 목록에서 생성 버튼을 클릭할 시 Persistent Volume 생성 팝업창이 뜬다.

#### Persistent Volume 목록 페이지
![IMG_059]

#### Persistent Volume 생성 팝업창
![IMG_060]


##### <div id='3-2-5-1-4'/> 3.2.5.1.4. Persistent Volume 수정
1. Persistent Volume 상세에서 수정 버튼을 클릭할 시 Persistent Volume 수정 팝업창이 뜬다.

#### Persistent Volume 상세 페이지
![IMG_061]

#### Persistent Volume 수정 팝업창
![IMG_062]

##### <div id='3-2-5-1-5'/> 3.2.5.1.5. Persistent Volume 삭제
1. Persistent Volume 상세에서 삭제 버튼을 클릭 할 시 Persistent Volume이 삭제된다.

#### Persistent Volume 상세 페이지
![IMG_063]

#### Persistent Volume 삭제 팝업창
![IMG_064]

#### <div id='3-2-5-2'/> 3.2.5.2. Persistent Volume Claims
##### <div id='3-2-5-2-1'/> 3.2.5.2.1. Persistent Volume Claim 목록 조회
1. Storages의 Persistent Volume Claims를 클릭하여 Persistent Volume Claim 목록 페이지로 이동한다.
![IMG_065]

##### <div id='3-2-5-2-2'/> 3.2.5.2.2. Persistent Volume Claim 상세 조회
1. Persistent Volume Claim 목록에서 Persistent Volume명을 클릭하여 Persistent Volume Claim 상세 페이지로 이동한다.

#### Persistent Volume Claim 상세 페이지
![IMG_066]

##### <div id='3-2-5-2-3'/> 3.2.5.2.3. Persistent Volumee Claim 생성
1. Persistent Volume Claim 목록에서 생성 버튼을 클릭할 시 Persistent Volume Claim 생성 팝업창이 뜬다.

#### Persistent Volume Claim 목록 페이지
![IMG_067]

#### Persistent Volume Claim 생성 팝업창
![IMG_068]

##### <div id='3-2-5-2-4'/> 3.2.5.2.4. Persistent Volume Claim 수정
1. Persistent Volume Claim 상세에서 수정 버튼을 클릭할 시 Persistent Volume Claim 수정 팝업창이 뜬다.

#### Persistent Volume Claim 상세 페이지
![IMG_069]

#### Persistent Volume Claim 수정 팝업창
![IMG_070]

##### <div id='3-2-5-2-5'/> 3.2.5.2.5. Persistent Volume Claim 삭제
1. Persistent Volume Claim 상세에서 삭제 버튼을 클릭할 시 Persistent Volume Claim이 삭제된다.

#### Persistent Volume Claim 상세 페이지
![IMG_071]

#### Persistent Volume Claim 삭제 팝업창
![IMG_072]

#### <div id='3-2-5-3'/> 3.2.5.3. Storage Classes
##### <div id='3-2-5-3-1'/> 3.2.5.3.1. Storage Class 목록 조회
1. Storages의 Storage Classes를 클릭하여 Storage Class 목록 페이지로 이동한다.
![IMG_073]

##### <div id='3-2-5-3-2'/> 3.2.5.3.2. Storage Class 상세 조회
1. Storage Class 목록에서 Storage Class명을 클릭하여 Storage Class 상세 페이지로 이동한다.

#### Storage Class 상세 페이지
![IMG_074]

##### <div id='3-2-5-3-3'/> 3.2.5.3.3. Storage Class 생성
1. Storage Class 목록에서 생성 버튼을 클릭할 시 Storage Class 생성 팝업창이 뜬다.

#### Storage Class 목록 페이지
![IMG_075]

#### Storage Class 생성 팝업창
![IMG_076]

##### <div id='3-2-5-3-4'/> 3.2.5.3.4. Storage Class 수정
1. Storage Class 상세에서 수정 버튼을 클릭할 시 Storage Class 수정 팝업창이 뜬다.

#### Storage Class 상세 페이지
![IMG_077]

#### Storage Class 수정 팝업창
![IMG_078]

##### <div id='3-2-5-3-5'/> 3.2.5.3.5. Storage Class 삭제
1. Storage Class 상세에서 삭제 버튼을 클릭할 시 Storage Class가 삭제된다.

#### Storage Class 상세 페이지
![IMG_079]

#### Storage Class 삭제 팝업창
![IMG_080]

### <div id='3-2-6'/> 3.2.6. Managements
#### <div id='3-2-6-1'/> 3.2.6.1. Users
##### <div id='3-2-6-1-1'/> 3.2.6.1.1. 클러스터 관리자 조회
1. Managements 메뉴의 Users를 선택하고 Administrator탭을 클릭하여 클러스터 관리자를 조회한다.

![IMG_081]

##### <div id='3-2-6-1-2'/> 3.2.6.1.2. 클러스터 관리자 상세 조회
1.  클러스터 관리자 User ID를 클릭하여 클러스터 관리자 상세 조회 페이지로 이동한다.

#### 클러스터 관리자 상세 조회 페이지
![IMG_082]

##### <div id='3-2-6-1-3'/> 3.2.6.1.3.  일반 사용자 목록 조회
1. Managements 메뉴의 Users를 선택하고 User탭을 클릭하여 일반사용자 목록을 조회한다.

![IMG_083]

##### <div id='3-2-6-1-4'/> 3.2.6.1.4. 일반 사용자 상세 조회
1.  일반 사용자 User ID를 클릭하여 일반 사용자 상세 조회 페이지로 이동한다.

####  일반 사용자 상세 조회 페이지
![IMG_084]


##### <div id='3-2-6-1-5'/> 3.2.6.1.5. User 생성
- User 생성 페이지에서 사용자 계정 등록 및 해당 사용자가 이용할 Namespace와 Role을 지정할 수 있다.

1. User 목록에서 생성 버튼을 클릭하여 User 생성 페이지로 이동한다.

#### User 목록 페이지
![IMG_085]

#### User 생성 팝업창
![IMG_086]
![IMG_087]
![IMG_088]

##### <div id='3-2-6-1-6'/> 3.2.6.1.6. User 수정
- User 수정 페이지에서 사용자 계정 수정 및 해당 사용자가 이용할 Namespace와 Role을 수정할 수 있다.

1. User 상세에서 수정 버튼을 클릭하여 User 수정 페이지로 이동한다.

#### User 상세 페이지
![IMG_089]

#### User 수정 페이지
![IMG_090]
![IMG_091]
![IMG_092]

##### <div id='3-2-6-1-7'/> 3.2.6.1.7. User 삭제
1. User 상세에서 삭제 버튼을 클릭할 시 사용자가 삭제된다.

#### User 상세 페이지
![IMG_093]

#### User 삭제 팝업창
![IMG_094]


#### <div id='3-2-6-2'/> 3.2.6.2. Roles
##### <div id='3-2-6-2-1'/> 3.2.6.2.1. Role 목록 조회
1. Managements 메뉴의 Roles를 클릭하여 Role 목록 페이지로 이동한다.
![IMG_095]

##### <div id='3-2-6-2-2'/> 3.2.6.2.2. Role 상세 조회
1. Role 목록에서 Role명을 클릭하여 Role 상세 페이지로 이동한다.

#### Role 상세 페이지
![IMG_096]

##### <div id='3-2-6-2-3'/> 3.2.6.2.3. Role 생성
1. Role 목록에서 생성 버튼을 클릭할 시 Role 생성 팝업창이 뜬다.

#### Role 목록 페이지
![IMG_097]

#### Role 생성 팝업창
![IMG_098]

##### <div id='3-2-6-2-4'/> 3.2.6.2.4. Role 수정
1. Role 상세에서 수정 버튼을 클릭할 시 Role 수정 팝업창이 뜬다.

#### Role 상세 페이지
![IMG_099]

#### Role 수정 팝업창
![IMG_100]

##### <div id='3-2-6-2-5'/> 3.2.6.2.5. Role 삭제
1. Role 상세에서 삭제 버튼을 클릭할 시 Role이 삭제된다.

#### Role 상세 페이지
![IMG_101]

#### Role 삭제 팝업창
![IMG_102]

#### <div id='3-2-6-3'/> 3.2.6.3. Resource Quotas
##### <div id='3-2-6-3-1'/> 3.2.6.3.1. Resource Quota 목록 조회
1. Managements 메뉴의 Resource Quotas를 클릭하여 Resource Quota 목록 페이지로 이동한다.
![IMG_103]

##### <div id='3-2-6-3-2'/> 3.2.6.3.2. Resource Quota 상세 조회
1. Resource Quota 목록에서 Resource Quota명을 클릭하여 Resource Quota 상세 페이지로 이동한다.

#### Resource Quota 상세 페이지
![IMG_104]

##### <div id='3-2-6-3-3'/> 3.2.6.3.3. Resource Quota 생성
1. Resource Quota 목록에서 생성 버튼을 클릭할 시 Resource Quota 생성 팝업창이 뜬다.

#### Resource Quota 목록 페이지
![IMG_105]

#### Resource Quota 생성 팝업창
![IMG_106]

##### <div id='3-2-6-3-4'/> 3.2.6.3.4. Resource Quota 수정
1. Resource Quota 상세에서 수정 버튼을 클릭할 시 Resource Quota 수정 팝업창이 뜬다.

#### Resource Quota 상세 페이지
![IMG_107]

#### Resource Quota 수정 팝업창
![IMG_108]

##### <div id='3-2-6-3-5'/> 3.2.6.3.5. Resource Quota 삭제
1. Resource Quota 상세에서 삭제 버튼을 클릭할 시 Resource Quota가 삭제된다.

#### Resource Quota 상세 페이지
![IMG_109]

#### Resource Quota 삭제 팝업창
![IMG_110]

#### <div id='3-2-6-4'/> 3.2.6.4. Limit Ranges
##### <div id='3-2-6-4-1'/> 3.2.6.4.1. Limit Range 목록 조회
1. Managements 메뉴의 Limit Ranges를 클릭하여 Limit Range 목록 페이지로 이동한다.
![IMG_111]

##### <div id='3-2-6-4-2'/> 3.2.6.4.2. Limit Range 상세 조회
1. Limit Range 목록에서 Limit Range명을 클릭하여 Limit Range 상세 페이지로 이동한다.

#### Limit Range 상세 페이지
![IMG_112]

##### <div id='3-2-6-4-3'/> 3.2.6.4.3. Limit Range 생성
1. Limit Range 목록에서 생성 버튼을 클릭할 시 Limit Range 생성 팝업창이 뜬다.

#### Limit Range 목록 페이지
![IMG_113]

#### Limit Range 생성 팝업창
![IMG_114]

##### <div id='3-2-6-4-4'/> 3.2.6.4.4. Limit Range 수정
1. Limit Range 상세에서 수정 버튼을 클릭할 시 Limit Range 수정 팝업창이 뜬다.

#### Limit Range 상세 페이지
![IMG_115]

#### Limit Range 수정 팝업창
![IMG_116]

##### <div id='3-2-6-4-5'/> 3.2.6.4.5. Limit Range 삭제
1. Limit Range 상세에서 삭제 버튼을 클릭할 시 Limit Range가 삭제된다.

#### Limit Range 상세 페이지
![IMG_117]

#### Limit Range 삭제 팝업창
![IMG_118]

----

[IMG_001]:../images/container-platform/admin-portal/cp-001.png
[IMG_002]:../images/container-platform/admin-portal/cp-002.png
[IMG_003]:../images/container-platform/admin-portal/cp-003.png
[IMG_004]:../images/container-platform/admin-portal/cp-004.png
[IMG_005]:../images/container-platform/admin-portal/cp-005.png
[IMG_006]:../images/container-platform/admin-portal/cp-006.png
[IMG_007]:../images/container-platform/admin-portal/cp-007.png
[IMG_008]:../images/container-platform/admin-portal/cp-008.png
[IMG_009]:../images/container-platform/admin-portal/cp-009.png
[IMG_010]:../images/container-platform/admin-portal/cp-010.png
[IMG_011]:../images/container-platform/admin-portal/cp-011.png
[IMG_012]:../images/container-platform/admin-portal/cp-012.png
[IMG_013]:../images/container-platform/admin-portal/cp-013.png
[IMG_014]:../images/container-platform/admin-portal/cp-014.png
[IMG_015]:../images/container-platform/admin-portal/cp-015.png
[IMG_016]:../images/container-platform/admin-portal/cp-016.png
[IMG_017]:../images/container-platform/admin-portal/cp-017.png
[IMG_018]:../images/container-platform/admin-portal/cp-018.png
[IMG_019]:../images/container-platform/admin-portal/cp-019.png
[IMG_020]:../images/container-platform/admin-portal/cp-020.png
[IMG_021]:../images/container-platform/admin-portal/cp-021.png
[IMG_022]:../images/container-platform/admin-portal/cp-022.png
[IMG_023]:../images/container-platform/admin-portal/cp-023.png
[IMG_024]:../images/container-platform/admin-portal/cp-024.png
[IMG_025]:../images/container-platform/admin-portal/cp-025.png
[IMG_026]:../images/container-platform/admin-portal/cp-026.png
[IMG_027]:../images/container-platform/admin-portal/cp-027.png
[IMG_028]:../images/container-platform/admin-portal/cp-028.png
[IMG_029]:../images/container-platform/admin-portal/cp-029.png
[IMG_030]:../images/container-platform/admin-portal/cp-030.png
[IMG_031]:../images/container-platform/admin-portal/cp-031.png
[IMG_032]:../images/container-platform/admin-portal/cp-032.png
[IMG_033]:../images/container-platform/admin-portal/cp-033.png
[IMG_034]:../images/container-platform/admin-portal/cp-034.png
[IMG_035]:../images/container-platform/admin-portal/cp-035.png
[IMG_036]:../images/container-platform/admin-portal/cp-036.png
[IMG_037]:../images/container-platform/admin-portal/cp-037.png
[IMG_038]:../images/container-platform/admin-portal/cp-038.png
[IMG_039]:../images/container-platform/admin-portal/cp-039.png
[IMG_040]:../images/container-platform/admin-portal/cp-040.png
[IMG_041]:../images/container-platform/admin-portal/cp-041.png
[IMG_042]:../images/container-platform/admin-portal/cp-042.png
[IMG_043]:../images/container-platform/admin-portal/cp-043.png
[IMG_044]:../images/container-platform/admin-portal/cp-044.png
[IMG_045]:../images/container-platform/admin-portal/cp-045.png
[IMG_046]:../images/container-platform/admin-portal/cp-046.png
[IMG_047]:../images/container-platform/admin-portal/cp-047.png
[IMG_048]:../images/container-platform/admin-portal/cp-048.png
[IMG_049]:../images/container-platform/admin-portal/cp-049.png
[IMG_050]:../images/container-platform/admin-portal/cp-050.png
[IMG_051]:../images/container-platform/admin-portal/cp-051.png
[IMG_052]:../images/container-platform/admin-portal/cp-052.png
[IMG_053]:../images/container-platform/admin-portal/cp-053.png
[IMG_054]:../images/container-platform/admin-portal/cp-054.png
[IMG_055]:../images/container-platform/admin-portal/cp-055.png
[IMG_056]:../images/container-platform/admin-portal/cp-056.png
[IMG_057]:../images/container-platform/admin-portal/cp-057.png
[IMG_058]:../images/container-platform/admin-portal/cp-058.png
[IMG_059]:../images/container-platform/admin-portal/cp-059.png
[IMG_060]:../images/container-platform/admin-portal/cp-060.png
[IMG_061]:../images/container-platform/admin-portal/cp-061.png
[IMG_062]:../images/container-platform/admin-portal/cp-062.png
[IMG_063]:../images/container-platform/admin-portal/cp-063.png
[IMG_064]:../images/container-platform/admin-portal/cp-064.png
[IMG_065]:../images/container-platform/admin-portal/cp-065.png
[IMG_066]:../images/container-platform/admin-portal/cp-066.png
[IMG_067]:../images/container-platform/admin-portal/cp-067.png
[IMG_068]:../images/container-platform/admin-portal/cp-068.png
[IMG_069]:../images/container-platform/admin-portal/cp-069.png
[IMG_070]:../images/container-platform/admin-portal/cp-070.png
[IMG_071]:../images/container-platform/admin-portal/cp-071.png
[IMG_072]:../images/container-platform/admin-portal/cp-072.png
[IMG_073]:../images/container-platform/admin-portal/cp-073.png
[IMG_074]:../images/container-platform/admin-portal/cp-074.png
[IMG_075]:../images/container-platform/admin-portal/cp-075.png
[IMG_076]:../images/container-platform/admin-portal/cp-076.png
[IMG_077]:../images/container-platform/admin-portal/cp-077.png
[IMG_078]:../images/container-platform/admin-portal/cp-078.png
[IMG_079]:../images/container-platform/admin-portal/cp-079.png
[IMG_080]:../images/container-platform/admin-portal/cp-080.png
[IMG_081]:../images/container-platform/admin-portal/cp-081.png
[IMG_082]:../images/container-platform/admin-portal/cp-082.png
[IMG_083]:../images/container-platform/admin-portal/cp-083.png
[IMG_084]:../images/container-platform/admin-portal/cp-084.png
[IMG_085]:../images/container-platform/admin-portal/cp-085.png
[IMG_086]:../images/container-platform/admin-portal/cp-086.png
[IMG_087]:../images/container-platform/admin-portal/cp-087.png
[IMG_088]:../images/container-platform/admin-portal/cp-088.png
[IMG_089]:../images/container-platform/admin-portal/cp-089.png
[IMG_090]:../images/container-platform/admin-portal/cp-090.png
[IMG_091]:../images/container-platform/admin-portal/cp-091.png
[IMG_092]:../images/container-platform/admin-portal/cp-092.png
[IMG_093]:../images/container-platform/admin-portal/cp-093.png
[IMG_094]:../images/container-platform/admin-portal/cp-094.png
[IMG_095]:../images/container-platform/admin-portal/cp-095.png
[IMG_096]:../images/container-platform/admin-portal/cp-096.png
[IMG_097]:../images/container-platform/admin-portal/cp-097.png
[IMG_098]:../images/container-platform/admin-portal/cp-098.png
[IMG_099]:../images/container-platform/admin-portal/cp-099.png
[IMG_100]:../images/container-platform/admin-portal/cp-100.png
[IMG_101]:../images/container-platform/admin-portal/cp-101.png
[IMG_102]:../images/container-platform/admin-portal/cp-102.png
[IMG_103]:../images/container-platform/admin-portal/cp-103.png
[IMG_104]:../images/container-platform/admin-portal/cp-104.png
[IMG_105]:../images/container-platform/admin-portal/cp-105.png
[IMG_106]:../images/container-platform/admin-portal/cp-106.png
[IMG_107]:../images/container-platform/admin-portal/cp-107.png
[IMG_108]:../images/container-platform/admin-portal/cp-108.png
[IMG_109]:../images/container-platform/admin-portal/cp-109.png
[IMG_110]:../images/container-platform/admin-portal/cp-110.png
[IMG_111]:../images/container-platform/admin-portal/cp-111.png
[IMG_112]:../images/container-platform/admin-portal/cp-112.png
[IMG_113]:../images/container-platform/admin-portal/cp-113.png
[IMG_114]:../images/container-platform/admin-portal/cp-114.png
[IMG_115]:../images/container-platform/admin-portal/cp-115.png
[IMG_116]:../images/container-platform/admin-portal/cp-116.png
[IMG_117]:../images/container-platform/admin-portal/cp-117.png
[IMG_118]:../images/container-platform/admin-portal/cp-118.png
