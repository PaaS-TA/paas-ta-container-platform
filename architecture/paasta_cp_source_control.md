### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Architecture](../README.md) > SourceControl

## 목적
본 문서는 PaaS-TA Container Platform SourceControl의 Architecture를 제공한다.
<br><br>

## 컨테이너 구성도
![image](https://user-images.githubusercontent.com/80228983/146350860-3722c081-7338-438d-b7ec-1fdac09160c4.png)



| 컨테이너명  | 역할 |
|-------|-----|
| SC-API | 소스 컨트롤 서비스 제어에 필요한 REST API 제공 |
| SC-UI | 소스 컨트롤 서비스 Web UI |
| SC-Broker | PaaS-TA와 소스컨트롤 서비스 간의 중계 역할용 어플리케이션 |
| SCM-Server | SCM Server |



## 설명
파스-타 컨테이너플랫폼 소스 컨트롤 서비스는 Git과 Svn Repository를 관리할 수 있는 UI를 제공한다.   


### [Index](https://github.com/PaaS-TA/Guide/blob/master/README.md) > [CP Architecture](../README.md) > SourceControl
