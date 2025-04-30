variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "eks-unencrypted-demo-2"
}

variable "subnet_ids" {
  default = ["subnet-08eb5a9180331ca23","subnet-0a25497eba0417388"]
}

variable "vpc_id" {
  default = "vpc-0aebab0bdccee06d2"
}

variable "node_instance_type" {
  default = "t3.medium"
}

variable "desired_capacity" {
  default = 2
}
