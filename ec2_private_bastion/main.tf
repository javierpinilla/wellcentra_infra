# VPC existente
data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

# SG Existente para EC2/Lambda
data "aws_security_group" "ec2_sg" {
  vpc_id = data.aws_vpc.existing_vpc.id
  filter {
    name   = "tag:Name"
    values = ["${local.vpc_name}-ec2-lambda-sg"]
  }
}

# Subredes privadas para ubicar EC2
data "aws_subnet" "private_subnets" {
  count = 3
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["${local.vpc_name}-private-subnet-${count.index + 1}"]
  }
}

# SSM Role
resource "aws_iam_role" "ec2_role" {
  name = "${local.vpc_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(var.common_tags, {
    Name = "${local.vpc_name}-ec2-role"
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${local.vpc_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Data source para AMI Amazon Linux 2023
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Instancia EC2
resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t2.micro"
  subnet_id                   = element(data.aws_subnet.private_subnets, 0).id
  vpc_security_group_ids      = [data.aws_security_group.ec2_sg.id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp3"
    volume_size = 30
    tags = merge(var.common_tags, {
      Name = "${local.ec2_name}-ebs-root"
    })
    delete_on_termination = true
    encrypted             = true
  }

  user_data = <<-EOF
            #!/bin/bash
            yum update -y
            systemctl enable amazon-ssm-agent
            systemctl start amazon-ssm-agent
            systemctl restart amazon-ssm-agent
            yum install -y postgresql17 telnet curl docker
            EOF

  tags = merge(var.common_tags, {
    Name = local.ec2_name
  })
}