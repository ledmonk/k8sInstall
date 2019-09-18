#!/bin/bash
tennantid= 
apiToken=
paasToken=
#############
# Will loop through all namespaces in your cluster
namespacelist=`kubectl get namespaces | awk '{print $1}' | grep -v "NAME"`
#################

kubectl delete namespace dynatrace
kubectl create namespace dynatrace
LATEST_RELEASE=$(curl -s https://api.github.com/repos/dynatrace/dynatrace-oneagent-operator/releases/latest | grep tag_name | cut -d '"' -f 4)
kubectl create -f https://raw.githubusercontent.com/Dynatrace/dynatrace-oneagent-operator/$LATEST_RELEASE/deploy/kubernetes.yaml
kubectl -n dynatrace logs -f deployment/dynatrace-oneagent-operator
kubectl -n dynatrace create secret generic oneagent --from-literal="apiToken=$apiToken" --from-literal="paasToken=$paasToken"
kubectl create -f cr.yaml
kubectl apply -f dt-mon-srv-acct.yaml

# creates a view only service account per namespace to enable pulling in metadata & labels for pods
for i in $namespacelist
do kubectl create rolebinding serviceaccounts-view --clusterrole=view --group=system:serviceaccounts:$i --namespace=$i
done

printf '\n%s\n' "API Endpoint For Activegate:"
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'
printf '\n%s\n'
printf '\n%s\n' "Auth Token:"
kubectl get secret $(kubectl get sa dynatrace-monitoring -o jsonpath='{.secrets[0].name}' -n dynatrace) -o jsonpath='{.data.token}' -n dynatrace | base64 --decode
printf '\n%s\n' 
printf '\n%s' "Dynatrace is installed yo!"
printf '\n%s' "Go checkout all that data: "
printf '\n%s\n' "https://$tennantid.live.dynatrace.com"
printf '\n%s\n' "Add the K8s API endpoint & auth token to the Active Gate install:"
printf '\n%s\n' "https://$tennantid.live.dynatrace.com#settings/kubernetesmonitoring;gf=all"
printf '\n%s' ""

