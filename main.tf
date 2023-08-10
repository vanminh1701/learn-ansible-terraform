terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.11.0"
    }

  }
  required_version = "~> 1.0"
}

provider "aws" {
  region = "us-east-1"
}

locals {
  tags = {
    "Project"   = "demo"
    "ManagedBy" = "tvminh"
  }
}

module "ec2_instance_client" {
  source = "terraform-aws-modules/ec2-instance/aws"

  for_each = toset(["web01", "web02", "db"])

  name = "instance-${each.key}"

  instance_type          = "t3.micro"
  key_name               = "user1"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.client-sg.id]
  tags = local.tags
}

module "ec2_instance_control" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "instance-control"

  instance_type          = "t3.micro"
  key_name               = "user1"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.control-sg.id]
  tags                   = local.tags
}


resource "aws_security_group" "control-sg" {
  name = "control-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "client-sg" {
  name = "client-sg"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.control-sg.id]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}