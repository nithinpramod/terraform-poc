

resource "aws_kms_key" "rds_cmk" {
  description             = "Customer Managed Key for encryption(RDS)"
  deletion_window_in_days = 30

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

resource "aws_kms_alias" "cmk_alias_rds" {
  name          = "alias/rds-cmk-key"
  target_key_id = aws_kms_key.rds_cmk.key_id
}

data "aws_caller_identity" "current" {}
