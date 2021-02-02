## Table Contents
1. [문서 개요](#1)    
 1.1 [목적](#1.1)    
 1.2 [유의사항](#1.2)  

2. [CCE 진단항목](#2)  
  2.1 [root 계정 원격 접속 제한](#2.1)    
  2.2 [패스워드 복잡성 설정](#2.2)    
  2.3 [계정 잠금 임계값 설정](#2.3)    
  2.4 [파일 및 디렉터리 소유자 설정](#2.4)    
  2.5 [/etc/shadow 파일 소유자 및 권한 설정](#2.5)    
  2.6 [SUID, SGID, Sticky bit 설정 파일 점검](#2.6)    
  2.7 [world writable 파일 점검](#2.7)    
  2.8 [Docker daemon audit 설정](#2.8)    
  2.9 [/usr/lib/docker audit 설정](#2.9)    
  2.10 [/etc/docker audit 설정](#2.10)    
  2.11 [docker.service audit 설정](#2.11)    
  2.12 [docker.socket audit 설정](#2.12)    
  2.13 [/etc/default/docker audit 설정](#2.13)    
  2.14 [default bridge를 통한 컨테이너 간 네티워크 트래픽 제한](#2.14)       

3. [CVE 진단항목](#3)  
  3.1 [TCP timestamp responses 비활성화 설정](#3.1)      

## <div id='1'/>1. 문서 개요
### <div id='1.1'/>1.1. 목적 
본 문서는 CVE, CCE 취약점에 대한 기술적 보안 가이드를 제공한다. 각각은 항목설명, 조치대상, 진단방법, 조치방법으로 구성되어있다. 본 가이드를 활용하여 취약점 내용에 관련해 보안조치를 취할 수 있다.

### <div id='1.2'/>1.2. 유의사항
본 문서의 수록된 판단 기준은 클라우드 인증 평가 시 사용되고 있는 사항이며, 양호 혹은 취약을 가르는 실제 판단 기준은 각 클라우드 서비스 운영에 따라 다양한 환경, 정책 등 고려하여
심사원이 최종적으로 결정한다.

<br>

##  <div id='2'/>2. CCE 진단항목
### <div id='2.1'/>2.1. root 계정 원격 접속 제한

- 항목 설명 
  + 각종 공격(무작위 대입 공격, 사전 대입 공격 등)을 통해 root 원격 접속 차단이 적용되지 않은 시스템의 root 계정 정보를 비인가자가 획득할 경우 시스템 계정 정보 유출, 파일 및 디렉터리 변조 등의 행위 침해사고가 발생할 수 있다.

- 조치대상

| <center>대상 환경</center> | <center>분류</center> | <center>조치 대상</center> |
| :--- | :--- | :---: |
| Cluster | Master | O |
|| Worker | O |
| Bosh | MariaDB | X |
|| HAproxy | X |
|| Private-image-repository | X |

- 진단방법
  + /etc/ssh/sshd_config 파일에서 Root 로그인 설정 확인
```
# cat /etc/ssh/sshd_config | grep PermitRootLogin
```

- 조치방법
  + /etc/ssh/sshd_config 설정 값 변경
```
# vi /etc/ssh/sshd_config

[현황]
#PermitRootLogin prohibit-password

[조치]
PermitRootLogin no 
```
---

### <div id='2.2'/>2.2. 패스워드 복잡성 설정

- 항목 설명 
  + 패스워드 복잡성 설정이 되어 있지 않은 사용자 계정 패스워드 존재 시 비인가자가 각종 공격(무작위 대입 공격, 사전 대입 공격 등)을 통해 취약한 패스워드가 설정된 사용자 계정의 패스워드를 획득하여 획득한 사용자 계정 정보를 통해 해당 사용자 계정의 시스템에 접근할 수 있는 위험이 존재한다.

- 조치대상
 
| <center>대상 환경</center> | <center>분류</center> | <center>조치 대상</center> |
| :--- | :--- | :---: |
| Cluster | Master | O |
|| Worker | O |
| Bosh | MariaDB | X |
|| HAProxy | X |
|| Private-image-repository | X | 

- 진단방법
  + /etc/pam.d/common-password 파일 설정 내용 확인
```
# cat /etc/pam.d/common-password
```

- 조치방법
  + /etc/pam.d/common-password 파일 편집
```
# vi /etc/pam.d/common-password

[현황]
password	requisite			pam_deny.so

[조치]
password	requisite			pam_pwquality.so enforce_for_root retry=3 minlen=8 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1
```
---

### <div id='2.3'/>2.3. 계정 잠금 임계값 설정

- 항목 설명 
  + 로그인 실패 임계값이 설정되어 있지 않을 경우 반복되는 로그인 시도에 대한 차단이 이루어지지 않아 각종 공격(무작위 대입 공격, 사전 대입 공격, 추측 공격 등)에 취약하여 비인가자에게 사용자 계정 패스워드를 유출 당할 수 있다.

- 조치대상

| <center>대상 환경</center> | <center>분류</center> | <center>조치 대상</center> |
| :--- | :--- | :---: |
| Cluster | Master | O |
|| Worker | O |
| Bosh | MariaDB | X |
|| HAProxy | X |
|| Private-image-repository | X |  

- 진단방법
  + /etc/pam.d/common-auth 파일에서 임계값 설정 확인
```
# cat /etc/pam.d/common-auth
```

- 조치방법
  + /etc/pam.d/common-auth 파일 내 설정 값을 변경
```
# vi /etc/pam.d/common-auth

[현황]
auth    requisite                       pam_deny.so

[조치]
auth    required                        pam_tally2.so deny=5 no_magic_root        
```
---

### <div id='2.4'/>2.4. 파일 및 디렉터리 소유자 설정 

- 항목 설명 
  + 삭제된 소유자의 UID와 동일한 사용자가 해당 파일, 디렉터리에 접근 가능하여 사용자 정보 등 중요 정보가 노출될 위험이 있다.

- 조치대상

| <center>대상 환경</center> | <center>분류</center> | <center>조치 대상</center> |
| :--- | :--- | :---: |
| Cluster | Master | O |
|| Worker | O |
| Bosh | MariaDB | X |
|| HAProxy | X |
|| Private-image-repository | X |

- 진단방법
  + 시스템에서 소유자나 그룹이 존재하지 않는 파일 및 디렉터리를 검색
```
# find / -nouser -o -nogroup
```

- 조치방법
  + 소유자가 존재하지 않는 파일이나 디렉터리가 불필요한 경우 rm 명령으로 삭제
```
# rm <file name>
# rm -rf <directory name>

[현황]
ex) 검색시 나온 파일 또는 디렉터리
find: ‘/proc/11145/task/11145/fd/6’: No such file or directory
find: ‘/proc/11145/task/11145/fdinfo/6’: No such file or directory
find: ‘/proc/11145/fd/5’: No such file or directory
find: ‘/proc/11145/fdinfo/5’: No such file or directory

[조치]
ex) 검색시 나온 파일 또는 디렉터리 삭제
# rm -rf /proc/11145/task/11145/fd/6
# rm -rf /proc/11145/task/11145/fdinfo/6
# rm -rf /proc/11145/fd/5
# rm -rf /proc/11145/fdinfo/5
```
---

### <div id='2.5'/>2.5. /etc/shadow 파일 소유자 및 권한 설정

- 항목 설명 
  + 해당 파일에 대한 권한 관리가 이루어지지 않을 시 ID 및 패스워드 정보가 외부로 노출될 수 있다.

- 조치대상
  
| <center>대상 환경</center> | <center>분류</center> | <center>조치 대상</center> |
| :--- | :--- | :---: |
| Cluster | Master | O |
|| Worker | O |
| Bosh | MariaDB | X |
|| HAProxy | X |
|| Private-image-repository | X | 

- 진단방법
  + /etc/shadow 파일의 퍼미션과 소유자를 확인 
```
# ls -l /etc/shadow
```

- 조치방법
  + /etc/shadow 파일의 소유자 및 권한 변경 (소유자 root, 권한 400)
```
# chown root /etc/shadow
# chmod 400 /etc/shadow

[현황]
ex) 검색시 나온 파일
-rw-r----- 1 root shadow 863 Jan 28 06:18 /etc/shadow


[조치]
ex) 검색시 나온 파일의 소유자 및 권한 변경
# chown root /etc/shadow
# chmod 400 /etc/shadow
```
---

### <div id='2.6'/>2.6. SUID, SGID, Sticky bit 설정 파일 점검

- 항목 설명 
  + SUID, SGID 파일의 접근권한이 적절하지 않을 경우 SUID, SGID 설정된 파일로 특정 명령어를 실행하여 root 권한 획득 및 정상 서비스 장애를 발생시킬 수 있다.

- 조치대상

| <center>대상 환경</center> | <center>분류</center> | <center>조치 대상</center> |
| :--- | :--- | :---: |
| Cluster | Master | O |
|| Worker | O |
| Bosh | MariaDB | X |
|| HAProxy | X |
|| Private-image-repository | X |	  

- 진단방법
  + 아래 명령어를 통해 SUID와 SGID 파일을 검색하여 주요 파일의 권한을 확인 
```
# find / -user root -type f \( -perm -04000 -o -perm -02000 \) -xdev -exec ls -al {} \;
```

- 조치방법
  + SUID, SGID 설정 제거
```
#chmod -s /usr/bin/newgrp
#chmod -s /sbin/unix_chkpwd
#chmod -s /usr/bin/at
```
---

### <div id='2.7'/>2.7. world writable 파일 점검

- 항목 설명 
  + 시스템 파일과 같은 중요 파일에 world writable 설정이 될 경우, 악의적인 사용자가 해당 파일을 마음대로 파일을 덧붙이거나 지울 수 있게 되어 시스템의 무단 접근 및 시스템 장애를 유발할 수 있다.

- 조치대상

| <center>대상 환경</center> | <center>분류</center> | <center>조치 대상</center> |
| :--- | :--- | :---: |
| Cluster | Master | O |
|| Worker | O |
| Bosh | MariaDB | O |
|| HAProxy | O |
|| Private-image-repository | O |

- 진단방법
  + world writable 파일 존재 여부 확인 
```
# find / -type f -perm -2 -exec ls -l {} \;
```

- 조치방법
  + 일반 사용자 쓰기 권한 제거 방법
```
# chmod o-w <file name>

[현황]
  4039      4 drwxrwxrwt  10 root     root         4096 Jan 29 06:15 /tmp
256007      4 drwxrwxrwt   2 root     root         4096 Jan 28 04:51 /tmp/.Test-unix
256005      4 drwxrwxrwt   2 root     root         4096 Jan 28 04:51 /tmp/.XIM-unix
256003      4 drwxrwxrwt   2 root     root         4096 Jan 28 04:51 /tmp/.X11-unix
256004      4 drwxrwxrwt   2 root     root         4096 Jan 28 04:51 /tmp/.ICE-unix
256006      4 drwxrwxrwt   2 root     root         4096 Jan 28 04:51 /tmp/.font-unix
 67692      4 drwxrwxrwt   2 root     root         4096 Oct 26 17:27 /var/crash
 67674      4 drwxrwxrwt   5 root     root         4096 Jan 28 04:52 /var/tmp
256028      4 drwxrwxrwt   2 root     root         4096 Jan 28 04:51 /var/tmp/cloud-init

[조치 : kubernetes master, kubernetes worker]
#chmod o-w 
#chmod o-w /tmp
#chmod o-w /tmp/.Test-unix
#chmod o-w /tmp/.XIM-unix
#chmod o-w /tmp/.X11-unix
#chmod o-w /tmp/.ICE-unix
#chmod o-w /tmp/.font-unix
#chmod o-w /var/crash
#chmod o-w /var/tmp
#chmod o-w /var/tmp/cloud-init

[조치 : maradb, haproxy, private-image-repository]
# Iception환경 Instance VM 접근 방법
ex) {Instance VM name} : maradb (위 세가지 vm 입력)
$ bosh -e <bosh_name> -d paasta-container-platform ssh {Instance VM name}

#chmod o-w /tmp
#chmod o-w /var/tmp
```
---

### <div id='2.8'/>2.8. Docker daemon audit 설정

- 항목 설명 
  + Docker 데몬은 root 권한으로 실행 되기 때문에 그 활동과 용도를 감사하여야한다. 

- 조치대상

| <center>대상 환경</center> | <center>분류</center> | <center>조치 대상</center> |
| :--- | :--- | :---: |
| Cluster | Master | O |
|| Worker | O |
| Bosh | MariaDB | X |
|| HAProxy | X |
|| Private-image-repository | X |

- 진단방법
  + 명령어를 통해 /usr/bin/docker 감사 설정 확인 
```
# auditctl -l | grep /usr/bin/docker
```
 + 명령어를 통해 /etc/audit/audit.rules 파일의 내용 확인
```
# cat /etc/audit/audit.rules | grep /usr/bin/docker
```

- 조치방법
  + audit 설정 적용
```
다음과 같은 절차로 설정 적용
# apt install auditd -y
# vi /etc/audit/rules.d/audit.rules

## Add at the bottom
-w /usr/bin/docker -k docker

# systemctl restart auditd.service
```
---

### <div id='2.9'/>2.9. /usr/lib/docker audit 설정

- 항목 설명 
  + /var/lib/docker 디렉터리는 컨테이너에 대한 모든 정보를 보유하고 있는 디렉터리이므로 감사 설정을 하여야 한다.

- 조치대상

| <center>대상 환경</center> | <center>분류</center> | <center>조치 대상</center> |
| :--- | :--- | :---: |
| Cluster | Master | O |
|| Worker | O |
| Bosh | MariaDB | X |
|| HAProxy | X |
|| Private-image-repository | X |

- 진단방법
  + 명령어를 통해 /var/lib/docker 감사 설정 확인 
```
# auditctl -l | grep /var/lib/docker
```
 + 명령어를 통해 /etc/audit/audit.rules 파일의 내용 확인
```
# cat /etc/audit/audit.rules | grep /var/lib/docker
```

- 조치방법
  + audit 설정 적용
```
다음과 같은 절차로 설정 적용
# apt install auditd -y
# vi /etc/audit/rules.d/audit.rules

## Add at the bottom
-w /var/lib/docker -k docker

# systemctl restart auditd.service
```
---

### <div id='2.10'/>2.10. /etc/docker audit 설정

- 항목 설명 
  + /etc/docker 디렉터리는 Docker 데몬과 Docker 클라이언트 간의 TLS 통신에 사용되는 다양한 인증서와 키를 보유하고 있으므로 감사 설정을 하여야 한다.
  
- 조치대상

| <center>대상 환경</center> | <center>분류</center> | <center>조치 대상</center> |
| :--- | :--- | :---: |
| Cluster | Master | O |
|| Worker | O |
| Bosh | MariaDB | X |
|| HAProxy | X |
|| Private-image-repository | X |

- 진단방법
  + 명령어를 통해 /etc/docker 감사 설정 확인 
```
# auditctl -l | grep /etc/docker
```
 + 명령어를 통해 /etc/audit/audit.rules 파일의 내용 확인
```
# cat /etc/audit/audit.rules | grep /etc/docker
```

- 조치방법
  + audit 설정 적용
```
다음과 같은 절차로 설정 적용
# apt install auditd -y
# vi /etc/audit/rules.d/audit.rules

## Add at the bottom
-w /etc/docker -k docker

# systemctl restart auditd.service
```
---

### <div id='2.11'/>2.11. docker.service audit 설정

- 항목 설명 
  + 데몬 매개변수가 관리자에 의해 변경된 경우 docker.service 파일이 존재한다. docker.service 파일은 Docker 데몬을 위한 다양한 파라미터를 보유하고 있으므로 감사 설정을 하여야 한다.

- 조치대상

| <center>대상 환경</center> | <center>분류</center> | <center>조치 대상</center> |
| :--- | :--- | :---: |
| Cluster | Master | O |
|| Worker | O |
| Bosh | MariaDB | X |
|| HAProxy | X |
|| Private-image-repository | X |

- 진단방법
  + docker.service 파일의 경로 확인 
```
# systemctl show -p FragmentPath docker.service
```
  + 명령어를 통해 docker.service 감사 설정 확인 
```
# auditctl -l | grep /lib/systemd/system/docker.service
```
 + 명령어를 통해 /etc/audit/audit.rules 파일의 내용 확인
```
# cat /etc/audit/audit.rules | grep docker.service
```

- 조치방법
  + audit 설정 적용
```
다음과 같은 절차로 설정 적용
# apt install auditd -y
# vi /etc/audit/rules.d/audit.rules

## Add at the bottom
-w /lib/systemd/system/docker.service -k docker

# systemctl restart auditd.service
```
---

### <div id='2.12'/>2.12. docker.socket audit 설정

- 항목 설명 
  + docker.socket 파일은 Docker 데몬 소켓을 위한 다양한 파라미터를 보유하고 있으므로 감사 설정을 하여야 한다.

- 조치대상

| <center>대상 환경</center> | <center>분류</center> | <center>조치 대상</center> |
| :--- | :--- | :---: |
| Cluster | Master | O |
|| Worker | O |
| Bosh | MariaDB | X |
|| HAProxy | X |
|| Private-image-repository | X |  

- 진단방법
  + docker.socket 파일의 경로 확인 
```
# systemctl show -p FragmentPath docker.socket
```
  + 명령어를 통해 docker.socket  감사 설정 확인 
```
# auditctl -l | grep /lib/systemd/system/docker.socket
```
 + 명령어를 통해 /etc/audit/audit.rules 파일의 내용 확인
```
# cat /etc/audit/audit.rules | grep docker.socket
```

- 조치방법
  + audit 설정 적용
```
다음과 같은 절차로 설정 적용
# apt install auditd -y
# vi /etc/audit/rules.d/audit.rules

## Add at the bottom
-w /lib/systemd/system/docker.socket -k docker

# systemctl restart auditd.service
```
---

### <div id='2.13'/>2.13. /etc/default/docker audit 설정

- 항목 설명 
  + /etc/default/docker 파일은 Docekr 데몬을 위한 다양한 파라미터를 보유하고 있으므로 감사 설정을 하여야 한다.

- 조치대상

| <center>대상 환경</center> | <center>분류</center> | <center>조치 대상</center> |
| :--- | :--- | :---: |
| Cluster | Master | O |
|| Worker | O |
| Bosh | MariaDB | X |
|| HAProxy | X |
|| Private-image-repository | X |

- 진단방법
  + 명령어를 통해 /etc/default/docker 감사 설정 확인 
```
# auditctl -l | grep /etc/default/docker
```
 + 명령어를 통해 /etc/audit/audit.rules 파일의 내용 확인
```
# cat /etc/audit/audit.rules | /etc/default/docker
```

- 조치방법
  + audit 설정 적용
```
다음과 같은 절차로 설정 적용
# apt install auditd -y
# vi /etc/audit/rules.d/audit.rules

## Add at the bottom
-w /etc/default/docker -k docker

# systemctl restart auditd.service
```
---

### <div id='2.14'/>2.14. default bridge를 통한 컨테이너 간 네티워크 트래픽 제한

- 항목 설명 
  + Default Network Bridge의 동일한 호스트에서 컨테이너 간의 네트워크 통신은 제한되지 않는다. 따라서 각 컨테이너는 호스트의 네트워크를 통해 다른 컨테이너 네트워크 패킷을 모두 볼 수 있다. 이로 인해 의도하지 않거나 원하지 않는 정보가 다른 컨테이너에 공개될 수 있으므로 Default Network Bridge에서 컨테이너 간 통신을 제한하여야 한다.

- 조치대상

| <center>대상 환경</center> | <center>분류</center> | <center>조치 대상</center> |
| :--- | :--- | :---: |
| Cluster | Master | O |
|| Worker | O |
| Bosh | MariaDB | X |
|| HAProxy | X |
|| Private-image-repository | X |	  

- 진단방법
  + 아래 명령을 통해 컨테이너 간 제한 옵션이 적용되어 있는지 확인 
```
$ docker network ls --quiet | xargs docker network inspect --format "{{ .Name}}: {{Options }}"
```

- 조치방법
  + --icc=false 옵션 추가 
```
# vi /etc/systemd/system/docker.service.d/docker-options.conf
(변경)    --iptables=true 
(추가)    --icc=false

[Service]
Environment="DOCKER_OPTS= --iptables=true \
--icc=false \
--exec-opt native.cgroupdriver=systemd \
 \
--data-root=/var/lib/docker \
--log-opt max-size=50m --log-opt max-file=5 \

# 도커 daemon reload 및 재시작 
# systemctl daemon-reload
# systemctl restart docker
```
<br>

##  <div id='3'/>3. CVE 진단항목
### <div id='3.1'/>TCP timestamp responses 비활성화 설정

- 항목 설명 
  + TCP 타임스탬프 응답을 사용하면 원격 호스트 가동 시간의 근사치를 계산하고 향후 공격 시 도움을 줄 수 있다. 또한, 일부 운영 체제의 경우 해당 TCP 타임스탬프의 동작을 바탕으로 핑거프린팅될 수 있다.

- 조치대상

| <center>대상 환경</center> | <center>분류</center> | <center>조치 대상</center> |
| :--- | :--- | :---: |
| Cluster | Master | O |
|| Worker | O |
| Bosh | MariaDB | X |
|| HAProxy | X |
|| Private-image-repository | X |

- 조치방법
  + /etc/sysctl.conf 파일 설정 변경, iptables에 정책 추가
```
 $ sudo vi /etc/sysctl.conf
 ----------------------------------------
 ## Add at the bottom
 net.ipv4.tcp_timestamps=0
 ----------------------------------------
 $ sudo reboot
 
 #  iptables에 정책 추가
 $ sudo iptables -A INPUT -p icmp --icmp-type timestamp-request -j DROP
 $ sudo iptables -A OUTPUT -p icmp --icmp-type timestamp-reply -j DROP
```
---
