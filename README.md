
# This is a demo for provisioning EKS-Kubernetes Cluster and deploying ELK Stack

<img src="https://github.com/ynraju4/Readme_Images/blob/master/og-image-8b3e4f7d%20(1).png" width="150" height="150"><img src="https://github.com/ynraju4/Readme_Images/blob/master/eks-orig.jpg" width="285" height="150"><img src="https://github.com/ynraju4/Readme_Images/blob/master/download.png" width="150" height="150">



Note: Fork k8s-demo Repository to your GitHub account to execute all the steps without 

#### Steps
1. Preparation
2. Clone git code repository
3. Launch EKS cluster in AWS
4. Deploy Jenkins on EKS cluster
5. Configure Jenkins pipeline job
6. Deploy Application
7. Validate Application
8. Delete all the deployments and services from EKS cluster
9. Destroy EKS cluster with Terraform 

#   1. Preparation.

#### Install Terraform

```bash
wget https://releases.hashicorp.com/terraform/0.12.5/terraform_0.12.5_linux_amd64.zip
sudo unzip terraform_0.12.5_linux_amd64.zip
sudo mv terraform /usr/local/bin
```

#### Configure AWS account which has AdminAccess for all Resources

```bash
aws configure
```

#### Install kubectl 

```bash

curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

#### Install aws-iam-authenticator

```bash
wget https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.3.0/heptio-authenticator-aws_0.3.0_linux_amd64
chmod +x heptio-authenticator-aws_0.3.0_linux_amd64
sudo mv heptio-authenticator-aws_0.3.0_linux_amd64 /usr/local/bin/aws-iam-authenticator
```

# 2. Clone git code repository

```bash
git clone https://github.com/ynraju4/k8s-demo.git
```

# 3. Launch EKS cluster in AWS
###### Worker Nodes Count: 4

```bash
cd k8s-demo/terraform-aws-eks/k8s/eks
terraform init
terraform plan #Note: Please check how many resources are going to create on AWS for EKS
terraform apply 
```

###### Type "yes" and Enter in Terraform prompt to provision AWS resources for EKS

#### Take environment configuration to backup and source the configuration to access the K8s cluster by kubectl 

```bash
terraform output kubectl_config > kubeconfig
mkdir -p $HOME/.kube
cp kubeconfig $HOME/.kube/config

#Note: Please wait for few minutes until nodes health is ready state
kubectl get no

#Configure aws authenticator
terraform output config_map_aws_auth > aws-auth.yml
kubectl apply -f aws-auth.yml
```

# 4. Install Helm and Deploy Tiller

```bash
cd ../../../helm/
curl -LO https://git.io/get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
```

```bash
 kubectl apply -f helm-rbac.yaml
 helm init --service-account tiller
 ```

# 5. Deploy Jenkins on EKS cluster

```bash
cd ../jenkins
helm install stable/jenkins --values values-myjenkins.yml --name jenkins
```
#### Create RBAC Authentication to Jenkins slave pods

```bash
kubectl apply -f rbac-slave.yaml
```

#### Please wait for few minutes till pod get create and Nodes join LoadBalancer

```bash
kubectl get all
```

#### Get Jenkins LoadBalancer URL from EKS

```bash
kubectl get services |grep jenkins
```

# 5. Deploy ELK pipeline job

#### Access Jenkins Dashboard with Jenkins LoadBalancer

![alt text](https://github.com/ynraju4/Readme_Images/blob/master/Jenkins_Home_Page.PNG)

#### Create DitHub Credentials Account in Jenkins Dashboard with ID: GitHub

Navigation: Jenkins ➭ Credentials ➭ System ➭ Global credentials (unrestricted) ➭ Add Credentials
 
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/GitHub.PNG)
 
#### Create DockerHub Credentials Account in Jenkins Dashboard with ID: dockerhub
 
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/dockerhub.PNG)
 
#### Set DockerHub Repository Environment Variables in Jenkins Dashboard

Navigation: Jenkins ➭ Manage Jenkins ➭ Configure System

Note: Please make sure you have Docker Hub account with same <ORGANIZATION_NAME>/<REPOSITORY_NAME>

![alt text](https://github.com/ynraju4/Readme_Images/blob/master/Environment_Variables.PNG)

#### Create New Pipeline Job
 
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/Create%20New%20job.PNG)

![alt text](https://github.com/ynraju4/Readme_Images/blob/master/Job%20Name.PNG)
 
#### Select Job Type: Multibranch Pipeline
 
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/Job%20Type.PNG)
 
#### Select Source Code Repository Type
 
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/add%20source.PNG)
 
#### Select Source Code Repository
 
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/Git%20Soruce.PNG)
 
#### Verify Jenkinsfile is validated successfully
 
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/Jenkinsfilescan.PNG)

# 7 Deploy Prometheus

```bash
helm install --name monitoring --namespace monitoring stable/prometheus-operator
```

# 6. Deploy Application

#### Run Pipeline Job
 
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/Run%20Job.PNG)
 
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/Pipeline%20Log.PNG)
 
# 7. Validate Application

#### Get k8s-app LoadBalancer URL from k8s cluster

```bash
kubectl get services |grep k8s-app
```
 
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/DryRUN%20No.1.PNG)
 
#### Edit Source Code
 
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/edit_index.PNG)
 
#### Run Jenkins pipeline job and Validate Application Access again
 
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/DryRUN%20No.2.PNG)
 
# 8. Delete all the deployments and services from EKS cluster

```bash
kubectl delete -f kibana/kibana.yaml
kubectl delete -f elasticsearch/elasticsearch.yaml
kubectl delete -f fluentd/fluentd.yaml
kubectl delete -f configmaps/fluentd-config.yaml
```

```bash
helm del --purge jenkins
```

# 9. Destroy EKS cluster with Terraform 

```bash
cd ../terraform-aws-eks/k8s/eks/
terraform destroy 
```

###### #Type "yes" and Enter in Terraform prompt to Decommission all AWS resources created for EKS



