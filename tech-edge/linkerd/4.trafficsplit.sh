#!/bin/bash
export PROCESS="● [TrafficSplit]"

# linkerd-smi 설치
echo $PROCESS"linkerd-smi 설치"
helm install linkerd-smi l5d-smi/linkerd-smi -n linkerd-smi --create-namespace --kube-context=ctx-1

