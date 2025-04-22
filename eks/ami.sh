#!/bin/bash

set -e

REGION="us-east-1"
KMS_KEY_ALIAS="alias/eks/eks-unencrypted-demo"

echo "🔍 Searching for a running EKS worker node instance..."
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag-key,Values=eks:nodegroup-name" \
            "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[0].InstanceId' \
  --output text \
  --region "$REGION")

if [[ "$INSTANCE_ID" == "None" || -z "$INSTANCE_ID" ]]; then
  echo "❌ No running EKS worker node instance found."
  exit 1
fi

echo "✅ Found instance: $INSTANCE_ID"

# Step 1: Create AMI
AMI_NAME="eks-node-unencrypted-$(date +%Y%m%d%H%M%S)"
echo "📸 Creating AMI: $AMI_NAME"
SOURCE_AMI=$(aws ec2 create-image \
  --instance-id "$INSTANCE_ID" \
  --name "$AMI_NAME" \
  --no-reboot \
  --query 'ImageId' \
  --output text \
  --region "$REGION")

echo "⏳ Waiting for unencrypted AMI ($SOURCE_AMI) to become available..."
aws ec2 wait image-available --image-ids "$SOURCE_AMI" --region "$REGION"
echo "✅ Source AMI available: $SOURCE_AMI"

# Step 2: Copy with CMK encryption
ENCRYPTED_AMI_NAME="eks-node-encrypted-$(date +%Y%m%d%H%M%S)"
echo "🔐 Copying AMI with encryption using KMS key: $KMS_KEY_ALIAS"
ENCRYPTED_AMI=$(aws ec2 copy-image \
  --source-image-id "$SOURCE_AMI" \
  --source-region "$REGION" \
  --region "$REGION" \
  --name "$ENCRYPTED_AMI_NAME" \
  --encrypted \
  --kms-key-id "$KMS_KEY_ALIAS" \
  --query 'ImageId' \
  --output text)

echo "⏳ Waiting for encrypted AMI ($ENCRYPTED_AMI) to become available..."
aws ec2 wait image-available --image-ids "$ENCRYPTED_AMI" --region "$REGION"

echo "✅ Encrypted AMI created: $ENCRYPTED_AMI"
