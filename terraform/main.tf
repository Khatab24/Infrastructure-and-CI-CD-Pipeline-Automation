
# the provider
provider "aws" {
  region     = var.aws_region
}

# create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "my_vpc"
  }
}

# create public subnets in two different AZs
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_cidr_block_a
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"
  tags = {
    Name = "Public_Subnet_A"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_cidr_block_b
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2b"
  tags = {
    Name = "Public_Subnet_B"
  }
}
# create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_internet_gateway"
  }
}

# route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "public_route_table"
  }
}

# route for internet gateway
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# associate route table with subnet
resource "aws_route_table_association" "public_subnet_a_association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_b_association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}


# key pair
# ================================================================================
# create key pair for connecting to EC2 by SSH
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_4096.public_key_openssh
}

# save the private key in the specific path on my lactop 
resource "local_file" "private_key" {
  content  = tls_private_key.rsa_4096.private_key_pem
  filename = var.private_key_path
  file_permission = "400"
}


# create security group
# ===================================================================================
resource "aws_security_group" "sg_ec2" {
  vpc_id      = aws_vpc.my_vpc.id
  name        = "sg_ec2"
  description = "Security group for EC2"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # my pubblic ip 
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #to install jenkins 
  }
    
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"   # to HTTP
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}






# Step 3: Create an IAM Instance Profile for the EC2 instance
resource "aws_iam_instance_profile" "eks_instance_access" {
  role = aws_iam_role.eks_node_group_role.name
}






# create EC2 instance
# ================================================================================
resource "aws_instance" "public_instance" {
  ami                    = var.ami_id  
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key_pair.key_name
  iam_instance_profile   = aws_iam_instance_profile.eks_instance_access.name
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]
  subnet_id              = aws_subnet.public_subnet_a.id
  associate_public_ip_address = true

  tags = {
    Name = "MY_jenkins_EC2"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }
}
# EKS Cluster Role
#=======================================================
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "eks_policy_attachment" {
  name       = "eks-cluster-policy-attachment"
  roles      = [aws_iam_role.eks_cluster_role.name]
  policy_arn = aws_iam_policy.eks_permissions.arn
}
#=========================================================================================
resource "aws_iam_policy" "eks_permissions" {
  name        = "EKSDescribeAndListPolicy"
  description = "IAM policy to allow describe and list actions for EKS"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListNodegroups"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}


# create EKS cluster
#===================================================================
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSServicePolicy
  ]
}


# EKS node role
# ===========================================================================
resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Step 2: Attach AmazonEKSClusterPolicy to IAM Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

# role to SSH access to the node group
#===========================================================================================
resource "aws_iam_role_policy" "eks_worker_node_ssh_policy" {
  name        = "EKSWorkerNodeSSHAccess"
  role        = aws_iam_role.eks_node_group_role.id
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2-instance-connect:SendSSHPublicKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# EKS NODE GROUP
# ==============================================================================================================================================
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  instance_types = ["t3.medium"] 

  # Key name to allow SSH access (assuming the key pair is created in AWS)
  remote_access {
    ec2_ssh_key = var.key_name
  }

  depends_on = [
    aws_security_group.sg_ec2,
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_registry_policy,
  ]

  tags = {
    Name = "eks_node_group"
  }
}

#outputs
#==========================================================================
output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "public_subnet_a_id" {
  value = aws_subnet.public_subnet_a.id
}


output "public_subnet_b_id" {
  value = aws_subnet.public_subnet_b.id
}


output "ec2_instance_id" {
  value = aws_instance.public_instance.id
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

