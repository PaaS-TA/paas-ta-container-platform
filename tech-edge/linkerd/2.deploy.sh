#!/bin/bash
export PROCESS="● [Linkerd Deploy]"
context=("ctx-1" "ctx-2")

######################################
# Prerequisite
# 1. 2개의 클러스터 준비 
#  
# 2. .kube/config 설정
#   context 명 : ctx-1, ctx-2 (Host정보 정확히 / 127.0.0.1 안됨)
# 3. 방화벽, 네트웍IP 등록(OpenStack) 
# 4. MetalLB 설정(LoadBalancer)
# 5. 인증서 설정
######################################

# linkerd 레파지토리 등록
echo $PROCESS"linkerd Helm repository 등록"
helm repo add linkerd https://helm.linkerd.io/stable
helm repo add l5d-smi https://linkerd.github.io/linkerd-smi

# linkerd cli 수동설치
echo $PROCESS"linkerd cli 설치"
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh
sudo mv $HOME/.linkerd2/bin/linkerd /usr/bin/
sudo chmod +x /usr/bin/linkerd

# linkerd 설치 확인
echo $PROCESS"linkerd cli 설치 확인"
linkerd version

# Cluster별로 linkerd-crds 설치
echo $PROCESS"linkerd-crds 설치"
for ctx in "${context[@]}"; do
    echo "..."$ctx
    helm install linkerd-crds linkerd/linkerd-crds -n linkerd --create-namespace --kube-context=$ctx
done

# Cluster별로 linkerd-control-plane 설치
echo $PROCESS"linkerd-control-plane 설치"
for ctx in "${context[@]}"; do
    echo "..."$ctx
    helm install linkerd-control-plane -n linkerd \
      --set-file identityTrustAnchorsPEM=$HOME/linkerd/certs/ca.crt \
      --set-file identity.issuer.tls.crtPEM=$HOME/linkerd/certs/issuer.crt \
      --set-file identity.issuer.tls.keyPEM=$HOME/linkerd/certs/issuer.key \
      linkerd/linkerd-control-plane --kube-context=$ctx
done

# Cluster별로 linkerd-viz 설치
echo $PROCESS"linkerd-viz 설치"
for ctx in "${context[@]}"; do
    echo "..."$ctx
    helm install linkerd-viz -n linkerd-viz --create-namespace linkerd/linkerd-viz --kube-context=$ctx
done

# Cluster별로ingress 생성 
echo $PROCESS"Ingress 생성"
for ctx in "${context[@]}"; do
    echo "..."$ctx
    kubectl apply -f linkerd-viz-ingress.yaml --context=$ctx
done
