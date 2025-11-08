
#Terraform code for EC2 Provisioning

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/*20.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    
    owners = ["099720109477"] # Canonical
}

provider "aws" {
  region  = "eu-west-1"
}

resource "aws_instance" "gs_app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = "gs-ssh"

  tags = {
    Name = var.ec2_name
  }
}

resource "aws_security_group" "ec2_security_group" {
  name        = "GS_EC2_security_group"
  description = "Allow HTTP, HTTPS, and SSH access"
  vpc_id     = "vpc-12345678"  # Specify your VPC ID

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTP access from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTPS access from anywhere
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["200.10.100.0/24"]  # SSH access from specific IP range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

