# Infrastructure-and-CI-CD-Pipeline-Automation
# Project Overview
# Infrastructure as Code with Terraform, Ansible, and Kubernetes CI/CD Pipeline
This project aims to demonstrate a complete workflow for creating, configuring, and deploying a web application infrastructure using modern DevOps practices and tools. The solution leverages Terraform for infrastructure provisioning, Ansible for configuration management, Kubernetes for container orchestration, and Jenkins for Continuous Integration and Continuous Deployment (CI/CD).

![Infrastructure-and-CI-CD-Pipeline-Automation drawio (1)](https://github.com/user-attachments/assets/e1a330f2-3fe9-4e21-b989-f043be2988ae)


# Objectives
## 1-Infrastructure Creation:

Set up a scalable and secure cloud infrastructure using Terraform modules.
Create a Virtual Private Cloud (VPC) with a 2 public subnet for hosting EC2 and EKS.
Deploy an EC2 instance within the public subnet, ensuring it has internet access.
Provision a Kubernetes cluster using Elastic Kubernetes Service (EKS) within the same VPC.
# 2-Configuration Management:

Automate the installation of Jenkins and requirements on the EC2 instance using Ansible playbooks, ensuring a consistent setup.
# 3-Source Code Management:

Prepare a GitHub repository for a simple web project(RedStore), establishing a clear structure with Dev branche.
Write a Dockerfile to containerize the web application, ensuring it runs consistently across environments.
Create necessary Kubernetes deployment and service files to manage the application lifecycle.
# 4-Kubernetes Configuration:

Implement namespace in the Kubernetes cluster:Dev.
Deploy the application using Load Balancer services on namespace, exposing it externally for user access.
# 5-CI/CD Pipeline Setup:

Integrate Jenkins with GitHub to automate the CI/CD process, enabling seamless deployments.
Create pipeline for the Dev branche, automating the build and deployment of Docker images.
Configure a GitHub webhook to trigger deployments upon code pushes, ensuring that the Dev branch updates the Dev namespace.

## Technologies Used
- Terraform: Infrastructure provisioning and management.
- Ansible: Configuration management and automation.
- Kubernetes: Container orchestration and management.
- AWS EKS: Managed Kubernetes service.
- Jenkins: Continuous Integration and Continuous Deployment.
- Docker: Containerization of applications.
