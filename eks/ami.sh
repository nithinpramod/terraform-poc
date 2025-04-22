#!/bin/bash

set -e

REGION="us-east-1"
KMS_KEY_ALIAS="alias/eks/eks-unencrypted-demo"

echo "Fetching one EKS worker node instance ID..."
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:eks:nodegroup-name,Values=unencrypted-nodes" \
            "Name=instance-state-name,Values=running" \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text \
  --region "$REGION")

echo "Instance ID: $INSTANCE_ID"

# Step 1: Create AMI from instance
AMI_NAME="eks-node-unencrypted-$(date +%Y%m%d%H%M%S)"
echo "Creating AMI: $AMI_NAME"
SOURCE_AMI=$(aws ec2 create-image \
  --instance-id "$INSTANCE_ID" \
  --name "$AMI_NAME" \
  --no-reboot \
  --query 'ImageId' --output text --region "$REGION")

echo "Waiting for AMI to become available..."
aws ec2 wait image-available --image-ids "$SOURCE_AMI" --region "$REGION"
echo "Source AMI ID: $SOURCE_AMI"

# Step 2: Copy AMI with CMK encryption
ENCRYPTED_AMI_NAME="eks-node-encrypted-$(date +%Y%m%d%H%M%S)"
echo "Copying AMI with encryption..."
ENCRYPTED_AMI=$(aws ec2 copy-image \
  --source-image-id "$SOURCE_AMI" \
  --source-region "$REGION" \
  --region "$REGION" \
  --name "$ENCRYPTED_AMI_NAME" \
  --encrypted \
  --kms-key-id "$KMS_KEY_ALIAS" \
  --query 'ImageId' --output text)

echo "Waiting for encrypted AMI to become available..."
aws ec2 wait image-available --image-ids "$ENCRYPTED_AMI" --region "$REGION"

echo "✅ Encrypted AMI created: $ENCRYPTED_AMI"
