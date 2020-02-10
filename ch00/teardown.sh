#!/bin/sh

# Exit if any of the intermediate steps fail
set -e

# Remove EKS cluster
del=1

while [ $del -ne 0 ] ;
do
  sleep 5 
  echo 'try to delete eks'
  eksctl delete cluster -f eks.yaml
  del=$?
done

echo 'Clean up Done. Please do not forget check at console.'