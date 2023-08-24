#!/bin/bash
export PROCESS="● [Certificate]"

######################################
# Prerequisite
# 1. 2개의 클러스터 준비 
# 2. .kube/config 설정
#   context 명 : ctx-1, ctx-2 (Host정보 정확히 / 127.0.0.1 안됨)
# 3. 방화벽, 네트웍IP 등록(OpenStack) 
# 4. MetalLB 설정
######################################


# 인증성 생성용 step 설치
echo $PROCESS"step 설치"
wget https://github.com/smallstep/cli/releases/download/v0.24.4/step_linux_0.24.4_amd64.tar.gz -O step.tar.gz
tar -xvzf step.tar.gz
sudo mv step_0.24.4/bin/step /usr/bin/
sudo chmod +x /usr/bin/step

echo $PROCESS"Step 설치확인"
step version


# 인증서 생성 
# 디렉토리 생성 
echo $PROCESS"인증서 디렉토리 생성"
mkdir -p $HOME/linkerd/certs
cd $HOME/linkerd/certs

# 루트 인증서 및 키 생성
echo $PROCESS"루트인증서 생성"
step certificate create root.linkerd.cluster.local ca.crt ca.key \
--profile root-ca --no-password --insecure

echo $PROCESS"서브인증서 생성"
step certificate create identity.linkerd.cluster.local issuer.crt issuer.key \
--profile intermediate-ca --not-after 8760h --no-password --insecure \
--ca ca.crt --ca-key ca.key


echo $PROCESS"tree 설치"
sudo apt-get install tree -y

echo $PROCESS"인증서 확인"
tree .
