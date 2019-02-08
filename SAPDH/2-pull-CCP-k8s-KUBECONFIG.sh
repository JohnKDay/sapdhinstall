#!/bin/bash
set -v

#CLUSTER=sapdatahub
CLUSTER=${1:-ccp222b-cluster1o}

# get cookie

if [ -z "$MGMT_HOST" ]; then
   printf "Error: need MGMT_HOST env variable set\n"
   exit 1
fi

[ -d temp ] || mkdir temp
[ -w temp/_context-merge.KUBECONFIG ] || touch temp/_context-merge.KUBECONFIG

curl -k -c temp/cookie.txt -H "Content-Type:application/x-www-form-urlencoded" -d "username=admin&password=${PASS}" https://$MGMT_HOST/2/system/login/

# get SAP DH TC information 

curl -sk -b temp/cookie.txt https://$MGMT_HOST/2/clusters/${CLUSTER}| tee temp/${CLUSTER}.json| jq '.name,.uuid,.state'
# get TC environment file

TC=$(jq -r '.uuid' temp/${CLUSTER}.json)
echo $TC

curl -sk -b temp/cookie.txt https://$MGMT_HOST/2/clusters/${TC}/env | set_kubeconfig_cluster.rb ${CLUSTER} >  temp/${CLUSTER}.KUBECONFIG

# test kubctl commands

KUBECONFIG=temp/${CLUSTER}.KUBECONFIG kubectl get nodes -o wide

# export the value to set KUBECONFIG

echo "export KUBECONFIG=${PWD}/temp/${CLUSTER}.KUBECONFIG"


