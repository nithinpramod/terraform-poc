provider "aws" {
  region = "us-east-1"  # Set to your preferred AWS region
}
# Declare the security group for the RDS instance
resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-sg-"
  vpc_id      = "vpc-014ccc486a24d5676"  # Your VPC ID

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow access from anywhere (not recommended for production)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS Security Group"
  }
}

# Reference the existing DB subnet group
resource "aws_db_instance" "rds_instance" {
  allocated_storage      = 20
  identifier             = "rdstest"  
  engine                 = "postgres"
  engine_version         = "13.16"  # Ensure this version is available in your region
  instance_class         = "db.t3.micro"
  username               = "dbadmin"  # Use a non-reserved username
  password               = "password123"  # Use a secure password
  parameter_group_name   = "default.postgres13"
  skip_final_snapshot    = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = "default-subnet-group"  # Use the existing subnet group
  storage_encrypted      = false

  publicly_accessible    = false
  multi_az               = false

}

