provider "aws" {
  region = "us-east-1"
}

# 1. S3 Storage Layer (Secure Data Repository)
resource "aws_s3_bucket" "script_storage" {
  bucket = "my-unique-canada-bucket-2026" 
  
  tags = {
    Name    = "Canada-Data-Bucket"
    Project = "QLR-Score"
  }
}

# Enforcing Private Access: Disabling all public access to the bucket
resource "aws_s3_bucket_public_access_block" "security_block" {
  bucket = aws_s3_bucket.script_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Data Integrity: Enabling versioning for accidental deletion protection
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.script_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 2. NoSQL Database Layer (DynamoDB - Scalable Results Store)
resource "aws_dynamodb_table" "processed_files" {
  name           = "ProcessedFilesTable"
  
  # Cost Optimization: Pay-per-request mode (No idle costs for the client)
  billing_mode   = "PAY_PER_REQUEST" 
  hash_key       = "FileName"

  attribute {
    name = "FileName"
    type = "S" # String type
  }

  tags = {
    Name    = "Canada-Main-DB"
    Project = "QLR-Score"
  }
}

# OUTPUTS - For cross-layer resource referencing
output "dynamodb_table_arn" {
  value = aws_dynamodb_table.processed_files.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.script_storage.id
}