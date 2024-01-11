terraform {
  backend "s3" {
    bucket                  = "stateprojectgroup2"
    key                     = "terraform.tfstate"   
    region                  = "us-east-1"
  }
}
resource "aws_s3_bucket" "datatechtorialbucket" {
    bucket = "datatechtorialbucket"
}

resource "aws_iam_role" "s3accessforec2_role" {
    name = "s3accessforec2_role"
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

resource "aws_iam_policy" "s3accessforec2_policy" {
    name = "bucketaccessforec2"
    description = "Grants an access for s3 buckets from instances"
    policy = jsonencode({
        Version    = "2012-10-17"
            Statement = [
                {
                    Action   = ["s3:ListBucket"]
                    Effect   = "Allow"
                    Resource = [aws_s3_bucket.datatechtorialbucket.arn]
                },
                {
                    Action   = ["s3:GetObject", "s3:PutObject"]
                    Effect   = "Allow"
                    Resource = ["${aws_s3_bucket.datatechtorialbucket.arn}/*"]
                }
            ]
        })
}

resource "aws_iam_role_policy_attachment" "s3accessforec2_policy_attachment"{
    role = aws_iam_role.s3accessforec2_role.name
    policy_arn = aws_iam_policy.s3accessforec2_policy.arn    
}

resource "aws_iam_instance_profile" "ec2_profile"{
    name = "ec2_profile"
    role = aws_iam_role.s3accessforec2_role.name
}
