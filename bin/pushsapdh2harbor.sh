#!/bin/sh


docker images --format "{{.Repository}}:{{.Tag}}" | grep aws.com | while read name
  do
    echo $name
    echo ${name#*aws.com/}
    docker tag $name 10.10.149.4/ccpsapdh/${name#*aws.com/}
    docker push 10.10.149.4/ccpsapdh/${name#*aws.com/}
  done
