#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# ---------------------------------------------------------------------------------------------------------------------
# Download all necessary binary file
# ---------------------------------------------------------------------------------------------------------------------

echo "Get binaries ..."

curl --silent -Lo kubectl curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
echo 'kubectl Done.'

curl --silent -Lo aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator
chmod +x aws-iam-authenticator
sudo mv aws-iam-authenticator /usr/local/bin/
echo 'aws-iam-authenticator Done.'

curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
chmod +x /tmp/eksctl
sudo mv /tmp/eksctl /usr/local/bin
echo 'eksctl Done.'

curl --silent --location "https://github.com/txn2/kubefwd/releases/download/1.11.1/kubefwd_linux_amd64.tar.gz" | tar xz -C /tmp
chmod +x /tmp/kubefwd
sudo mv /tmp/kubefwd /usr/local/bin
echo 'kubefwd Done.'

curl --silent -Lo kubebox https://github.com/astefanutti/kubebox/releases/download/v0.7.0/kubebox-linux
chmod +x kubebox
sudo mv kubebox /usr/local/bin
echo 'kubebox Done.'


curl --silent -Lo terraform.zip https://releases.hashicorp.com/terraform/0.12.20/terraform_0.12.20_linux_amd64.zip
unzip terraform.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/
rm terraform.zip
echo 'terraform Done.'

sudo apt-get install -y jq mysql-client
echo 'jq, mysql-client Done.'

# ---------------------------------------------------------------------------------------------------------------------
# Prepare EKS cluster
# ---------------------------------------------------------------------------------------------------------------------


echo "Prepare EKS cluster ..."
CLUSTER_NAME=container-security-${RANDOM}

cat > eks.yaml << EOF
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: "${CLUSTER_NAME}"
  region: us-west-2

nodeGroups:
  - name: ng0
    instanceType: t3.large
    desiredCapacity: 2
EOF

# Create eks cluster using eksctl
echo "Creating eks cluster and node group with two t3.large instances ..."
eksctl create cluster -f eks.yaml

# Setup OIDC ID provider
eksctl utils associate-iam-oidc-provider --cluster ${CLUSTER_NAME} --approve

# Test if kubernate cluster works good
kubectl get all

echo 'Done setting EKS.'
