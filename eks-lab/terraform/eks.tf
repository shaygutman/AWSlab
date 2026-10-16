resource "aws_eks_cluster" "lab" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  # API access for kubectl from your laptop; bootstrap gives you cluster-admin
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids              = aws_subnet.public[*].id
    endpoint_public_access  = true
    endpoint_private_access = false
    security_group_ids      = [aws_security_group.cluster.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]

  tags = {
    Name = var.cluster_name
  }
}

# Launch template so nodes use our SG + the EKS cluster SG, with a small gp3 disk
resource "aws_launch_template" "nodes" {
  name_prefix = "${var.cluster_name}-node-"

  vpc_security_group_ids = [
    aws_eks_cluster.lab.vpc_config[0].cluster_security_group_id,
    aws_security_group.nodes.id,
  ]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.node_disk_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-node"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "${var.cluster_name}-node-volume"
    }
  }
}

# Managed Node Group — single t3.micro in public subnets (Free Tier friendly)
resource "aws_eks_node_group" "lab" {
  cluster_name    = aws_eks_cluster.lab.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.public[*].id

  # EKS 1.34: Amazon Linux 2023 only (AL2 AMI is not published for 1.34)
  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = "ON_DEMAND"
  instance_types = [var.node_instance_type]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.nodes.id
    version = aws_launch_template.nodes.latest_version
  }

  labels = {
    role = "lab"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    Name = "${var.cluster_name}-ng"
  }
}
