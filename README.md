# Infrastructure-and-CI-CD-Pipeline-Automation
This project aims to demonstrate a complete workflow for creating, configuring, and deploying a web application infrastructure using modern DevOps practices and tools. The solution leverages Terraform for infrastructure provisioning, Ansible for configuration management, Kubernetes for container orchestration, and Jenkins for Continuous Integration and Continuous Deployment (CI/CD).

![Infrastructure-and-CI-CD-Pipeline-Automation drawio (1)](https://github.com/user-attachments/assets/e1a330f2-3fe9-4e21-b989-f043be2988ae)
### Prerequisites : 
  - [Terraform](https://www.terraform.io/downloads.html)
  - [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
  - [AWS CLI](https://aws.amazon.com/cli/)
  - [kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)
  - [Jenkins](https://www.jenkins.io/doc/book/installing/)

     
### 1-Clone the Repository
```scss
git clone https://github.com/Khatab24/Infrastructure-and-CI-CD-Pipeline-Automation.git
cd Infrastructure-and-CI-CD-Pipeline-Automation
```

### 2-AWS Configuration
```scss
aws configure
```

### 3-Deploy AWS Infrastructure using Terraform
```scss
cd terraform-Infra
terraform init
terraform plan
terraform apply
```
### 4-Deploy Jenkins to EC2 using Ansible
```scss
cd ../ansible
ansible-playbook -i inventory install-jenkins.yml
```
### 5-Prepare GitHub Repository
## (Instructions: Create two branches, add Dockerfile, Kubernetes files, Jenkinsfile, and set up webhook)

### 6-Kubernetes Configuration
```scss
aws eks --region <region> update-kubeconfig --name <cluster_name>
cd k8s/dev
kubectl create namespace dev
kubectl create namespace prod
```
### 7-Prerequisites for Jenkins
```scss
sudo apt-get install awscli
sudo apt-get install kubectl
```
### 8-Access Jenkins
### Open Jenkins UI in your browser:
### http://<EC2_INSTANCE_IP>:8080

### 9-Install Jenkins plugins (Docker and Kubernetes)

### 10-Add AWS and GitHub credentials to Jenkins

### 11-Create a new Jenkins Pipeline
### 12-Add Jenkinsfile repo URL, define branches, and configure webhook

