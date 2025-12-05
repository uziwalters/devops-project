terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
 
  region = var.aws_region
}

# ---------- VARIABLES ----------

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"  # London
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for a Linux image (e.g., Amazon Linux 2 or Ubuntu)"
  type        = string
}

# ---------- SECURITY GROUP (FIREWALL) ----------

resource "aws_security_group" "web_sg" {
  name        = "devops-project-web-sg"
  description = "Allow SSH and Flask app traffic"
  vpc_id      = null # uses default VPC

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Flask app on port 5000
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-project-web-sg"
  }
}

# ---------- EC2 INSTANCE ----------

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "devops-project-web"
  }
}

# ---------- OUTPUTS ----------

output "instance_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the web server"
  value       = aws_instance.web.public_dns
}
