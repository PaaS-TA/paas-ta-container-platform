# paas-ta-container-platform

## 소개
Native Kubernetes 설치 가이드 및 Kubernetes에 Container Platform을 배포하여 사용할 수 있는 2가지 방법(PaaS-TA를 통해 서비스 형태로 배포되는 CaaS 형태의 서비스 배포, 단독 배포)에 대한 설치 및 활용 가이드를 다루고 있습니다.

## Kubernetes 설치 가이드
**서비스를 배포 하기 위한 kubernetes 설치 방법을 선택하여 설치한다.**
- [Kubespray 설치](https://github.com/PaaS-TA/paas-ta-container-platform/blob/dev/install-guide/standalone/paas-ta-container-platform-standalone-deployment-guide-v1.0.md)  
  + [설치 소스 파일](https://github.com/PaaS-TA/paas-ta-container-platform-deployment/tree/dev/standalone)
- [KubeEdge 설치](https://github.com/PaaS-TA/paas-ta-container-platform/blob/dev/install-guide/edge/paas-ta-container-platform-edge-deployment-guide-v1.0.md)  
  + [설치 소스 파일](https://github.com/PaaS-TA/paas-ta-container-platform-deployment/tree/dev/edge)

## 플랫폼 설치 가이드
**서비스팩 설치를 위해서는 BOSH 2.0과 PaaS-TA 5.1이 설치되어 있어야 한다.**
- [설치 파일 다운로드 받기](https://paas-ta.kr/download/package)
- 운영 환경 설치
  - PaaS-TA 플랫폼 수동 설치
    - [BOSH 2.0 설치가이드](https://github.com/PaaS-TA/Guide/blob/working-5.1/install-guide/bosh/PAAS-TA_BOSH2_INSTALL_GUIDE_V5.0.md)
    - [PaaS-TA 5.1 설치가이드](https://github.com/PaaS-TA/Guide/tree/working-5.1)

## Container Platform 설치 가이드
**Bosh 기반 Release의 설치 및 서비스를 등록한다.**
- [일반 단독 배포 설치](https://github.com/PaaS-TA/paas-ta-container-platform/blob/dev/install-guide/bosh/paas-ta-container-platform-bosh-deployment-guide-v1.0.md)  
  + [설치 소스 파일](https://github.com/PaaS-TA/paas-ta-container-platform-deployment/tree/dev/bosh)  
  + [Container Platform Release](https://github.com/PaaS-TA/paas-ta-container-platform-release/tree/dev)
- [서비스용 단독 배포 설치](https://github.com/PaaS-TA/paas-ta-container-platform/blob/dev/install-guide/bosh/paas-ta-container-platform-bosh-deployment-caas-guide-v1.0.md)
  + [설치 소스 파일](https://github.com/PaaS-TA/paas-ta-container-platform-deployment/tree/dev/bosh)   
  + [Container Platform Release](https://github.com/PaaS-TA/paas-ta-container-platform-release/tree/caas-dev)


## 포털 이용 가이드
**Container Platform 서비스를 사용할 포털 사용 방법에 대한 가이드이다.**
- 사용자 포털
  + [User Portal](https://github.com/PaaS-TA/paas-ta-container-platform/blob/dev/use-guide/portal/paas-ta-container-platform-user-guide-v1.0.md)  
- 운영자 포털
  + [Admin Portal](https://github.com/PaaS-TA/paas-ta-container-platform/blob/dev/use-guide/portal/paas-ta-container-platform-admin-guide-v1.0.md)

## 프로젝트 소스 파일 
**Container Platform서비스를 제공할 어플리케이션 소스이다.** 
- API 개발 소스 파일
  + [paas-ta-container-platform-api](https://github.com/PaaS-TA/paas-ta-container-platform-api/tree/dev)
- Common API 개발 소스 파일
  + [paas-ta-container-platform-common-api](https://github.com/PaaS-TA/paas-ta-container-platform-common-api/tree/dev)
- Webuser 개발 소스 파일
  + [paas-ta-container-platform-webuser](https://github.com/PaaS-TA/paas-ta-container-platform-webuser/tree/dev)
- Webadmin 개발 소스 파일
  + [paas-ta-container-platform-webadmin](https://github.com/PaaS-TA/paas-ta-container-platform-webadmin/tree/dev)
  
## License
paas-ta-container-platform은 [Apache-2.0 License](http://www.apache.org/licenses/LICENSE-2.0)를 사용합니다.
