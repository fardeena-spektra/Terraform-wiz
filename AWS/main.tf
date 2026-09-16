terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.AccessKey
  secret_key = var.SecretKey
}

# ---------------------------------------------------------------------------
# Variables (equivalent to CFN "Parameters")
# ---------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region to deploy into (CFN relied on the implicit console/CLI region)"
  type        = string
  default     = "us-east-1"
}

variable "CloudLabsDeploymentID" {
  type = string
}

variable "AccessKey" {
  description = "Access key to authenticate to AWS account"
  type        = string
  sensitive   = true
}

variable "SecretKey" {
  description = "Secret key to authenticate to AWS account"
  type        = string
  sensitive   = true
}

variable "CheckAcknowledgement" {
  type    = string
  default = "TRUE"
  validation {
    condition     = contains(["TRUE", "FALSE"], var.CheckAcknowledgement)
    error_message = "CheckAcknowledgement must be TRUE or FALSE."
  }
}

variable "vpcCidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "subnetCidr" {
  type    = string
  default = "10.10.0.0/24"
}

variable "AmazonECSTaskExecutionRolePolicy" {
  type    = string
  default = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

variable "VMUserName" {
  type    = string
  default = "Labuser"
}

variable "VMPassword" {
  type      = string
  sensitive = true
}

# ---------------------------------------------------------------------------
# Data sources (equivalent to CFN pseudo parameters)
# ---------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# ---------------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------------

resource "aws_iam_role" "task_execution_role" {
  name = "TaskExecutionRole-${var.CloudLabsDeploymentID}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["ecs-tasks.amazonaws.com"]
        }
        Action = ["sts:AssumeRole"]
      }
    ]
  })

  tags = {
    Name = "TaskExecutionRole-${var.CloudLabsDeploymentID}"
  }
}

resource "aws_iam_role_policy_attachment" "task_execution_role_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = var.AmazonECSTaskExecutionRolePolicy
}

resource "aws_iam_role" "ssm_role" {
  name = "SSMRole-${var.CloudLabsDeploymentID}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_role_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "SSMInstanceProfile-${var.CloudLabsDeploymentID}"
  role = aws_iam_role.ssm_role.name
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

resource "aws_vpc" "clg_vpc" {
  cidr_block           = var.vpcCidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "clgVpc-${var.CloudLabsDeploymentID}"
  }
}

resource "aws_internet_gateway" "clg_igw" {
  tags = {
    Name = "clgInternetGateway-${var.CloudLabsDeploymentID}"
  }
}

resource "aws_internet_gateway_attachment" "attach_igw" {
  internet_gateway_id = aws_internet_gateway.clg_igw.id
  vpc_id               = aws_vpc.clg_vpc.id
}

resource "aws_subnet" "vm_subnet" {
  vpc_id                  = aws_vpc.clg_vpc.id
  cidr_block               = var.subnetCidr
  availability_zone        = "${data.aws_region.current.name}a"
  map_public_ip_on_launch  = true

  tags = {
    Name = "vmSubnet-${var.CloudLabsDeploymentID}"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.clg_vpc.id

  tags = {
    Name = "RouteTable-${var.CloudLabsDeploymentID}"
  }
}

resource "aws_route" "route_to_igw" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id              = aws_internet_gateway.clg_igw.id
  depends_on              = [aws_internet_gateway_attachment.attach_igw]
}

resource "aws_route_table_association" "vm_subnet_rta" {
  subnet_id      = aws_subnet.vm_subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "vm_sg" {
  name_prefix = "vmSecurityGroup-"
  description = "Allow RDP to client host"
  vpc_id      = aws_vpc.clg_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vmSecurityGroup-${var.CloudLabsDeploymentID}"
  }
}

resource "aws_security_group" "clg_sg" {
  name_prefix = "clgSg-"
  description = "Security group for Fargate ECS container - fully open"
  vpc_id      = aws_vpc.clg_vpc.id

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "clgSg-${var.CloudLabsDeploymentID}"
  }
}

# ---------------------------------------------------------------------------
# Key Pair
# CFN's AWS::EC2::KeyPair (no PublicKeyMaterial) auto-generates a new key
# pair; Terraform's aws_key_pair only registers a public key, so we generate
# one with tls_private_key to reproduce the same "brand-new key pair" behavior.
# ---------------------------------------------------------------------------

resource "tls_private_key" "vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "vm_key_pair" {
  key_name   = "labkeypair-${var.CloudLabsDeploymentID}"
  public_key = tls_private_key.vm_key.public_key_openssh
}

