
# This is a demo for deploying sample application on Kubernetes Cluster

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

  #   1. Preparation.

Install terrafrom

```bash
wget https://releases.hashicorp.com/terraform/0.12.5/terraform_0.12.5_linux_amd64.zip
unzip terraform_0.12.5_linux_amd64.zip
mv terraform /usr/local/bin
```
Configure AWS account which has AdminAccess for all resources

```bash
aws configure
```

Install kubectl 
```bash
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

Install aws-iam-authenticator

```bash
wget https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.3.0/heptio-authenticator-aws_0.3.0_linux_amd64
chmod +x heptio-authenticator-aws_0.3.0_linux_amd64
mv heptio-authenticator-aws_0.3.0_linux_amd64 /usr/local/bin/aws-iam-authenticator
```


# 2. clone git code repository

```bash
git clone https://github.com/ynraju4/k8s-demo.git
```

# 3. Launch EKS cluster in AWS

```bash
cd k8s-demo/terraform-aws-eks/k8s/eks
terraform init
terraform plan #Note: Please check how many resources are going to create on AWS for EKS
terraform apply #Cross verify resources list, type yes and enter
```

Take environment configuration to back and soure the configuration to access the cluster by kubectl 

```bash
terraform output kubectl_config > kubeconfig
mkdir -p $HOME/.kube
cp kubeconfig $HOME/.kube/config

#Note: Please wait for few minutes until nodes health is ready state and check nodes health
kubectl get no

#configure aws authenticater
terraform output config_map_aws_auth > aws-auth.yml
kubectl apply -f aws-auth.yml
```

# 4. Deploy Jenkins on EKS cluster
```bash
cd ../../../jenkins/
 kubectl create -f jenkins.yml
 ```
 Wait for few minutes till pod get join to load balancer 
 Get jenkins loadbalancer URL from EKS
 ```bash
 kubectl get services |grep jenkins
 ```
 
 ```bash
kubectl get services |grep k8s-app
```
#8. Delete all the deployments and services from EKS cluster
 ```bash
kubectl delete services jenkins k8s-app

kubectl delete deployments jenkins k8s-app
```
# 9. Destroy EKS cluster with Terraform 
 ```bash
cd ../terraform-aws-eks/k8s/eks/
terraform destroy -force
```

 

 


