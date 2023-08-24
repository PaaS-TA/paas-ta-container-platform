#!/bin/bash

kubectl delete -f helloworld-v2.yaml  --context=ctx-2

./remove_multicluster.sh

./remove_deploy.sh

kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.0/deploy/static/provider/cloud/deploy.yaml --context=ctx-2

kubectl delete ns linkerd-multicluster

kubectl delete ns linkerd-viz

kubectl delete ns linkerd

kubectl delete ns ingress-nginx