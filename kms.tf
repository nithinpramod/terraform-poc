provider "aws" {
  region = "eu-west-1"  # Change as per your requirement
}

resource "aws_kms_key" "cmk" {
  description             = "Customer Managed Key for encryption"
  deletion_window_in_days = 10

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "key-default-1",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_kms_alias" "cmk_alias" {
  name          = "alias/my-cmk-key"
  target_key_id = aws_kms_key.cmk.key_id
}

data "aws_caller_identity" "current" {}
