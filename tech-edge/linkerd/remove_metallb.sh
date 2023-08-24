#!/bin/bash
export PROCESS="[METALLB]"
context=("ctx-1" "ctx-2")

# External IP로 사용할 대역을 설정
echo $PROCESS"MetalLB IP대역 설정"
cat << EOF | kubectl delete --context=ctx-1 -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default
  namespace: metallb-system
spec:
  addresses:
    - 10.100.0.12-10.100.1.15
  autoAssign: true
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
spec:
  ipAddressPools:
    - default
EOF

cat << EOF | kubectl delete --context=ctx-2 -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default
  namespace: metallb-system
spec:
  addresses:
    - 10.100.0.17-10.100.0.20
  autoAssign: true
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
spec:
  ipAddressPools:
    - default
EOF


# MetalLB 설정 확인
echo $PROCESS"MetalLB 설정 확인"
for ctx in "${context[@]}"; do
    echo "..."$ctx
    kubectl get pods -n metallb-system --context=$ctx
done
