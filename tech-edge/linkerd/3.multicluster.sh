#!/bin/bash
export PROCESS="● [MultiCluster]"
context=("ctx-1" "ctx-2")
spinner=( '|' '/' '-' '\' )

# cluster1(ctx-1)에 linkerd-multicluster 설치
echo $PROCESS"linkerd-multicluster 설치"
for ctx in "${context[@]}"; do
    echo "..."$ctx
    helm install linkerd-multicluster -n linkerd-multicluster --create-namespace linkerd/linkerd-multicluster --kube-context=$ctx
done

# cluster2(ctx-2) 자격증명 추출 후 cluster1(ctx-1)에 생성
linkerd multicluster link --context=ctx-2  --cluster-name cluster2  |  kubectl --context=ctx-1 apply -f -

echo $PROCESS"sleep 5sec..."
sleep 40s

max=$((SECONDS + 10))

while [[ ${SECONDS} -le ${max} ]]
do
    for item in ${spinner[*]}
    do
        echo -en "\r$item"
        sleep .2
        echo -en "\r              \r"
    done
done

echo $PROCESS"multicluster 연결 상태 확인"
linkerd multicluster check --context=ctx-1
