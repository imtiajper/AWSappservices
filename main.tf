terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.65" 
 #     version = "~> 4.0"
    }
  }
}

variable "imtiaj_app" {
  description = "App for test"
  type        = string
}

variable "imtiaj_image" {
  description = "ami of app"
  type        = string
}

variable "app_port" {
  description = "Port on which the app listens"
  type        = number
  default     = 443
}


resource "aws_iam_role" "app_role" {
  name = "${var.imtiaj_app}-role"

  assume_role_policy = <<EOF
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
EOF
}


resource "aws_subnet" "app_subnets" {
  vpc_id                   = aws_vpc.app_vpc.id
  cidr_block               = "10.0.2.0/24"
  tags = {
    Name = "imtiaj_subnet"
  }
}

resource "aws_security_group" "app_security_group" {
  vpc_id      = aws_vpc.app_vpc.id
  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
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

resource "aws_instance" "imtiaj_web" {
    ami                  = "var.imtiaj_image"
    intance_type         = "t2.micro"
    key_name             = "imtiaj_test_key"
    security_groups      = "data.aws_security_group.app_security_group"
    iam_instance_profile = "data.aws_iam_role.app_role"
}

# TEST




