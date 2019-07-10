provider "aws" {
  version = "~> 2.0"
  region = "us-west-2"
}

variable "cluster-name" {
  default = "sample-system-eks"
  type    = "string"
}

# VPC

# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_availability_zones" "available" {}

resource "aws_vpc" "sample-system-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "sample-users-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "sample-system-subnet" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.sample-system-vpc.id}"

  tags = "${
    map(
     "Name", "sample-system-eks-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "sample-system-gateway" {
  vpc_id = "${aws_vpc.sample-system-vpc.id}"

  tags = {
    Name = "sample-system-eks"
  }
}

resource "aws_route_table" "sample-system-route" {
  vpc_id = "${aws_vpc.sample-system-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.sample-system-gateway.id}"
  }
}

resource "aws_route_table_association" "sample_system" {
  count = 2

  subnet_id      = "${aws_subnet.sample-system-subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.sample-system-route.id}"
}

# EKS Master IAM role

resource "aws_iam_role" "sample-system-cluster" {
  name = "sample-system-eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "sample-system-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.sample-system-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "sample-system-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.sample-system-cluster.name}"
}

# EKS Master Cluster Security Group

resource "aws_security_group" "sample-system-cluster" {
  name        = "sample-system-eks-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.sample-system-vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sample-system-eks"
  }
}

# OPTIONAL: Allow inbound traffic from your local workstation external IP
#           to the Kubernetes. You will need to replace A.B.C.D below with
#           your real IP. Services like icanhazip.com can help you find this.
resource "aws_security_group_rule" "sample-system-cluster-ingress-workstation-https" {
  cidr_blocks       = ["86.57.255.92/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sample-system-cluster.id}"
  to_port           = 443
  type              = "ingress"
}

# EKS Master Cluster

resource "aws_eks_cluster" "sample-system" {
  name            = "${var.cluster-name}"
  role_arn        = "${aws_iam_role.sample-system-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.sample-system-cluster.id}"]
    subnet_ids         = ["${aws_subnet.sample-system-subnet.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.sample-system-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.sample-system-cluster-AmazonEKSServicePolicy",
  ]
}

# Worker Node IAM Role and Instance Profile
resource "aws_iam_role" "sample-system-node" {
  name = "smaple-system-eks-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "sample-system-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.sample-system-node.name}"
}

resource "aws_iam_role_policy_attachment" "sample-system-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.sample-system-node.name}"
}

resource "aws_iam_role_policy_attachment" "sample-system-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.sample-system-node.name}"
}

resource "aws_iam_instance_profile" "sample-system-node" {
  name = "sample-system-eks"
  role = "${aws_iam_role.sample-system-node.name}"
}

# Worker Node Security Group
resource "aws_security_group" "sample-system-node" {
  name        = "sample-system-eks-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.sample-system-vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "sample-system-eks-node",
     "kubernetes.io/cluster/${var.cluster-name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "sample-system-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.sample-system-node.id}"
  source_security_group_id = "${aws_security_group.sample-system-node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "sample-system-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sample-system-node.id}"
  source_security_group_id = "${aws_security_group.sample-system-node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

# Worker Node Access to EKS Master Cluster

resource "aws_security_group_rule" "sample-system-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sample-system-cluster.id}"
  source_security_group_id = "${aws_security_group.sample-system-node.id}"
  to_port                  = 443
  type                     = "ingress"
}

# Worker Node AutoScaling Group

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.sample-system.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_region" "current" {}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We implement a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  sample-system-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.sample-system.endpoint}' --b64-cluster-ca '${aws_eks_cluster.sample-system.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA
}

resource "aws_launch_configuration" "sample-system-node" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.sample-system-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "m4.large"
  name_prefix                 = "terraform-eks-demo"
  security_groups             = ["${aws_security_group.sample-system-node.id}"]
  user_data_base64            = "${base64encode(local.sample-system-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "sample-system-node-group" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.sample-system-node.id}"
  max_size             = 2
  min_size             = 1
  name                 = "sample-system-eks"
  vpc_zone_identifier  = ["${aws_subnet.sample-system-subnet.*.id}"]

  tag {
    key                 = "Name"
    value               = "sample-system-eks"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.sample-system-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

output "config_map_aws_auth" {
  value = "${local.config_map_aws_auth}"
}
