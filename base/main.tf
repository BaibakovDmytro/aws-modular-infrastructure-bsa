provider "aws" {
  region = "us-east-1"
}

# 1. Security (Zero Trust Compliance)
variable "my_ip" {
  description = "Administrative IP for secure SSH access"
  type        = string
  default     = "0.0.0.0/32" # REPLACE WITH YOUR ACTUAL IP
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_sg"
  description = "Allow SSH inbound traffic from specific IP only"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "Canada-SSH-SG"
    Project = "QLR-Score"
  }
}

# 2. Roles & Permissions (IAM - Least Privilege Principle)
resource "aws_iam_role" "ec2_s3_access_role" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_readonly" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy" "dynamodb_write_policy" {
  name = "dynamodb_write_policy"
  role = aws_iam_role.ec2_s3_access_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:UpdateItem"]
      Effect   = "Allow"
      Resource = "*" # Specific ARN to be restricted in production
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2_s3_profile"
  role = aws_iam_role.ec2_s3_access_role.name
}

# 3. OUTPUTS - Used for cross-layer communication with Application layer
output "security_group_id" {
  value = aws_security_group.allow_ssh.id
}

output "iam_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_s3_profile.name
}