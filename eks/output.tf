# output "cluster_name" {
#   value = module.eks.cluster_name
# }

output "subnet_ids" {
  value = var.subnet_ids
}

output "node_role_arn" {
  value = "arn:aws:iam::456130209114:role/cmk_encrypted_nodes-eks-node-group-20250430081203008100000006"
}
