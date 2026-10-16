variable "aws_region" {
  description = "AWS region for the lab (us-east-1 is best for Free Tier)"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "eks-lab"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.34"
}

variable "vpc_cidr" {
  description = "CIDR for the lab VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs for the two public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "node_instance_type" {
  description = "EC2 instance type for the managed node group (Free Tier eligible)"
  type        = string
  default     = "t3.micro"
}

variable "node_disk_size" {
  description = "EBS root volume size (GiB). Keep small for Free Tier."
  type        = number
  default     = 20
}
