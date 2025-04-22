#!/bin/bash

# Variables
SOURCE_SNAPSHOT_ID="snapshot-20250422-071126"
TARGET_SNAPSHOT_ID="${SOURCE_SNAPSHOT_ID}-encrypted"
KMS_KEY_ID="arn:aws:kms:us-east-1:456130209114:key/553e42aa-f6de-4323-81e0-0f303fe287c8"
REGION="us-east-1"

# Copy the unencrypted snapshot to a new encrypted snapshot
echo "Copying snapshot $SOURCE_SNAPSHOT_ID to $TARGET_SNAPSHOT_ID with encryption..."
aws rds copy-db-snapshot \
  --source-db-snapshot-identifier "$SOURCE_SNAPSHOT_ID" \
  --target-db-snapshot-identifier "$TARGET_SNAPSHOT_ID" \
  --kms-key-id "$KMS_KEY_ID" \
  --region "$REGION"

# Wait until the encrypted snapshot becomes available
echo "Waiting for snapshot $TARGET_SNAPSHOT_ID to become available..."
aws rds wait db-snapshot-available \
  --db-snapshot-identifier "$TARGET_SNAPSHOT_ID" \
  --region "$REGION"

echo "Encrypted snapshot created: $TARGET_SNAPSHOT_ID"
