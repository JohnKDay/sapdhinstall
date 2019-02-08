#!/usr/bin/env bash

cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Service
metadata:
  name: vsystem-load-balancer
spec:
  selector:
    app: vora
    vora-component: vsystem
  ports:
  - protocol: TCP
    port: 443
    targetPort: 8797
  type: LoadBalancer
EOF
