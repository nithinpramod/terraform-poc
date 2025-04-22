output "cluster_name" {
  value = module.eks.cluster_name
}

output "subnet_ids" {
  value = var.subnet_ids
}

output "node_role_arn" {
  value = module.eks.eks_managed_node_groups["unencrypted_nodes"].iam_role_arn
}
