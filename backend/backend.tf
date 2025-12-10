terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Backend: this must be configured BEFORE using the backend.
  # terraform init reads this block; you can't use variables inside the backend block.
  backend "s3" {
    bucket         = "devops-automation-project-harshshahdeo1" # <-- your bucket (owned by your account)
    key            = "terraform/state.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "devops-automation-project-lock-table-harshshahdeo1" # lock table name we'll create below
  }
}

provider "aws" {
  region = "us-east-1"
}

# ---- S3 bucket to store terraform state (optional)
# If the bucket already exists in your account you can remove this resource.
resource "aws_s3_bucket" "s3_remote_backend" {
  bucket = "devops-automation-project-harshshahdeo1" # keep in sync with backend block if creating it here
  acl    = "private"

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = "terraform-remote-state"
    Environment = "dev"
    Project     = "devops-automation-project"
  }
}

# Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "deny_public" {
  bucket = aws_s3_bucket.s3_remote_backend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.s3_remote_backend.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption (SSE-S3 / AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.s3_remote_backend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB table for state locking (recommended)
resource "aws_dynamodb_table" "dynamodb_lock_table" {
  name         = "devops-automation-project-lock-table-harshshahdeo1"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Project = "devops-automation-project"
    Usage   = "terraform-lock"
  }
}
