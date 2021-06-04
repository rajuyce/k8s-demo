
# Provisioning AWS EKS Cluster with Terraform and deploying Jenkins with slave pods, EFK Stack, Prometheus and Sample Web Application on K8S

<img src="https://github.com/ynraju4/Readme_Images/blob/master/og-image-8b3e4f7d%20(1).png" width="100" height="100"><img src="https://github.com/ynraju4/Readme_Images/blob/master/eks-orig.jpg" width="190" height="100"><img src="https://github.com/ynraju4/Readme_Images/blob/master/k8s-demo/headshot.png" width="75" height="75"><img src="https://github.com/ynraju4/Readme_Images/blob/master/download.png" width="100" height="100"><img src="https://github.com/ynraju4/Readme_Images/blob/master/Prometheus_software_logo.jpg" width="100" height="100">



Note: Fork k8s-demo Repository to your GitHub account to execute all the steps without any issues

#### Steps
1. Preparation
2. Clone git code repository
3. Launch EKS cluster in AWS
4. Install Helm and Deploy tiller on k8s
5. Deploy Jenkins on k8s with Helm
6. Configure Jenkins pipeline job for ELK 
7. Deploy ELK Stack on k8s
8. Depoly Prometheus with Helm on k8s (Optional)
9. Create CI/CD Pipeline Job for Sample Java Application(optional)
10. Validate all deployed Componets
11. Decommission

#   1. Preparation.

#### Install Terraform

```bash
tfenv install 0.14.11
```

#### Configure AWS account which has AdminAccess for all Resources

```bash
aws configure
```

#### Install kubectl 

```bash
brew install kubernetes-cli
```

#### Install aws-iam-authenticator

```bash
brew install aws-iam-authenticator
```

# 2. Clone git code repository

```bash
git clone https://github.com/ynraju4/k8s-demo.git
```

# 3. Launch EKS cluster in AWS
###### Worker Nodes Count: 2, Size: t2.xlarge, Subnets: private

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

# 4. Install Helm and Deploy tiller on k8s

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

# 5. Deploy Jenkins on k8s with Helm

```bash
cd ../jenkins
helm install stable/jenkins --values values-jenkins.yml --name jenkins
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

# 6. Configure Jenkins pipeline job for ELK 

#### Login to Jenkins and access Dashboard with Jenkins LoadBalancer

![alt text](https://github.com/ynraju4/Readme_Images/blob/master/Jenkins_Home_Page.PNG)

#### Create DitHub Credentials Account in Jenkins Dashboard with ID: GitHub

Navigation: Jenkins ➭ Credentials ➭ System ➭ Global credentials (unrestricted) ➭ Add Credentials
 
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/GitHub.PNG)
 
#### Create DockerHub Credentials Account in Jenkins Dashboard with ID: dockerhub
 
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/dockerhub.PNG)
 
#### Set DockerHub Repository Environment Variables in Jenkins Dashboard

Navigation: Jenkins ➭ Manage Jenkins ➭ Configure System

Note: GitHub and Docker hub environment variables ORGANIZATION_NAME, REPOSITORY_K8S, REPOSITORY_MVN

![alt text](https://github.com/ynraju4/Readme_Images/blob/master/k8s-demo/env_variables.PNG)

#### Create New Pipeline Job
 
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/Create%20New%20job.PNG)

#### Select Job Type: Pipeline
 
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/k8s-demo/job_type.PNG)
 
#### Configure Source Code Repository
 
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/k8s-demo/github_entry.PNG)
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/k8s-demo/githubhook.PNG)
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/k8s-demo/pipeline_definition.PNG)
![alt text](https://github.com/ynraju4/Readme_Images/blob/master/k8s-demo/github_reentry.PNG)
 
###### #Click on "Save" to create Job

# 7. Deploy ELK Stack on k8s

![alt text](https://github.com/ynraju4/Readme_Images/blob/master/k8s-demo/Build_now.PNG)

##### Build status

![alt text](https://github.com/ynraju4/Readme_Images/blob/master/k8s-demo/eks_build_status.PNG)

# 8. Create GitHub webhook for ELK stack CI/CD Pipline

![alt text](https://github.com/ynraju4/Readme_Images/blob/master/k8s-demo/github-webhook.PNG)

##### Kibana Home Page

![alt text](https://github.com/ynraju4/Readme_Images/blob/master/k8s-demo/Kibana_home_page.PNG)

# 9. Depoly Prometheus on k8s with Helm on k8s (Optional)

```bash
helm install --name monitoring --namespace monitoring stable/prometheus-operator
```

# 10. Create CI/CD Pipeline Job for Sample Java Application(optional)

###### Source Code: https://github.com/ynraju4/mvn-demo.git

##### Maven Application Build status

![alt text](https://github.com/ynraju4/Readme_Images/blob/master/k8s-demo/mvn-demo.PNG)


 
# 11. Validate all deployed Componets

#### End Urls after DNS configuration
###### Note: Considering security we will not be exposing cluster maintenance applications and internal applications to the external loadbalancers. This is just a demo 
##### Internal

Jenkins: http://jenkins.gofair.in \
Kibana: https://kibana.gofair.in \
Prometheus: http://prometheus.gofair.in \
Rancher: https://rancher.gofair.in


##### External

Demo Application: https://www.gofair.in

# 12. Decommission 

###### Delete all the deployments and services from EKS cluster

```bash
cd ../elk
kubectl delete -f kibana/kibana.yaml
kubectl delete -f elasticsearch/elasticsearch.yaml
kubectl delete -f fluentd/fluentd.yaml
kubectl delete -f configmaps/fluentd-config.yaml
```

```bash
helm del --purge jenkins
```

######. Destroy EKS cluster with Terraform 

```bash
cd ../terraform-aws-eks/k8s/eks/
terraform destroy 
```

###### #Type "yes" and Enter in Terraform prompt to Decommission all AWS resources created for EKS



