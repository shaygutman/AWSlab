output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.lab.name
}

output "cluster_endpoint" {
  description = "EKS API endpoint"
  value       = aws_eks_cluster.lab.endpoint
}

output "cluster_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "configure_kubectl" {
  description = "Command to configure kubectl for this cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.lab.name}"
}

output "vpc_id" {
  description = "Lab VPC ID"
  value       = aws_vpc.lab.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "node_group_name" {
  description = "Managed node group name"
  value       = aws_eks_node_group.lab.node_group_name
}

output "destroy_reminder" {
  description = "How to tear everything down after the lab"
  value       = <<-EOT
    1) kubectl delete -f ../k8s/
    2) cd terraform && terraform destroy -auto-approve
  EOT
}
