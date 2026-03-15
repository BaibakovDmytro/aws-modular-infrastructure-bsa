provider "aws" {
  region = "us-east-1"
}

# 1. SSH Key Management (Automated RSA Generation)
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "canada_key" {
  key_name   = "canada_key"
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename        = "${path.module}/canada_key.pem"
  content         = tls_private_key.pk.private_key_pem
  file_permission = "0400"
}

# 2. Remote State Access: Security & Infrastructure Foundation (BASE Layer)
data "terraform_remote_state" "base" {
  backend = "local"

  config = {
    path = "${path.module}/../base/terraform.tfstate"
  }
}

# 3. Remote State Access: Storage & Databases (SERVICES Layer)
data "terraform_remote_state" "services" {
  backend = "local"

  config = {
    path = "${path.module}/../services/terraform.tfstate"
  }
}

# 4. Compute Resources (EC2 Instance)
resource "aws_instance" "canada_server" {
  ami           = "ami-0c7217cdde317cfec" 
  instance_type = "t3.micro"
  key_name      = aws_key_pair.canada_key.key_name

  # Modular Infrastructure Integration:
  # Injecting IAM Profile from BASE layer
  iam_instance_profile   = data.terraform_remote_state.base.outputs.iam_instance_profile_name
  
  # Injecting Security Group (Restricted to Admin IP) from BASE layer
  vpc_security_group_ids = [data.terraform_remote_state.base.outputs.security_group_id]

  # Provisioning: Automated Environment Setup
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y awscli python3-pip
              pip3 install boto3
              EOF

  tags = {
    Name        = "Canada-Main-Server"
    Project     = "QLR-Score"
    Environment = "Dev"
    ManagedBy   = "Terraform"
    Owner       = "Dmytro Baibakov"
  }
}

# Archive the Python script into a ZIP file
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/hello_world.py"
  output_path = "${path.module}/hello_world.zip"
}

# Create IAM role for Lambda execution
resource "aws_iam_role" "lambda_role" {
  name = "qlr_test_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Define the Lambda function resource
resource "aws_lambda_function" "test_automation_lambda" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "qlr-test-automation"
  role          = aws_iam_role.lambda_role.arn
  handler       = "hello_world.lambda_handler"
  runtime       = "python3.9"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}