#!/bin/bash

# Variables
ENCRYPTED_SNAPSHOT_ID="snapshot-20250422-071126-encrypted"
NEW_DB_INSTANCE_ID="temp-restored"
DB_INSTANCE_CLASS="db.t3.micro"
REGION="us-east-1"
SUBNET_GROUP_NAME="default-subnet-group"
VPC_SECURITY_GROUP_ID=$(aws ec2 describe-security-groups \
  --filters Name=group-name,Values="rds-sg-*" \
  --query 'SecurityGroups[0].GroupId' \
  --output text \
  --region "$REGION")

# Restore the RDS instance
echo "Restoring new RDS instance from snapshot $ENCRYPTED_SNAPSHOT_ID..."

aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier "$NEW_DB_INSTANCE_ID" \
  --db-snapshot-identifier "$ENCRYPTED_SNAPSHOT_ID" \
  --db-instance-class "$DB_INSTANCE_CLASS" \
  --region "$REGION" \
  --vpc-security-group-ids "$VPC_SECURITY_GROUP_ID" \
  --db-subnet-group-name "$SUBNET_GROUP_NAME"

# Wait until the new DB is available
echo "Waiting for DB instance $NEW_DB_INSTANCE_ID to become available..."
aws rds wait db-instance-available \
  --db-instance-identifier "$NEW_DB_INSTANCE_ID" \
  --region "$REGION"

echo "✅ RDS instance '$NEW_DB_INSTANCE_ID' restored successfully from encrypted snapshot."
