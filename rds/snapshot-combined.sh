#!/bin/bash

# Variables
DB_INSTANCE_IDENTIFIER="temp"
REGION="us-east-1"

# Check if KMS_KEY_ID environment variable is set
if [ -z "$KMS_KEY_ID" ]; then
  echo "❌ Error: KMS_KEY_ID environment variable is not set."
  echo "Please export KMS_KEY_ID and try again."
  exit 1
fi

# Generate timestamp-based snapshot IDs
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SOURCE_SNAPSHOT_ID="snapshot-$TIMESTAMP"
TARGET_SNAPSHOT_ID="${SOURCE_SNAPSHOT_ID}-encrypted"

# Step 1: Create an unencrypted snapshot
echo "📸 Creating unencrypted snapshot: $SOURCE_SNAPSHOT_ID"
aws rds create-db-snapshot \
  --db-snapshot-identifier "$SOURCE_SNAPSHOT_ID" \
  --db-instance-identifier "$DB_INSTANCE_IDENTIFIER" \
  --region "$REGION"

# Wait for the snapshot to be available
echo "⏳ Waiting for snapshot $SOURCE_SNAPSHOT_ID to become available..."
aws rds wait db-snapshot-available \
  --db-snapshot-identifier "$SOURCE_SNAPSHOT_ID" \
  --region "$REGION"

# Step 2: Copy the snapshot with encryption
echo "🔐 Copying $SOURCE_SNAPSHOT_ID to encrypted snapshot $TARGET_SNAPSHOT_ID..."
aws rds copy-db-snapshot \
  --source-db-snapshot-identifier "$SOURCE_SNAPSHOT_ID" \
  --target-db-snapshot-identifier "$TARGET_SNAPSHOT_ID" \
  --kms-key-id "$KMS_KEY_ID" \
  --region "$REGION"

# Wait for the encrypted snapshot to be available
echo "⏳ Waiting for encrypted snapshot $TARGET_SNAPSHOT_ID to become available..."
aws rds wait db-snapshot-available \
  --db-snapshot-identifier "$TARGET_SNAPSHOT_ID" \
  --region "$REGION"

echo "✅ Encrypted snapshot created: $TARGET_SNAPSHOT_ID"
