resource "random_id" "id" {
  byte_length = 8
}

resource "aws_s3_bucket" "mybucket" {
  #randomly generated bucket name
  bucket        = "mywebappbucket-${random_id.id.hex}"
  acl           = "private"
  force_destroy = true
  lifecycle_rule {
    id      = "StorageTransitionRule"
    enabled = true
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

}

#iam policy for ec2 to access s3
resource "aws_iam_policy" "WebAppS3_policy" {
  name = "WebAppS3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = "arn:aws:s3:::${aws_s3_bucket.mybucket.bucket}/*"
        Resource = "arn:aws:s3:::${aws_s3_bucket.mybucket.bucket}/*"
      }
    ]
  })
}

#iam role for ec2 to access s3
resource "aws_iam_role" "WebAppS3_role" {
  name = "EC2-CSYE6225"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

#iam role policy attachment
resource "aws_iam_role_policy_attachment" "WebAppS3_role_policy_attachment" {
  role       = aws_iam_role.WebAppS3_role.name
  policy_arn = aws_iam_policy.WebAppS3_policy.arn
}

output "bucket_name" {
  value = aws_s3_bucket.mybucket.bucket
}
output "ec2_iam_role" {
  value = aws_iam_role.WebAppS3_role.name
}

# Path: modules/instance/main.tf