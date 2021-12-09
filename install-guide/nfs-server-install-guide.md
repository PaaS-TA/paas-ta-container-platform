### [Index](https://github.com/PaaS-TA/Guide/tree/working-new-template) > [CP Install](https://github.com/PaaS-TA/paas-ta-container-platform/tree/master/install-guide) > 

# NFS 서버 설치 

- 패키지 업데이트를 실시한다.
```
$ sudo apt-get update
```

- NFS 서버를 위한 패키지를 설치한다.

```
$ sudo apt-get install nfs-common nfs-kernel-server portmap
```

- NFS에서 사용될 디렉토리 생성 및 권한 부여
```
$ mkdir -p /home/share/nfs
$ chmod 777 /home/share/nfs
```

- 공유 디렉토리 설정
```
$ sudo vi /etc/exports
## 형식 : [/공유디렉토리] [접근IP] [옵션]
/home/share/nfs *(rw,no_root_squash,async)
```
^옵션 : rw - 읽기쓰기
        no_root_squash - 클라이언트가 root 권한 획득 가능, 파일생성 시 클라이언트 권한으로 생성됨.
        async - 요청에 의해 변경되기 전에 요청에 응답, 성능 향상용

- nfs 서버 재시작
```
$ sudo /etc/init.d/nfs-kernel-server restart
$ sudo systemctl restart portmap
```


- 정상동작 확인
```
$ sudo exportfs -v 
/home/share/nfs 
                <world>(rw,async,wdelay,no_root_squash,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
```

### [Index](https://github.com/PaaS-TA/Guide/tree/working-new-template) > [CP Install](https://github.com/PaaS-TA/paas-ta-container-platform/tree/master/install-guide) > 