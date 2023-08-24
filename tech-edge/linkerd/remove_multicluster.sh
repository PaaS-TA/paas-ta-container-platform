#!/bin/bash
export PROCESS="[MultiCluster]"
context=("ctx-1" "ctx-2")

# cluster1(ctx-1)에 linkerd-multicluster 삭제
echo $PROCESS"linkerd-multicluster 삭제"
for ctx in "${context[@]}"; do
    echo "..."$ctx
    helm uninstall linkerd-multicluster -n linkerd-multicluster --kube-context=$ctx
done

echo $PROCESS"multicluster 연결 상태 확인"
for ctx in "${context[@]}"; do
    echo "..."$ctx
    linkerd multicluster check --context=$ctx
done
