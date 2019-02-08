#!/bin/bash

#Get list of repositories and pull to docker

aws --region=us-west-2 --profile=ECRpull --output=text ecr describe-repositories | cut -f 4,5 -d'	' | while read uri name
  do
    echo ---
    #echo $name
    aws --profile=ECRpull --output=text --region=us-west-2 ecr list-images --repository $name | cut -f 3 -d'	' | while read version
      do
        echo "931164380164.dkr.ecr.us-west-2.amazonaws.com/$name:$version"
        docker pull "931164380164.dkr.ecr.us-west-2.amazonaws.com/$name:$version"
      done
  done
