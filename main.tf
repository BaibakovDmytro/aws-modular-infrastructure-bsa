# 1. Провайдер и Ключи
provider "aws" {
  region = "us-east-1"
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "canada_key" {
  key_name   = "canada_key"
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${path.module}/canada_key.pem"
  content  = tls_private_key.pk.private_key_pem
  file_permission = "0400"
}

# 2. S3 Хранилище
resource "aws_s3_bucket" "script_storage" {
  bucket = "my-unique-canada-bucket-2026" 
}

resource "aws_s3_bucket_public_access_block" "security_block" {
  bucket = aws_s3_bucket.script_storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.script_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. Безопасность и Сеть
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_sg"
  description = "Allow SSH inbound traffic"

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

# 4. База данных DynamoDB
resource "aws_dynamodb_table" "processed_files" {
  name           = "ProcessedFilesTable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "FileName"

  attribute {
    name = "FileName"
    type = "S"
  }
}

# 5. Роли и Права (IAM)
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
      Resource = aws_dynamodb_table.processed_files.arn
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2_s3_profile"
  role = aws_iam_role.ec2_s3_access_role.name
}

# 6. Сервер (EC2)
resource "aws_instance" "canada_server" {
  ami           = "ami-0c7217cdde317cfec" 
  instance_type = "t3.micro"
  key_name      = aws_key_pair.canada_key.key_name

  iam_instance_profile   = aws_iam_instance_profile.ec2_s3_profile.name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y awscli python3-pip
              pip3 install boto3
              EOF

  tags = { Name = "Canada-Main-Server" }
}

# 7. Результаты (Outputs)
output "instance_public_ip" {
  value = aws_instance.canada_server.public_ip
}