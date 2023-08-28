#!/bin/bash

kubectl delete -f helloworld-v2.yaml  --context=ctx-2

./remove_multicluster.sh

./remove_deploy.sh

kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.0/deploy/static/provider/cloud/deploy.yaml --context=ctx-2

kubectl delete ns linkerd-multicluster --context=ctx-2

kubectl delete ns linkerd-viz --context=ctx-2

kubectl delete ns linkerd --context=ctx-2

kubectl delete ns ingress-nginx --context=ctx-2

kubectl delete ns linkerd-multicluster --context=ctx-1

kubectl delete ns linkerd-viz --context=ctx-1

kubectl delete ns linkerd --context=ctx-1