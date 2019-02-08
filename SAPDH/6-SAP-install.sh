#!/bin/bash

set -v
#cd ./SAPDataHub-2.3.167-Foundation
cd ./SAPDataHub

./install.sh  -n default -p -d -r 10.10.149.4/ccpsapdh

./install.sh  \
	-e=vora-cluster.components.txCoordinator.nodePort=30443  \
	-e=vora-cluster.components.disk.replicas=3  \
	-e=vora-cluster.components.disk.storageSize=200Gi  \
	-e=vora-cluster.components.dlog.storageSize=100Gi \
	--cert-domain=datahub.sslip.io  \
	--accept-license  \
	--vora-admin-username="admin" \
	--vora-admin-password="superduperadmin" \
	--vora-system-password="superduperadmin" \
	--interactive-security-configuration=no  \
	-r 10.10.149.4/ccpsapdh \
	-n default \
	--enable-checkpoint-store=yes \
	--checkpoint-store-type=s3 \
	--checkpoint-store-connection="AccessKey=minioaccess\&SecretAccessKey=miniosecret\&Host=http://10.10.148.10:9000\&Path=sapdh"
