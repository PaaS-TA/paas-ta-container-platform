## Table of Contents

1. [문서 개요](#1)  
  1.1. [목적](#1.1)  
  1.2. [참고자료](#1.2)  

1. [Minikube 설치](#2)  
  2.1. [Prerequisite](#2.1)  
  2.2. [Docker 설치](#2.2)<br>
  2.3. [Minikube 설치](#2.3)  

<br>

## <div id='1'> 1. 문서 개요

### <div id='1.1'> 1.1. 목적
본 문서는 Windows 환경의 Local환경에서 Cluster 오토스케일링을 체험할 수 있도록 Minikube를 설치하는 방법을 설명한다.

<br>

### <div id='1.2'> 1.2. 참고자료
- Docker Desktop
> https://www.docker.com/get-started/ 
- Chocolatey
> https://chocolatey.org/install
<br>

## <div id='2'> 2. Minikube 설치

### <div id='2.1'> 2.1. Prerequisite
Windows환경에서의 Hardware 요구사항을 참고한다.
> 1. 두번째 주소수준 변환(SLAT)을 사용하는 64bit 프로세서.
> 2. VM 모니터 모드 확장(Intel CPU의 VT-x)을 지원하는 CPU.
> 3. 최소 4GB의 메모리. 가상컴퓨터는 Hyper-V 호스트와 메모리를 공유하지만 예상된 가상 워크로드를 처리하려면 충분한 메모리를 제공해야 한다. 다음 항목을 시스템 BIOS에서 사용하도록 설정해야 함. 
> 4. 가상화 기술 - 메인보드 제조업체에 따른 레이블 <br>
  . 인텔 : Intel Virtualization Technology, VT-d <br>
  . AMD : SVM Mode <br>
> 5. 하드웨어 적용 데이터 실행 방지 <br>
> ※ 윈도우 Home에서는 Hyper-V 기능을 활성화 할 수 없음.

### <div id='2.2'> 2.2. Hyper-V 활성화(Windows 11 Home)
윈도우 Home 버전일 경우 Hyper-V 활성화를 할 수 없다.  
Hyper-v항목이 없음  
![image (2)](https://user-images.githubusercontent.com/67575226/211250493-e9d17124-1ed7-4915-a2e3-f97868a57bc7.png){: width="200" height="200"}

1. 메모장을 실행 후 아래 명령어를 붙여넣는다.
```
pushd "%~dp0"
dir /b %SystemRoot%\servicing\Packages\*Hyper-V*.mum >hyper-v.txt
for /f %%i in ('findstr /i . hyper-v.txt 2^>nul') do dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%i"
del hyper-v.txt
Dism /online /enable-feature /featurename:Microsoft-Hyper-V -All /LimitAccess /ALL
pause
```
  
1. 해당파일을 `windows11-home-hyper-v.bat`이름으로 저장한다. (파일이름은 아무거나 상관없음)
![image](https://user-images.githubusercontent.com/67575226/211251606-3a824764-30a0-4646-950b-edfe0c278c91.png)
  
1. 해당 파일에서 마우스 우클릭하여 관리자권한으로 실행 후 시스템을 재부팅 한다.
![image](https://user-images.githubusercontent.com/67575226/211251733-015a7e60-6d79-4a3e-a2de-85d599925d2e.png)
  
1. 재부팅 후 Windows 기능항목에 Hyper-V가 활성화 된 것을 볼 수 있다.
 ![image](https://user-images.githubusercontent.com/67575226/211252018-77e01135-4219-4a29-88b9-36d7ef340739.png)

### <div id='2.2'> 2.2. Docker 설치
도커를 설치하기 위한 최소사양
> 21H2이상 버전의 Windows 11 64bit Home, Pro, Enterprise, Education
> 2004(19041 빌드) 이상의 Windows 10 Home, Pro 혹은 1909(18363 빌드) 이상의 Windows 10 Enterprise, Education
> WSL2 혹은 Hyper-V 기능 활성화
> 4GB이상의 메모리

#### 2.2.1. 설치
1. Windows용 도커 데스크톱 설치 파일을 내려받기 위해 아래 경로에 접속한다.
> https://www.docker.com/get-started/
![image](https://user-images.githubusercontent.com/67575226/211242509-86996140-6e5b-49e0-8ba8-188b0fc21604.png)
2. 도커 공식 홈페이지의 Get Started에서 <Docker Desctop for Windows> 를 클릭해 설치 파일을 내려 받는다. 
3. 내려받은 Docker Desktop Installer 파일을 실행해 도커 설치를 시작합니다.
4. Configuration 단계에서 <OK>를 클릭해 도커 설치를 진행. "Install required Windows components for WSL 2"를 체크해 WSL 2 구성 요소 설치를 진행한다. 
5. 설치를 완료했다면 명령 프롬프트에서 docker -v를 입력해 설치를 확인 한다. 
![image](https://user-images.githubusercontent.com/67575226/211242726-e6a983c0-2b68-4677-b2ae-a1439003c7e4.png)

#### 2.2.2. Docker 할당 리소스 지정
  
1. 유저 디렉토리에서 .wslconfig파일을 생성해 Resource 할당 가능. 윈도우 탐색기에서 주소창에 `%UserProfile%`을 입력하여 유저 디렉토리 진입
![image](https://user-images.githubusercontent.com/67575226/211242806-d88d1cd8-8e84-4da1-9b77-9d8551a123d1.png)
  
2. .wslconfig 파일 생성
![image](https://user-images.githubusercontent.com/67575226/211242851-bd7e476b-cced-4652-9ce0-d1ae50b6f85e.png)
  
3. .wslconfig 파일 수정  
  자신의 환경에 맞게 조절한다. 
![image](https://user-images.githubusercontent.com/67575226/211242885-4463d74b-4613-497d-96c6-b55a8aea80a6.png)
  
1. 설정완료 후, 명령 프롬프트 창을 열어 `wsl --shutdown`명령어를 입력해 WSL 2를 종료한다. 
![image](https://user-images.githubusercontent.com/67575226/211242920-6b120a2c-98ef-4bcc-bf36-c8f83c2b0b09.png)
  
1. 이후 다시 wsl을 실행하면 해당 리소스 값이 적용된 도커를 사용할 수 있다.  
![image](https://user-images.githubusercontent.com/67575226/211242961-356badcc-5d8b-4e5e-8816-dd50cbe463e9.png)
<br>
### <div id='2.3'> 2.3. Minikube 설치
Minikube를 설치하는 방법은 여러가지가 있으나, 윈도우즈용 패키지 매니저인 `Chocolatey`를 이용하여 간편하게 설치 할 수 있다.
아래는 `Chocolatey`를 이용해 설치하는 방법은 설명한다.
#### 2.3.1. Chocolatey 설치
> https://chocolatey.org/install   

위 URL로 이동 후 Individual 항목으로 설치하는 내용확인.   
관리자모드로 실행한 PowerShell에서 아래 그림에서 설명한 내용을 복사 후 실행한다.
```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```
![image](https://user-images.githubusercontent.com/67575226/211243146-218198d8-35e7-4ba0-b65d-7524d86fb205.png)

<br>
#### 2.3.2. Minikube 설치
1. `Chocolatey` 설치가 완료되었으면 아래 Command를 통해 Minikube를 설치한다. 
```
$ choco install minikube
```
![image](https://user-images.githubusercontent.com/67575226/211241438-b6abb40d-14f3-460a-a170-69d3fb24ac9e.png)
  
2. minikube를 구동시킨다. 
```
$ minikube start
```
![image](https://user-images.githubusercontent.com/67575226/211241528-5615c3bb-0cac-411c-9e73-b7910c955685.png)
  
3. `kubectl` 명령어를 통해 Kubernetes Resource조회가 잘 되는지 확인 한다.
![image](https://user-images.githubusercontent.com/67575226/211241580-2fa0bf13-7441-4b95-bc6d-38e2907d6514.png)