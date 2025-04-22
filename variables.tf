variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "eks-unencrypted-demo"
}

variable "subnet_ids" {
  default = ["subnet-071d24e7da7812932", "subnet-02848b6b3026b21a4"]
}

variable "vpc_id" {
  default = "vpc-014ccc486a24d5676"
}

variable "node_instance_type" {
  default = "t3.medium"
}

variable "desired_capacity" {
  default = 2
}
