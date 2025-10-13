module "vpc" {
  source = "./vpc"

  vpc_parameters            = var.vpc_parameters
  public_subnet_parameters  = var.public_subnet_parameters
  private_subnet_parameters = var.private_subnet_parameters
  create_nat                = var.create_nat

  tags = var.tags
}

resource "aws_key_pair" "k8s_key" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.public_key_path)

  tags = merge({
    Name = "${var.project_name}-key"
  }, var.tags)
}

resource "aws_security_group" "jumpbox_sg" {
  name        = "${var.project_name}-jumpbox-sg"
  description = "Access controls for the jumpbox"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.project_name}-jumpbox-sg"
  }, var.tags)
}

resource "aws_security_group" "kubernetes_sg" {
  name        = "${var.project_name}-nodes-sg"
  description = "Access controls for the Kubernetes cluster nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "SSH from jumpbox"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jumpbox_sg.id]
  }

  ingress {
    description     = "Kubernetes API server"
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = [aws_security_group.jumpbox_sg.id]
  }

  ingress {
    description = "Intra-cluster communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "etcd server client API"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Kubelet API"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.project_name}-nodes-sg"
  }, var.tags)
}

resource "aws_instance" "jumpbox" {
  ami                    = data.aws_ami.debian_12.id
  instance_type          = var.jumpbox_instance_type
  subnet_id              = module.vpc.public_subnet_id
  vpc_security_group_ids = [aws_security_group.jumpbox_sg.id]
  key_name               = aws_key_pair.k8s_key.key_name

  user_data = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname jumpbox

    apt update
    apt install -y netcat-openbsd
  EOF  

  root_block_device {
    volume_size = var.jumpbox_root_volume_size
    volume_type = var.root_volume_type
  }

  tags = merge({
    Name = "${var.project_name}-jumpbox"
    Role = "admin"
  }, var.tags)
}

resource "aws_instance" "control_plane" {
  ami                    = data.aws_ami.debian_12.id
  instance_type          = var.control_plane_instance_type
  subnet_id              = module.vpc.private_subnet_id
  vpc_security_group_ids = [aws_security_group.kubernetes_sg.id]
  key_name               = aws_key_pair.k8s_key.key_name
  depends_on             = [module.vpc]

  user_data = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname control-plane
    echo "127.0.1.1 control-plane.kubernetes.local control-plane" >> /etc/hosts

    apt update
    apt install -y netcat-openbsd
  EOF 

  root_block_device {
    volume_size = var.control_plane_root_volume_size
    volume_type = var.root_volume_type
  }

  tags = merge({
    Name = "${var.project_name}-control-plane"
    Role = "control-plane"
  }, var.tags)
}

resource "aws_instance" "worker" {
  count                  = var.worker_count
  ami                    = data.aws_ami.debian_12.id
  instance_type          = var.worker_instance_type
  subnet_id              = module.vpc.private_subnet_id
  vpc_security_group_ids = [aws_security_group.kubernetes_sg.id]
  key_name               = aws_key_pair.k8s_key.key_name
  depends_on             = [module.vpc]

  user_data = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname worker-${count.index}
    echo "127.0.1.1 worker-${count.index}.kubernetes.local worker-${count.index}" >> /etc/hosts

    apt update
    apt install -y netcat-openbsd
  EOF 

  root_block_device {
    volume_size = var.worker_root_volume_size
    volume_type = var.root_volume_type
  }

  tags = merge({
    Name = "${var.project_name}-worker-${count.index}"
    Role = "worker"
  }, var.tags)
}
