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

# Cluster별로ingress 삭제 
echo $PROCESS"Ingress 삭제"
for ctx in "${context[@]}"; do
    echo "..."$ctx
    kubectl delete -f linkerd-viz-ingress.yaml --context=$ctx
done

# Cluster별로 linkerd-viz 삭제
echo $PROCESS"linkerd-viz 삭제"
for ctx in "${context[@]}"; do
    echo "..."$ctx
    helm uninstall linkerd-viz -n linkerd-viz  --kube-context=$ctx
done

# Cluster별로 linkerd-control-plane 삭제
echo $PROCESS"linkerd-control-plane 삭제"
for ctx in "${context[@]}"; do
    echo "..."$ctx
    helm uninstall linkerd-control-plane -n linkerd --kube-context=$ctx
done

# Cluster별로 linkerd-crds 삭제
echo $PROCESS"linkerd-crds 삭제"
for ctx in "${context[@]}"; do
    echo "..."$ctx
    helm uninstall linkerd-crds -n linkerd --kube-context=$ctx
done

# 삭제확인
echo $PROCESS"삭제 확인"
for ctx in "${context[@]}"; do
    echo "..."$ctx
    helm list -n linkerd --kube-context=$ctx
    helm list -n linkerd-viz --kube-context=$ctx
done

# 삭제확인
# echo $PROCESS"Namespace삭제"
# for ctx in "${context[@]}"; do
#     echo "..."$ctx
#     kubectl delete ns linkerd --context=$ctx
#     kubectl delete ns linkerd-viz --context=$ctx
# done
 