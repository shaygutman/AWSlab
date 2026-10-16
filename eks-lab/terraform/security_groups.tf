# Cluster security group — control plane ENIs in the VPC
resource "aws_security_group" "cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "EKS cluster security group (lab)"
  vpc_id      = aws_vpc.lab.id

  tags = {
    Name = "${var.cluster_name}-cluster-sg"
  }
}

# Nodes security group
resource "aws_security_group" "nodes" {
  name        = "${var.cluster_name}-nodes-sg"
  description = "EKS managed nodes security group (lab)"
  vpc_id      = aws_vpc.lab.id

  # Do NOT tag with kubernetes.io/cluster/* — only the EKS-managed SG may have that tag,
  # otherwise Classic Load Balancer creation fails ("Multiple tagged security groups").
  tags = {
    Name = "${var.cluster_name}-nodes-sg"
  }
}

# Nodes → cluster API (HTTPS)
resource "aws_security_group_rule" "cluster_ingress_nodes_https" {
  description              = "Nodes to cluster API"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.nodes.id
}

# Cluster → nodes (kubelet)
resource "aws_security_group_rule" "nodes_ingress_cluster" {
  description              = "Cluster to node kubelet"
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = aws_security_group.cluster.id
}

# Node-to-node (pods / CoreDNS)
resource "aws_security_group_rule" "nodes_ingress_self" {
  description       = "Node to node"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.nodes.id
  self              = true
}

# Outbound from nodes (pull images, talk to EKS API over the internet)
resource "aws_security_group_rule" "nodes_egress_all" {
  description       = "Nodes outbound"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nodes.id
}

# Outbound from cluster ENIs
resource "aws_security_group_rule" "cluster_egress_all" {
  description       = "Cluster outbound"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster.id
}
