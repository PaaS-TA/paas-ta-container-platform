# Container Platform CCE 사후조치

<br>

## Table of Contents

1. [문서 개요](#1)  
  1.1. [목적](#1.1)  
  
2. [Container Platform CCE 사후조치](#2)  
  2.1. [Admission Control Plugin 설정](#2.1)  
  2.2. [etcd 암호화 적용](#2.2)  
  2.3. [컨테이너 권한 제어](#2.3)  
  2.4. [네임스페이스 관리](#2.4)  

3. [YAML, Helm Chart를 이용한 Pod 배포 시 설정 사항](#3)  

<br>

## <div id='1'> 1. 문서 개요

### <div id='1.1'> 1.1. 목적
본 문서 (Container Platform CCE 사후조치 가이드) 는 개방형 PaaS 플랫폼 고도화 및 개발자 지원 환경 기반의 Open PaaS에 배포되는 컨테이터 플랫폼에 CCE 취약점 조치를 위한 사후조치 방법을 기술하였다.

Container Platform v1.3.2 부터는 Container Platform Cluster 배포 시 자동조치 될 예정이다.
  
|주요 소프트웨어|Version|
|---|---|
|Kubernetes Native|v1.23.7|
|Container Platform Cluster|v1.3.1|
|Container Platform Portal|v1.2.3|

<br>

## <div id='2'> 2. Container Platform CCE 사후조치

### <div id='2.1'> 2.1. Admission Control Plugin 설정
Admission Control Plugin 설정이 적절하게 설정되어 있지 않을 경우 취약점이 존재하기 때문에 다음과 같이 설정을 진행한다.

- **AdmissionConfiguration** 설정 파일을 추가한다.
```
$ sudo mkdir /etc/kubernetes/admission
$ sudo vi /etc/kubernetes/admission/admission-configuration.yaml
```

```
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
  - name: EventRateLimit
    path: eventconfig.yaml
  - name: PodSecurity
    configuration:
      apiVersion: pod-security.admission.config.k8s.io/v1beta1
      kind: PodSecurityConfiguration
      defaults:
        enforce: "restricted"
        enforce-version: "latest"
        audit: "restricted"
        audit-version: "latest"
        warn: "restricted"
        warn-version: "latest"
      exemptions:
        usernames: []
        runtimeClasses: []
        namespaces: [kube-system,nfs-storageclass]
```

- **EventRateLimit** 설정 파일을 추가한다.

```
$ sudo vi /etc/kubernetes/admission/eventconfig.yaml
```

```
apiVersion: eventratelimit.admission.k8s.io/v1alpha1
kind: Configuration
limits:
  - type: Namespace
    qps: 50
    burst: 100
    cacheSize: 2000
  - type: User
    qps: 10
    burst: 50
```

- **kube-apiserver** Manifest 파일을 수정한다.
**PodSecurityPolicy**의 경우 **Kubernetes v1.21** 이후부터 사용되지 않으며 **PodSecurity**로 대체한다.
--disable-admission-plugins=ServiceAccount 설정의 경우 nfs-pod-provisioner 배포가 불가능하여 설정에서 제외 처리하였다.

```
$ sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
```

```
...
    - --enable-admission-plugins=AlwaysPullImages,NodeRestriction,PodSecurity,EventRateLimit
    - --admission-control-config-file=/etc/kubernetes/admission/admission-configuration.yaml
...
    - mountPath: /etc/kubernetes/admission
      name: admission
      readOnly: true
...
  - hostPath:
      path: /etc/kubernetes/admission
      type: DirectoryOrCreate
    name: admission
...
```

<br>

### <div id='2.2'> 2.2. etcd 암호화 적용
etcd 암호화 적용을 하고 있지 않을 경우 취약점이 존재하기 때문에 다음과 같이 설정을 진행한다. 

- **EncryptionConfiguration** 설정 파일을 추가한다.
```
$ sudo mkdir /etc/kubernetes/etcd
$ sudo vi /etc/kubernetes/etcd/cp-etcd.yaml
```

```
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: cp-key
              secret: dYbd3wKBk/AoUqXFbw2XNkxCXycdZ1g0Fc0DAwRZn2c=
      - identity: {}
```

- **kube-apiserver** Manifest 파일을 수정한다.
```
$ sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
```

```
...
    - --encryption-provider-config=/etc/kubernetes/etcd/cp-etcd.yaml
...
    - mountPath: /etc/kubernetes/etcd
      name: etcd
      readOnly: true
...
  - hostPath:
      path: /etc/kubernetes/etcd
      type: DirectoryOrCreate
    name: etcd
...
```

<br>

### <div id='2.3'> 2.3. 컨테이너 권한 제어
컨테이너 권한 제어를 적절하게 설정하고 있지 않을 경우 취약점이 존재하기 때문에 다음과 같이 설정을 진행한다.

-  Deployment, Pod 등 YAML 파일 작성 시 PodSecurity의 enforce: "restricted" 설정으로 인하여 다음과 같은 securityContext 설정을 필수로 추가한다.
```
...
spec:
  securityContext:
    runAsUser: 1000
    fsGroup: 1000
...
  containers:
    image: 10.100.1.51:30002/cp-portal-repository/cp-portal-webadmin:latest
    imagePullPolicy: Always
    name: cp-portal-webadmin
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
      runAsNonRoot: true
      seccompProfile:
        type: RuntimeDefault
...
```

- 해당 설정 누락 시 다음과 같은 예시의 WARN 메시지가 출력되며 Pod가 배포되지 않는다.
```
W0902 00:20:55.761056 2731247 warnings.go:70] would violate PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "nfs-pod-provisioner" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "nfs-pod-provisioner" must set securityContext.capabilities.drop=["ALL"]), restricted volume types (volume "nfs-provisioner" uses restricted volume type "nfs"), runAsNonRoot != true (pod or container "nfs-pod-provisioner" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "nfs-pod-provisioner" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
```

<br>

### <div id='2.4'> 2.4. 네임스페이스 관리
네임스페이스 공유 금지가 적절하게 되어 있지 않을 경우 취약점이 존재하기 때문에 설정이 필요하나 PodSecurity의 enforce: "restricted" 설정으로 인하여 spec.hostNetwork, spec.hostPID, spec.hostIPC 가 기본적으로 제한된다.

<br>

  https://img.shields.io/badge/Caution-★★-red
## <div id='3'> 3. YAML, Helm Chart를 이용한 Pod 배포 시 설정 사항
조치 후 운영되거나 배포되는 Pod의 이미지 권한 설정(Dockerfile)과 배포Menifest설정이 없을경우 아래와 같이 배포가 되지 않으니, KISA와 협의하여 운영상 문제가 없도록 협의가 필요할것으로 보인다.

```
Error from server (Forbidden): pods "nginx" is forbidden: violates PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "nginx" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "nginx" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "nginx" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "nginx" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
```
  
위의 경우는 PodSecurity의 enforce: "restricted" 설정으로 인하여 발생하는 것으로 이를 만족하기 위해서는 securityContext 설정이 필수로 적용되어야 한다.

- kubectl create --image 옵션으로 Deployment 배포 시 다음과 같이 Pod가 생성되지 않는다.
```
$ kubectl create deployment nginx --image=nginx

Warning: would violate PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "nginx" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "nginx" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "nginx" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "nginx" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")

deployment.apps/nginx created

$ kubectl get deployment
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
nginx      0/1     0            0           25s
```

-  YAML 파일을 작성하여 배포를 진행해야 한다.
```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  securityContext:
    runAsUser: 1000
    fsGroup: 1000
  containers:
  - name: nginx
    image: nginx:1.14.2
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
      runAsNonRoot: true
      seccompProfile:
        type: RuntimeDefault
    ports:
    - containerPort: 80
```

- helm install을 이용하여 Deployment 배포 시 다음과 같이 Pod가 생성되지 않는다.
```
$ helm install helm-nginx bitnami/nginx
W0923 06:13:09.875054  911757 warnings.go:70] would violate PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "nginx" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "nginx" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "nginx" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "nginx" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
NAME: helm-nginx
LAST DEPLOYED: Fri Sep 23 06:13:09 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: nginx
CHART VERSION: 13.2.4
APP VERSION: 1.23.1
...

$ kubectl get deployment

NAME         READY   UP-TO-DATE   AVAILABLE   AGE
helm-nginx   0/1     0            0           71s
```

- helm install 시 --set 옵션을 설정한다.
|---|---|---|
|podSecurityContext.enabled|Enabled NGINX pods' Security Context|false|
|podSecurityContext.fsGroup|Set NGINX pod's Security Context fsGroup|1001|
|podSecurityContext.sysctls|sysctl settings of the NGINX pods|[]|
|containerSecurityContext.enabled|Enabled NGINX containers' Security Context|false|
|containerSecurityContext.runAsUser|Set NGINX container's Security Context runAsUser|1001|
|containerSecurityContext.runAsNonRoot|Set NGINX container's Security Context runAsNonRoot|true|

```
$ helm install helm-nginx bitnami/nginx --set podSecurityContext.enabled=true
```

- 또는 helm chart 파일을 다운로드 후 templates 또는 values.yaml 파일을 수정한다. (https://github.com/bitnami/charts/tree/master/bitnami/nginx/)
```
$ vi nginx/values.yaml
```

```
...
podSecurityContext:
  enabled: true
  fsGroup: 1001
...
containerSecurityContext:
  enabled: true
  runAsUser: 1001
  runAsNonRoot: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
  seccompProfile:
    type: "RuntimeDefault"
...
```
  
<br>
