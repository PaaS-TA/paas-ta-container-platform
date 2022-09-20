^ 조치 후 운영되거나 배포되는 Pod의 이미지 권한 설정(Dockerfile)과 배포Menifest설정이 없을경우 아래와 같이 배포가 되지 않으니, KISA와 협의하여 운영상 문제가 없도록 협의가 필요할것으로 보인다.

```
Error from server (Forbidden): pods "nginx" is forbidden: violates PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "nginx" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "nginx" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "nginx" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "nginx" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
```