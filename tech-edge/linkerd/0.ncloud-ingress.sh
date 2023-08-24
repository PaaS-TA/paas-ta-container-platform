#!/bin/bash

# ncloud에서 제공하는 ingress-nginx 컨트롤러 배포(ctx-2)
echo "nCloud Kubernetes Service에 ingress 컨트롤러 배포"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.0/deploy/static/provider/cloud/deploy.yaml --context=ctx-2
