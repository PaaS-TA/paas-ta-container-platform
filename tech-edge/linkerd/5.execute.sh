#!/bin/bash

arrData=()

for (( i=0; i<100; i++ ))
  do
    arrData[i]=$(kubectl exec --context=ctx-1 "$(kubectl get pod --context=ctx-1 -l app=sleep -o jsonpath='{.items[0].metadata.name}')" -c sleep -- curl -sS helloworld:5000/hello)
    
    v1=0
    v2=0
    total=$(expr $i + 1)
    for data in "${arrData[@]}"; do
        if [[ "$data" == *v1* ]] ; then
            ((v1++))
        else 
            ((v2++))
        fi
    done
    echo "[ v1:"$v1 "/ v2:"$v2" ]   "  ${arrData[-1]}

    sleep 2s
done