# ---------------------------------------------------------------------------
# EC2 Instance
# ---------------------------------------------------------------------------

locals {
  user_data = <<-EOT
    #!/bin/bash
    useradd -m -s /bin/bash ${var.VMUserName}
    echo "${var.VMUserName}:${var.VMPassword}" | chpasswd
    usermod -aG wheel ${var.VMUserName}
    sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    grep -q '^PasswordAuthentication yes' /etc/ssh/sshd_config || echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
    grep -q '^UsePAM yes' /etc/ssh/sshd_config || echo 'UsePAM yes' >> /etc/ssh/sshd_config
    systemctl restart sshd || service sshd restart || service ssh restart
    dnf update -y
    dnf install -y httpd cronie wget nano vim curl --allowerasing
    systemctl enable httpd
    systemctl start httpd
    systemctl enable crond
    systemctl start crond
    mkdir -p /home/${var.VMUserName}/scripts
    chown -R ${var.VMUserName}:${var.VMUserName} /home/${var.VMUserName}/scripts
    mkdir -p /opt/logs
    mkdir -p /opt/validation
    echo '[error] Database connection failed' > /opt/logs/application.log
    echo '[error] Backend timeout' >> /opt/logs/application.log
    echo '[error] Authentication failed' >> /opt/logs/application.log
    chmod -R 755 /opt/logs
    chmod -R 755 /opt/validation
    chown -R ${var.VMUserName}:${var.VMUserName} /opt/logs
    chown -R ${var.VMUserName}:${var.VMUserName} /opt/validation
    echo 'CloudLabs Shell Scripting Lab' > /var/www/html/index.html
    mkdir -p /opt/data
    echo 'Shell Scripting Validation File' > /opt/data/testfile.txt
    chmod 644 /opt/data/testfile.txt
    systemctl enable amazon-ssm-agent
    systemctl restart amazon-ssm-agent
    echo "${var.VMUserName} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${var.VMUserName}
    chmod 440 /etc/sudoers.d/${var.VMUserName}
  EOT
}

resource "aws_instance" "vm_instance" {
  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = "t3.micro"
  iam_instance_profile   = aws_iam_instance_profile.ssm_instance_profile.name
  vpc_security_group_ids = [aws_security_group.vm_sg.id]
  key_name               = aws_key_pair.vm_key_pair.key_name
  subnet_id               = aws_subnet.vm_subnet.id
  user_data_base64        = base64encode(local.user_data)

  tags = {
    Name = "lab-vm-${var.CloudLabsDeploymentID}"
  }
}

# ---------------------------------------------------------------------------
# Outputs (equivalent to CFN "Outputs")
# ---------------------------------------------------------------------------

output "CloudLabsDeploymentID" {
  description = "CloudLabs Deployment ID"
  value       = var.CloudLabsDeploymentID
}

output "AWSAccountID" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "Region" {
  description = "AWS Region"
  value       = data.aws_region.current.name
}

output "VpcId" {
  description = "The ID of the VPC"
  value       = aws_vpc.clg_vpc.id
}

output "vmSubnetId" {
  description = "The ID of the VM Subnet"
  value       = aws_subnet.vm_subnet.id
}

output "vmSecurityGroupId" {
  description = "The SG ID of the VM"
  value       = aws_security_group.vm_sg.id
}

output "clusterSecurityGroupId" {
  description = "The SG ID of the Cluster"
  value       = aws_security_group.clg_sg.id
}

output "TaskExecutionRole" {
  description = "The ARN of the Role utilised by ECS Task Definition"
  value       = aws_iam_role.task_execution_role.arn
}

output "InstanceId" {
  description = "EC2 Instance ID"
  value       = aws_instance.vm_instance.id
}

output "VMName" {
  description = "Name of the VM"
  value       = "labvm"
}

output "VMPublicIP" {
  description = "VM Public IP"
  value       = aws_instance.vm_instance.public_ip
}

output "VMPrivateIP" {
  description = "VM Private IP"
  value       = aws_instance.vm_instance.private_ip
}

output "VMPublicDNSName" {
  description = "Public DNS Name"
  value       = aws_instance.vm_instance.public_dns
}

output "VMPrivateDNSName" {
  description = "Private DNS Name"
  value       = aws_instance.vm_instance.private_dns
}

output "VMUserName" {
  description = "VM Username"
  value       = var.VMUserName
}

output "VMPassword" {
  description = "VM Password"
  value       = var.VMPassword
  sensitive   = true
}
