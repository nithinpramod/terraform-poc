#!/bin/bash

set -e

# Variables (set these in your CI/CD environment or pass as arguments)
INSTANCE_ID=$1
CMK_ID=$2
REGION=${3:-"us-east-1"}  # Default to us-east-1 if not passed

# Step 1: Create AMI from the EC2 instance
echo "Creating AMI from instance: $INSTANCE_ID"
AMI_NAME="eks-node-backup-$(date +%Y%m%d%H%M%S)"
AMI_ID=$(aws ec2 create-image \
    --instance-id "$INSTANCE_ID" \
    --name "$AMI_NAME" \
    --no-reboot \
    --region "$REGION" \
    --query 'ImageId' --output text)

echo "Created AMI: $AMI_ID"

# Wait for the AMI to become available
echo "Waiting for AMI to become available..."
aws ec2 wait image-available --image-ids "$AMI_ID" --region "$REGION"
echo "AMI is now available."

# Step 2: Copy the AMI with encryption using CMK
ENCRYPTED_AMI_NAME="${AMI_NAME}-encrypted"
echo "Copying AMI with encryption using CMK ($CMK_ID)..."
ENCRYPTED_AMI_ID=$(aws ec2 copy-image \
    --source-image-id "$AMI_ID" \
    --source-region "$REGION" \
    --region "$REGION" \
    --name "$ENCRYPTED_AMI_NAME" \
    --encrypted \
    --kms-key-id "$CMK_ID" \
    --query 'ImageId' --output text)

echo "Encrypted AMI ID: $ENCRYPTED_AMI_ID"

# Wait for the encrypted AMI to become available
echo "Waiting for encrypted AMI to become available..."
aws ec2 wait image-available --image-ids "$ENCRYPTED_AMI_ID" --region "$REGION"
echo "Encrypted AMI is now available."

echo "Done."
