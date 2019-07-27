This is a demo for deploying sample application on Kubernetes Cluster

Steps
1. Prparation
2. clone git code repository
3. Launch EKS cluster in AWS
4. Deploy Jenkins on EKS cluster
5. Configure Jenkins pipeline job
6. Deploy sample application
7. Validate Application
8. Delete all the deployments and services from EKS cluster
9. Destroy EKS cluster with Terraform 


1. Preparation.

Install terrafrom in your local machine or in baisten host.
Configure AWS with your AWS access key and secret key

Install kubectl 
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

Install aws-iam-authenticator

wget https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.3.0/heptio-authenticator-aws_0.3.0_linux_amd64
chmod +x heptio-authenticator-aws_0.3.0_linux_amd64
mv heptio-authenticator-aws_0.3.0_linux_amd64 /usr/local/bin/aws-iam-authenticator


clone git code repository

git clone https://github.com/ynraju4/k8s-demo.git


3. Launch EKS cluster in AWS

cd k8s-demo/terraform-aws-eks/k8s/eks
terraform init
terraform plan #Note: Please check how many resources are going to create on AWS for EKS
terraform apply #Cross verify resources list, type yes and enter

Take environment configuration to back and soure the configuration to access the cluster by kubectl 

terraform output kubectl_config > kubeconfig
mkdir -p $HOME/.kube
cp kubeconfig $HOME/.kube/config

Note: Please wait for few minutes until nodes health is ready state and check nodes health
kubectl get no
configure aws authentication

terraform output config_map_aws_auth > aws-auth.yml
kubectl apply -f aws-auth.yml

4. Deploy Jenkins on EKS cluster

cd ../../../jenkins/
 kubectl create -f jenkins.yml
 
 Wait for few minutes till pod get join to load balancer 
 Get jenkins loadbalancer URL from EKS
 kubectl get services |grep jenkins
 
 
kubectl get services |grep k8s-app

kubectl delete services jenkins k8s-app

kubectl delete deployments jenkins k8s-app

cd ../terraform-aws-eks/k8s/eks/
terraform destroy -force


 

 


