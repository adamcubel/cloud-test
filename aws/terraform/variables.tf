variable "region" {
  description = "AWS Region to provision resources"
  type = string
  default = "us-east-1"
}

variable "vpc_id" {
  description = "ID of the VPC used for deployment"
  type = string
}

variable "eks_subnet_ids" {
  description = "Subnet IDs for where EKS should be provisioned"
  type = list(string)
}

variable "eks_cluster_version" {
  description = "version of EKS to use"
  type = string
  default = "1.30"
}