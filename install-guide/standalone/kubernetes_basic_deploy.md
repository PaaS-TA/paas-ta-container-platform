
## Table of Contents

1. [문서 개요](#1)  
  1.1. [목적](#1.1)  
  1.2. [Prerequisite](#1.2)
2. [Kubernetes resource 배포](#2)  
  2.1. [container 배포를 위한 YAML 스크립트 파일](#2.1)  
  2.2. [배포](#2.2)  
3. [Kubernetes Ingress 설정](#3)  
  3.1. [Kubespray Ingress Controller 배포 확인](#3.1)  
  3.2. [Ingress 배포 예시](#3.2)  


<br>

## <div id='1'> 1. 문서 개요

### <div id='1.1'> 1.1. 목적
본 문서는 Kubernetes의 기본적인 배포 및 사용을 위한 간단한 예제 사용해 보고 학습할 수 있도록 한다. 

<br>

### <div id='1.2'> 1.2. Prerequisite
본 이용 가이드는 Ubuntu 18.04 환경에서 kubespray를 통해 kubernetes cluster가 생성된 상태를 기준으로 작성하였다. 

Master서버에 접속하여 kubernetes CLI를 통해 진행 한다.


<br>

## <div id='2'> 2. Kubernetes resource 배포

### <div id='2.1'> 2.1 container 배포를 위한 YAML 스크립트 파일
샘플로 nginx를 Kubernetes에 배포할 수 있는 yaml을 준비한다. 
 
- Deployment Example Yaml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

- Service Example Yaml

```
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

### <div id='2.2'> 2.2 배포

>준비한 yaml을 배포한다.
```
ubuntu@ip-10-0-0-163:~$ vi deployment.yaml
ubuntu@ip-10-0-0-163:~$ kubectl apply -f deployment.yaml
deployment.apps/your-nginx-deployment created
service/your-nginx-svc created
```

> 배포된 deployment와 pod, service를 확인한다. 
```
ubuntu@ip-10-0-0-121:~$ kubectl get deploy,pod,svc -o wide 
NAME                               READY   UP-TO-DATE   AVAILABLE   AGE    CONTAINERS   IMAGES   SELECTOR
deployment.apps/nginx-deployment   1/1     1            1           100m   nginx        nginx    app=nginx

NAME                                   READY   STATUS    RESTARTS   AGE    IP             NODE            NOMINATED NODE   READINESS GATES
pod/nginx-deployment-d46f5678b-w5jjp   1/1     Running   0          100m   10.233.113.3   ip-10-0-0-238   <none>           <none>

NAME                    TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE    SELECTOR
service/kubernetes      ClusterIP   10.233.0.1     <none>        443/TCP   143m   <none>
service/nginx-service   ClusterIP   10.233.3.131   <none>        80/TCP    13m    app=nginx
```

nginx서버가 pod로 배포되며, 서비스로 노출된 nginx-service가 확인된다.



<br>


## <div id='3'> 3. Kubernetes Ingress 설정

<br>

### <div id='3.1'> 3.1. Kubespray Ingress Controller 배포 확인


- Kubernetes Cluster의 각 Node에 Daemonset으로 Ingress Controller 배포 확인
kuberspray로 배포된 Cluster에는 Ingress가 기본 배포되어 있다.

```
$ kubectl get daemonset -n ingress-nginx
NAME                       DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
ingress-nginx-controller   3         3         3       3            3           kubernetes.io/os=linux   28m

$ kubectl get pod -n ingress-nginx
NAME                             READY   STATUS    RESTARTS   AGE
ingress-nginx-controller-255cq   1/1     Running   0          28m
ingress-nginx-controller-755nq   1/1     Running   0          28m
ingress-nginx-controller-7dwv6   1/1     Running   0          28m
```

<br>

### <div id='3.2'> 3.2. Ingress 배포 예시

- 기본적인 앱 및 서비스 배포 후 Ingress Rule 설정이 필요

- Ingress Example Yaml

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: "suslmk01.shop"                     ## 외부에서 접근할 domain
    http:
      paths:
        - pathType: Prefix
          path: /
          backend:
            serviceName: nginx-service
            servicePort: 80
```

브라우저로 suslmk01.shop/로 접속 시 미리 Service로 선언된 nginx-service의 80포트로 전달

- Ingress 배포 확인

```
$ kubectl get ingress
NAME            CLASS    HOSTS           ADDRESS                            PORTS   AGE
nginx-ingress   <none>   suslmk01.shop   10.10.1.13,10.10.1.15,10.10.1.19   80      2m28s
```


<br>

- 브라우드저에서 확인

![image](https://user-images.githubusercontent.com/67575226/111438131-3ebe0380-8747-11eb-8c88-560258df9214.png)
