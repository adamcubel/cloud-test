variable "region" {
  description = "AWS Region to provision resources"
  type = string
  default = "us-east-1"
}

variable "eks_cluster_version" {
  description = "version of EKS to use"
  type = string
  default = "1.30"
}