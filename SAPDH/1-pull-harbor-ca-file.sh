#!/bin/bash

set -v
set -euo pipefail

#CLUSTER=sapdatahub
CLUSTER=${1:-ccp222b-harbor1}
HARBOR_PASS=${HARBOR_PASS:-$PASS}

# get cookie

if [ -z "$MGMT_HOST" ]; then
   printf "Error: need MGMT_HOST env variable set\n"
   exit 1
fi

[ -d temp ] || mkdir temp
[ -w temp/_context-merge.KUBECONFIG ] || touch temp/_context-merge.KUBECONFIG

curl -k -c temp/cookie.txt -H "Content-Type:application/x-www-form-urlencoded" -d "username=admin&password=${PASS}" https://$MGMT_HOST/2/system/login/

# Get Harbor TC information

curl -sk -b temp/cookie.txt https://$MGMT_HOST/2/clusters/${CLUSTER}| tee temp/${CLUSTER}.json| jq '.name,.uuid,.state'

# extract Harbor TC environment file

TC=$(jq -r '.uuid' temp/${CLUSTER}.json)
echo $TC

curl -sk -b temp/cookie.txt https://$MGMT_HOST/2/clusters/${TC}/env | set_kubeconfig_cluster.rb ${CLUSTER} >  temp/${CLUSTER}.KUBECONFIG

# write mgmt_host to temp

echo $MGMT_HOST > temp/mgmt_host

# pull harbor CA.crt file to use in other TCs 

KUBECONFIG=temp/${CLUSTER}.KUBECONFIG kubectl get secret ccp-ingress-tls-ca -n ccp -o jsonpath='{.data.tls\.crt}' |base64 -d | tee  temp/ccp.crt


## configure local instance ablilty to push/pull to harbor repo

# Obtain the Harbor Load Balancer IP

LBIP=$(KUBECONFIG=temp/${CLUSTER}.KUBECONFIG kubectl get svc -n ccp -o jsonpath='{.items..status.loadBalancer.ingress[0].ip}') 

# Copy Harbor CA cert into /etc/docker/certs.d for use on install machine

sudo mkdir -p /etc/docker/certs.d/${LBIP}

sudo cp temp/ccp.crt /etc/docker/certs.d/${LBIP}/ca.crt

docker pull johnkday/ubuntu-s3

docker login -u admin -p ${HARBOR_PASS} ${LBIP}

docker tag johnkday/ubuntu-s3 ${LBIP}/library/ubuntu-s3

docker push ${LBIP}/library/ubuntu-s3


