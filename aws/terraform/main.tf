provider "aws" {
  region = var.region
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

data "aws_vpc" "test" {
  id = var.vpc_id
}

resource "aws_security_group" "eks" {
  name        = "EKS Cluster"
  description = "Allow traffic"
  vpc_id      = data.aws_vpc.test.id

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
    Name = "eks-cluster",
    "kubernetes.io/cluster/eks-cluster": "owned"
  })
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.2"
  cluster_name    = "eks-cluster"
  cluster_version = var.eks_cluster_version

  vpc_id                         = data.aws_vpc.test.id
  subnet_ids                     = var.eks_subnet_ids
  cluster_endpoint_public_access = false
  cluster_endpoint_private_access = true
  enable_cluster_creator_admin_permissions = true
  cluster_additional_security_group_ids = [aws_security_group.eks.id]
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  cluster_addons = {
    coredns            = {}
    kube-proxy         = {}
    vpc-cni            = {}
    aws-ebs-csi-driver = {}
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
