#!/bin/bash

namespacelist=`kubectl get namespaces | awk '{print $1}' | grep -v "NAME"`
# creates a view only service account per namespace to enable pulling in metadata & labels for pods

for i in $namespacelist
do kubectl create rolebinding serviceaccounts-view --clusterrole=view --group=system:serviceaccounts:$i --namespace=$i
done