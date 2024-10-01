provider "aws" {
  region = var.region
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_vpc" "test" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "test-vpc"
  }
}

resource "aws_subnet" "iaas" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.10.0.0/18"

  tags = {
    Name = "IaaS"
  }
}

resource "aws_subnet" "eks1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.10.64.0/18"

  tags = {
    Name = "eks1"
  }
}

resource "aws_subnet" "eks2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.10.128.0/18"

  tags = {
    Name = "eks2"
  }
}

resource "aws_subnet" "eks3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.10.192.0/18"

  tags = {
    Name = "eks3"
  }
}

resource "aws_security_group" "eks" {
  name        = "EKS Cluster"
  description = "Allow traffic"
  vpc_id      = data.aws_vpc.cluster_vpc.id

  ingress {
    description      = "World"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge({
    Name = "EKS Cluster",
    "kubernetes.io/cluster/eks-cluster": "owned"
  })
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.2"
  cluster_name    = "EKS Cluster"
  cluster_version = var.eks_cluster_version

  vpc_id                         = aws_vpc.test.id
  subnet_ids                     = [aws_subnet.eks1.id, aws_subnet.eks2.id, aws_subnet.eks3.id]
  cluster_endpoint_public_access = false
  cluster_endpoint_private_access = true
  cluster_additional_security_group_ids = [aws_security_group.eks.id]
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"
      instance_types = ["t3.medium"]
      
      min_size     = 1
      max_size     = 6
      desired_size = 2
    }
  }
}
