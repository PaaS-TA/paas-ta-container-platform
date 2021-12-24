### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Architecture](../README.md) > Portal

## 목적
본 문서는 PaaS-TA Container Platform (CP)의 포탈 서비스에 대한 Architecture를 제공한다.
<br><br>

## 컨테이너 구성도
![image](https://user-images.githubusercontent.com/67575226/147046843-e7dd3c3d-c8d5-442c-bc9b-9469cba3e67c.png)



| 컨테이너명  | 역할 |
|-------|----|
| Admin-Portal | 컨테이너플랫폼 관리자 포탈 UI |
| User-Portal | 컨테이너플랫폼 사용자 포탈 UI |
| Portal-API | 컨테이너플랫폼 포탈 서비스 제어에 필요한 REST API를 제공 |
| Common-API | 서비스 관리에 필요한 메타데이터 제어를 위한 Database API를 제공 |
| Service-Broker | PaaS-TA와 컨테이너플랫폼 포탈 서비스 간의 중계 역할용 어플리케이션 |
| MariaDB | 컨테이너플랫폼 포탈 서비스 데이터 관리용 Database |


## 설명
파스-타 컨테이너플랫폼 포탈 서비스는 배포되는 쿠버네티스 클러스터의 워크로드를 관리하고, 테넌시별로 컨테이너의 배포 및 관리를 제어할 수 있는 UI를 제공한다.


### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Architecture](../README.md) > Portal
