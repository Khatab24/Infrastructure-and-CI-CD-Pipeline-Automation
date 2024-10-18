variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-2"  
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block_a" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.10.0/24"
}

variable "public_subnet_cidr_block_b" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.20.0/24"
}


#============================================================================================
variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "ubuntu-key"  
}

variable "private_key_path" {
  description = "Path to save EC2 private key file"
  type        = string
  default     = "/home/khatab/Downloads/ubuntu.pem"  # path on my labtop
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
  default     = "ami-09da212cf18033880"  # Amazon Linux 2023 AMI
}
#==============================================================================================
variable "ssh_ingress_cidr" {
  description = "CIDR block allowed to SSH into the instance"
  default     = "0.0.0.0/0"
}

variable "cluster_name" {
  description = "Name for the EKS cluster"
  default     = "my-eks-cluster"
}