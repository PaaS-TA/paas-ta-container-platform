## Table Contents
1. [문서 개요](#1)  
 1.1 [목적](#1.1)  
 1.2 [유의사항](#1.2)  

2. [Pod Security Disable](#2)  
  2.1 [PodSecurityConfiguration 수정](#2.1)  
  2.2 [kube-apiserver 재시작](#2.2)  

<br>

## <div id='1'/>1. 문서 개요
### <div id='1.1'/>1.1. 목적
본 문서는 Container Platform 내부 테스트 진행 시 securityContext 설정에 의해 일부 Container가 구동되지 않는 상황을 예외하여 테스트 진행하기 위해 기술되었다.

### <div id='1.2'/>1.2. 유의사항
본 설정은 KISA Kubernetes CCE 취약점 점검 기준에 의해 Default로 설정된 값이며 내부 테스트를 위해서만 설정을 변경하여야 한다.

<br>

##  <div id='2'/>2. Pod Security Disable
### <div id='2.1'/>2.1. PodSecurityConfiguration 수정

- podsecurity Manifest 파일 수정
podSecurityConfiguration의 enforce 값을 "privileged" 로 수정한다. (default값 : baseline)
audit, warn의 default값은 restricted 이며 securityContext 설정이 필요한 부분을 알려주지만 실제로는 enforce: "privileged" 설정에 의해 Container는 정상 실행된다.
```
$ sudo vi /etc/kubernetes/admission-controls/podsecurity.yaml
```

```
apiVersion: pod-security.admission.config.k8s.io/v1beta1
kind: PodSecurityConfiguration
defaults:
  enforce: "privileged" (수정)
  enforce-version: "latest"
  audit: "restricted"
  audit-version: "latest"
  warn: "restricted"
  warn-version: "latest"
...
```

<br>

### <div id='2.2'/>2.2. kube-apiserver 재시작

- kube-apiserver 재시작
해당 Manifest 파일을 열어 변경사항 없이 저장 및 종료한다. (:wq!)
```
$ sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
```

<br>
