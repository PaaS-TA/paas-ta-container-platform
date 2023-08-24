# NKS-Openstack(센터 내부망) Multi-Cluster 구성 가이드

## Table of Contents
1. [Prerequisite](#1)  
    1.1[컨텍스트 설정](#1.1)  
    1.2[Helm 설치](#1.2)  
    1.3[Step CLI 설치](#1.3)  
    1.4[Linkerd CLI 설치](#1.4)  
2. [인증서 생성](#2)      
3. [Linkerd 설치](#3)  
    3.1[Linkerd-crds 설치](#3.1)  
    3.2[Linkerd-control-plane 설치](#3.2)    
    3.3[Linkerd-viz 설치](#3.3)  
    3.4[Linkerd-viz Dashboard 접속](#3.4)         
4. [Linkerd multi-cluster 구성](#4)  
    4.1[Linkerd-multicluster 설치](#4.1)  
    4.2[Linkerd-smi 설치](#4.2)    
5. [Sample App 배포](#5)     

<br>  

## 1. Prerequisite
#### Lastest Version
- [Linkerd Extension List](https://linkerd.io/2.13/reference/extension-list/#)

|NAME|NAMESPACE|CHART VERSION|APP VERSION|Extensions|
|:---|:---|:---|:---|---|
|<b>linkerd-crds</b>|linkerd|linkerd-crds-1.6.1|-|-|
|<b>linkerd-control-plane</b>|linkerd|linkerd-control-plane-1.12.5| stable-2.13.5|-|
|<b>linkerd-viz</b>|linkerd-viz|linkerd-viz-30.8.5|stable-2.13.5|O|
|<b>linkerd-multicluster</b>|linkerd-multicluster|linkerd-multicluster-30.7.5|stable-2.13.5|O|
|<b>linkerd-smi</b>|linkerd-smi|linkerd-smi-1.0.1 |v0.2.1|O|

#### Cluster 환경
해당 가이드는 아래 클러스터 2개의 Linkerd 멀티클러스터 서비스 메시를 구성한다. <br>
- <b>Openstack (센터 내부망)</b>
  + Cluster Name : cluster1
  + Context : ctx-1
- <b>NKS</b>
  + Cluster Name : cluster2
  + Context : ctx-2

<b>클러스터 간 통신 상태</b>

|FROM|방향|TO|통신|
|:---|:---:|:---|:---:|
|<b>cluster1(센터 내부망 Openstack)</b> |→|<b>cluster2(NKS)</b>|정상|
|<b>cluster2(NKS)</b>|→|<b>cluster1(센터 내부망 Openstack)</b>|불가|
<br>

:bookmark: 
<b> 결과 </b>

- 클러스터 쌍방향 (cluster1 <-> cluster2) linkerd-multicluster 구성 불가
- cluster1 → cluster2 연결만 진행

:doughnut:
<b> 기존 Linkerd 설치 가이드와 차이점 </b>
- cluster1(openstack)에 MetalLB 미설치
- cluster1(openstack) 자격증명 추출 후 cluster2(nks)에 리소스 생성하는 과정 하지 않음
- cluster2(nks)에 Linkerd-smi 미설치
- cluster1(openstack)에 cluster2(nks) 서비스가 미러링 되어야함 
- linkerd-viz 설치하지않아도 linkerd-multicluster 통신 정상 동작

---

<br>

### 1.1 컨텍스트 설정 
- 클러스터 <b>cluster1</b>에 cluster1, cluster2 컨텍스트 설정 확인
```yaml
# cluster api server 주소는 외부에서 접근가능해야한다. https://127.0.0.1:6443 안됨
$ kubectl config view --context=ctx-1

apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://10.100.0.10:6443
  name: cluster1
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://63c4f2d9-2ac3-xxxx.xxxx.com
  name: cluster2
contexts:
- context:
    cluster: cluster1
    user: kubernetes-admin
  name: ctx-1
- context:
    cluster: cluster2
    user: nks_kr_nks01_xxxx
  name: ctx-2
current-context: ctx-1
...
```
- 컨텍스트 목록 확인
```bash
$ kubectl config get-contexts
CURRENT   NAME    CLUSTER    AUTHINFO               NAMESPACE
*         ctx-1   cluster1   kubernetes-admin
          ctx-2   cluster2   nks_kr_nks01_xxxx
```
### 1.2 Helm 설치 
- 클러스터 <b>cluster1</b>에 helm 설치 확인 
  + 컨테이너 플랫폼 배포에 helm 설치 기본 제공
```bash
$ helm version
version.BuildInfo{Version:"v3.9.4", GitCommit:"dbc6d8e20fe1d58d50e6ed30f09a04a77e4c68db", GitTreeState:"clean", GoVersion:"go1.17.13"}
```

### 1.3 Step CLI 설치
- 클러스터 <b>cluster1</b>에 step 설치 확인 
  + 인증서와 키 생성을 위한 툴
```bash
## step 다운로드 및 /usr/bin 배치
$ wget https://github.com/smallstep/cli/releases/download/v0.24.4/step_linux_0.24.4_amd64.tar.gz -O step.tar.gz
$ tar -xvzf step.tar.gz
$ sudo mv step_0.24.4/bin/step /usr/bin/
$ sudo chmod +x /usr/bin/step
$ step version
Smallstep CLI/0.24.4 (linux/amd64)
Release Date: 2023-05-11T19:52:34Z
```

### 1.4 Linkerd CLI 설치 
- 클러스터 <b>cluster1</b>에 linkerd cli설치 확인
  + Linkerd와 상호 작용
```bash
# linkerd cli 수동설치
$ curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh

# 설치 중 
Download complete!

Validating checksum...
Checksum valid.

Linkerd stable-2.13.5 was successfully installed 🎉

# 설치 완료
$ sudo mv $HOME/.linkerd2/bin/linkerd /usr/bin/
$ sudo chmod +x /usr/bin/linkerd
$ linkerd version
Client version: stable-2.13.5
# 아직 linkerd 컨트롤 플레인을 설치 않았기에 unavailable 상태
Server version: unavailable
``` 

<br>

## 2. 인증서 생성
Pod 간 mTLS 통신을 지원하기 위해 Linkerd는 trust anchor 인증서와 해당키의 issue 인증서가 필요하다.<br>
Helm을 통한 Linkerd 설치의 경우 사용자가 수동으로 생성해야 한다.
```bash
# 디렉토리 생성 
$ mkdir -p $HOME/linkerd/certs
$ cd $HOME/linkerd/certs

# 루트 인증서 및 키 생성
$ step certificate create root.linkerd.cluster.local ca.crt ca.key \
--profile root-ca --no-password --insecure

# 중간 인증서 및 키 생성
$ step certificate create identity.linkerd.cluster.local issuer.crt issuer.key \
--profile intermediate-ca --not-after 8760h --no-password --insecure \
--ca ca.crt --ca-key ca.key

# 인증서 생성 확인
$ ls
ca.crt  ca.key  issuer.crt  issuer.key
```

<br>

## 3. Linkerd 설치

### 3.1 Linkerd-crds 설치
Helm을 통해 Linkerd CRDS를 설치한다.

```bash
# linkerd 레파지토리 등록
$ helm repo add linkerd https://helm.linkerd.io/stable

$ helm repo list
NAME    URL
linkerd https://helm.linkerd.io/stable


# cluster1(ctx-1)에 linkerd-crds 설치
$ helm install linkerd-crds linkerd/linkerd-crds -n linkerd --create-namespace --kube-context=ctx-1

# cluster2(ctx-2)에 linkerd-crds 설치
$ helm install linkerd-crds linkerd/linkerd-crds -n linkerd --create-namespace --kube-context=ctx-2
```

### 3.2  Linkerd-control-plane 설치
- 위에서 생성한 인증서과 함께 linkerd-control-plane을 설치한다.

```bash
# cluster1(ctx-1)에 linkerd-control-plane 설치
$ helm install linkerd-control-plane -n linkerd \
  --set-file identityTrustAnchorsPEM=ca.crt \
  --set-file identity.issuer.tls.crtPEM=issuer.crt \
  --set-file identity.issuer.tls.keyPEM=issuer.key \
  linkerd/linkerd-control-plane --kube-context=ctx-1

# cluster2(ctx-2)에 linkerd-control-plane 설치
$ helm install linkerd-control-plane -n linkerd \
  --set-file identityTrustAnchorsPEM=ca.crt \
  --set-file identity.issuer.tls.crtPEM=issuer.crt \
  --set-file identity.issuer.tls.keyPEM=issuer.key \
  linkerd/linkerd-control-plane --kube-context=ctx-2
```

### 3.3 Linkerd-viz 설치
- linkerd-viz(Dashboard)를 설치한다.
```bash
# cluster1(ctx-1)에 linkerd-viz 설치
$ helm install linkerd-viz -n linkerd-viz --create-namespace linkerd/linkerd-viz --kube-context=ctx-1

# cluster2(ctx-2)에 linkerd-viz 설지 
$ helm install linkerd-viz -n linkerd-viz --create-namespace linkerd/linkerd-viz --kube-context=ctx-2
```

### 3.4 Linkerd-viz Dashboard 접속
- linkerd viz dashboard 접속을 위해 Ingress를 생성한다. (ingress-nginx 사용)

```bash
# 디렉토리 생성 
$ mkdir -p $HOME/linkerd/yaml
$ cd $HOME/linkerd/yaml
```
- linkerd-viz-ingress.yaml
```yaml
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: web-ingress-auth
  namespace: linkerd-viz
data:
  auth: YWRtaW46JGFwcjEkbjdDdTZnSGwkRTQ3b2dmN0NPOE5SWWpFakJPa1dNLgoK
---
# apiVersion: networking.k8s.io/v1beta1 # for k8s < v1.19
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: linkerd-viz
  annotations:
    nginx.ingress.kubernetes.io/upstream-vhost: $service_name.$namespace.svc.cluster.local:8084
    nginx.ingress.kubernetes.io/configuration-snippet: |
      proxy_set_header Origin "";
      proxy_hide_header l5d-remote-ip;
      proxy_hide_header l5d-server-id;
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: web-ingress-auth
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required'
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 8084
```
- linkerd viz ingress 생성
```bash
# cluster1(ctx-1)에 ingress 생성
# 컨테이너 플랫폼 설치 시 ingress-nginx 배포 기본 제공한다.
kubectl apply -f linkerd-viz-ingress.yaml --context=ctx-1

# cluster2(ctx-2)에 ingress 생성
# NKS에 ingress-nginx가 설치되었는지 확인, 미설치라면 ingress 기능 NO, dashboard 접속 필요없으면 ingress 배포 NO
kubectl apply -f linkerd-viz-ingress.yaml --context=ctx-2
```

#### linkerd viz dashboard 접속
- ingress-nginx-controller port 80의 nodeport 접속
  + ex) http://{node-ip}:32699
```
$ kubectl get svc -n ingress-nginx
NAME                                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             NodePort    10.233.37.246   <none>        80:32699/TCP,443:30590/TCP   19d
ingress-nginx-controller-admission   ClusterIP   10.233.28.54    <none>        443/TCP                      19d
```
- 기본 로그인 정보  
  + `id: admin , password: admin` 


---

<br>

## 4. Linkerd multi-cluster 구성
### 4.1. Linkerd-multicluster 설치
- helm을 통해 linkerd-multicluster를 설치한다.
- <b>cluster2</b>(NKS) 에서 <b>cluster1</b>(센터 내부망 Openstack)의 Linkerd Multicluster Gateway EXTERNAL-IP가 통신불가하므로<br>
<b>cluster1</b>(센터 내부망 Openstack)에서 <b>cluster2</b>(NKS)의 자격증명 secret 및 미러 컨트롤러 생성만 진행한다.

|FROM|방향|TO|통신|
|:---|:---:|:---|:---:|
|<b>cluster1(센터 내부망 Openstack)</b> |→|<b>cluster2(NKS)</b>|정상|
|<b>cluster2(NKS)</b>|→|<b>cluster1(센터 내부망 Openstack)</b>|불가|

<br>

- linkerd-multicluster 설치는 <b>cluster1</b>, <b>cluster2</b> 모두 진행 
```bash
# cluster1(ctx-1)에 linkerd-multicluster 설치
$ helm install linkerd-multicluster -n linkerd-multicluster --create-namespace linkerd/linkerd-multicluster --kube-context=ctx-1

# MetalLB 미설치로 linkerd-gateway EXTERNAL-IP pending 상태일 것
$ kubectl get svc -n linkerd-multicluster  --context=ctx-1
NAME              TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                         AGE
linkerd-gateway   LoadBalancer   10.233.5.183   <pending>     4143:30300/TCP,4191:31353/TCP   10m
```
```bash
# cluster2(ctx-2)에 linkerd-multicluster 설치
$ helm install linkerd-multicluster -n linkerd-multicluster --create-namespace linkerd/linkerd-multicluster --kube-context=ctx-2

# NKS EXTERNAL-IP 도메인 자동할당 확인
$ kubectl get svc -n linkerd-multicluster --context=ctx-2
NAME              TYPE           CLUSTER-IP       EXTERNAL-IP                                 PORT(S)                         AGE
linkerd-gateway   LoadBalancer   198.xx.xxx.xx   linkerd-mul-linkerd-gate-xxxx.naverncp.com   4143:31021/TCP,4191:31099/TCP   12m
```

- <b>cluster1</b>에 cluster2 자격증명 secret 및 미러 컨트롤러 생성
```bash
# cluster2(ctx-2) 자격증명 추출 후 cluster1(ctx-1)에 생성
$ linkerd multicluster link --context=ctx-2  --cluster-name cluster2  |  kubectl --context=ctx-1 apply -f -
```

```bash
# 생성되는 리소스 목록
secret/cluster-credentials-cluster2 created (linkerd-multicluster)
secret/cluster-credentials-cluster2 created (linkerd)
link.multicluster.linkerd.io/cluster2 created
clusterrole.rbac.authorization.k8s.io/linkerd-service-mirror-access-local-resources-cluster2 unchanged
clusterrolebinding.rbac.authorization.k8s.io/linkerd-service-mirror-access-local-resources-cluster2 unchanged
role.rbac.authorization.k8s.io/linkerd-service-mirror-read-remote-creds-cluster2 created
rolebinding.rbac.authorization.k8s.io/linkerd-service-mirror-read-remote-creds-cluster2 created
serviceaccount/linkerd-service-mirror-cluster2 created
deployment.apps/linkerd-service-mirror-cluster2 created
service/probe-gateway-cluster2 created
```

<b>multicluster 연결 상태 확인</b>
```bash
# ctx-1 에서 ctx-1 → ctx2 연결상태 확인
$ linkerd multicluster check --context=ctx-1
linkerd-multicluster
--------------------
√ Link CRD exists
√ Link resources are valid
        * cluster2
√ remote cluster access credentials are valid
        * cluster2
√ clusters share trust anchors
        * cluster2
√ service mirror controller has required permissions
        * cluster2
√ service mirror controllers are running
        * cluster2
√ probe services able to communicate with all gateway mirrors
        * cluster2
√ all mirror services have endpoints
√ all mirror services are part of a Link
√ multicluster extension proxies are healthy
√ multicluster extension proxies are up-to-date
√ multicluster extension proxies and cli versions match

Status check results are √
```
<br>

### 4.2. Linkerd-smi 설치
트래픽 분할을 위한 CRD `TrafficSplit`를 사용하기 위해선 Linkerd-smi extenstions 설치가 필요하다. <br>
자세한 설명은 이곳으로 [[Getting started with Linkerd SMI extension]](https://linkerd.io/2.13/tasks/linkerd-smi/)

```bash
# linkerd-smi extension 레파지토리 등록
$ helm repo add l5d-smi https://linkerd.github.io/linkerd-smi

$ helm repo list
NAME    URL
linkerd https://helm.linkerd.io/stable
l5d-smi https://linkerd.github.io/linkerd-smi

# cluster1(ctx-1)에 linkerd-smi 설치
helm install linkerd-smi l5d-smi/linkerd-smi -n linkerd-smi --create-namespace --kube-context=ctx-1
```

<br>

## 5. Sample App 배포 
<b>cluster1, cluster2</b>에 멀티 클러스터 통신 샘플 앱을 배포해본다.

#### cluster2에 HelloWorld(v2) APP 배포
- `mirror.linkerd.io/exported: "true"`
  + 미러링을 통한 서비스 내보내기  
- `linkerd.io/inject: enabled`
  + pod에 linkerd-proxy 주입
```yaml
# cluster2(ctx-2)에 helloworld(v2) deployment-svc 생성
apiVersion: v1
kind: Service
metadata:
  name: helloworld
  labels:
    app: helloworld
    service: helloworld
    mirror.linkerd.io/exported: "true"
spec:
  ports:
    - port: 5000
      name: http
  selector:
    app: helloworld
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld-v2
  labels:
    app: helloworld
    version: v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: helloworld
      version: v2
  template:
    metadata:
      labels:
        app: helloworld
        version: v2
      annotations:
        linkerd.io/inject: enabled
    spec:
      containers:
        - name: helloworld
          image: docker.io/istio/examples-helloworld-v2
          resources:
            requests:
              cpu: "100m"
          imagePullPolicy: IfNotPresent #Always
          ports:
            - containerPort: 5000
```

- <b>cluster2</b> 내 HelloWorld(v2) 배포 확인
```bash
$ kubectl get all -l app=helloworld --context=ctx-2
NAME                                 READY   STATUS    RESTARTS   AGE
pod/helloworld-v2-55fb448cdd-x5897   2/2     Running   0          30s

NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/helloworld   ClusterIP   198.19.194.135   <none>        5000/TCP   30s

NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/helloworld-v2   1/1     1            1           30s

NAME                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/helloworld-v2-55fb448cdd   1         1         1       30s

```
- <b>cluster1</b> 내 서비스 미러링을 통한 `helloworld-cluster2` 생성 확인
```bash 
$ kubectl get all -l app=helloworld --context=ctx-1
NAME                          TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
service/helloworld-cluster2   ClusterIP   10.233.55.2   <none>        5000/TCP   64s
```

#### cluster1에 HelloWorld(v1) 배포
- `linkerd.io/inject: enabled`
  + pod에 linkerd-proxy 주입
```yaml
# cluster1(ctx-1)에 helloworld(v1) deployment-svc 생성
apiVersion: v1
kind: Service
metadata:
  name: helloworld
  labels:
    app: helloworld
    service: helloworld
spec:
  ports:
    - port: 5000
      name: http
  selector:
    app: helloworld
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld-v1
  labels:
    app: helloworld
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: helloworld
      version: v1
  template:
    metadata:
      labels:
        app: helloworld
        version: v1
      annotations:
        linkerd.io/inject: enabled
    spec:
      containers:
        - name: helloworld
          image: docker.io/istio/examples-helloworld-v1
          resources:
            requests:
              cpu: "100m"
          imagePullPolicy: IfNotPresent #Always
          ports:
            - containerPort: 5000
```
#### cluster1에 TrafficSplit 배포
- 서비스 <b>helloworld(cluster1)</b> weight 50, 서비스 <b>helloworld-cluster2(cluster2)</b> weight 50으로 트래픽 분할
```yaml
apiVersion: split.smi-spec.io/v1alpha1
kind: TrafficSplit
metadata:
  name: helloworld
spec:
  service: helloworld
  backends:
  - service: helloworld
    weight: 50
  - service: helloworld-cluster2
    weight: 50
```

#### cluster1에 Sleep APP (Client 용도) 배포
- `linkerd.io/inject: enabled`
  + pod에 linkerd-proxy 주입
```yaml
apiVersion: v1
kind: Service
metadata:
  name: sleep
  labels:
    app: sleep
spec:
  ports:
  - port: 80
    name: http
  selector:
    app: sleep
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sleep
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sleep
  template:
    metadata:
      labels:
        app: sleep
      annotations:
        linkerd.io/inject: enabled
    spec:
      containers:
      - name: sleep
        image: curlimages/curl
        command: ["/bin/sleep", "3650d"]
        imagePullPolicy: IfNotPresent
```
- <b>cluster1</b> 내 HelloWorld(v1), TrafficSplit, Sleep 배포 확인
```bash
$ kubectl get all -l app=helloworld --context=ctx-1
NAME                                READY   STATUS    RESTARTS   AGE
pod/helloworld-v1-d947f79f8-kfncp   2/2     Running   0          55s

NAME                          TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
service/helloworld            ClusterIP   10.233.7.67   <none>        5000/TCP   55s
service/helloworld-cluster2   ClusterIP   10.233.55.2   <none>        5000/TCP   3m4s

NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/helloworld-v1   1/1     1            1           55s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/helloworld-v1-d947f79f8   1         1         1       55s
```
```bash
$ kubectl get trafficsplits.split.smi-spec.io --context=ctx-1
NAME         SERVICE
helloworld   helloworld
```
```bash
$ kubectl get all -l app=sleep --context=ctx-1
NAME                        READY   STATUS    RESTARTS   AGE
pod/sleep-545b77f74-pzthq   2/2     Running   0          62s

NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/sleep   ClusterIP   10.233.9.253   <none>        80/TCP    62s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/sleep-545b77f74   1         1         1       62s

```

#### Sleep -> Helloworld 통신 테스트 
- `TrafficSplit`을 통해 cluster1의 helloworld-v1, cluster2의 helloworld-v2로 트래픽 분할되어 통신되는 것을 확인할 수 있다.
```bash
$ kubectl exec --context=ctx-1 "$(kubectl get pod --context=ctx-1 -l app=sleep -o jsonpath='{.items[0].metadata.name}')" \
-c sleep -- curl -sS helloworld:5000/hello
Hello version: v1, instance: helloworld-v1-d947f79f8-kfncp

...pod 접속해서 curl 통신
$ kubectl exec -it sleep-545b77f74-pzthq /bin/sh -c sleep
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
~ $ curl helloworld:5000/hello
Hello version: v2, instance: helloworld-v2-55fb448cdd-x5897
~ $ curl helloworld:5000/hello
Hello version: v1, instance: helloworld-v1-d947f79f8-kfncp
~ $ curl helloworld:5000/hello
Hello version: v2, instance: helloworld-v2-55fb448cdd-x5897
~ $ curl helloworld:5000/hello
Hello version: v2, instance: helloworld-v2-55fb448cdd-x5897
~ $ curl helloworld:5000/hello
Hello version: v1, instance: helloworld-v1-d947f79f8-kfncp
~ $ curl helloworld:5000/hello
Hello version: v1, instance: helloworld-v1-d947f79f8-kfncp
```

<b>Linkerd viz stat service 상태</b> 
```bash
$ linkerd viz stat services
NAME                  MESHED   SUCCESS      RPS   LATENCY_P50   LATENCY_P95   LATENCY_P99   TCP_CONN
helloworld                 -   100.00%   0.1rps           0ms           0ms           0ms          0
helloworld-cluster2        -   100.00%   0.1rps           0ms           0ms           0ms          0
```

