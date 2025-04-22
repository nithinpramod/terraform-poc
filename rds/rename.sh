#!/bin/bash

# Set variables
OLD_DB_ID="rdstest"
NEW_DB_ID="temp"
REGION="us-east-1"

# Rename the RDS instance
echo "Renaming RDS DB instance from $OLD_DB_ID to $NEW_DB_ID..."

aws rds modify-db-instance \
  --db-instance-identifier "$OLD_DB_ID" \
  --new-db-instance-identifier "$NEW_DB_ID" \
  --region "$REGION" \
  --apply-immediately

# Check if command succeeded
if [ $? -eq 0 ]; then
  echo "Modification request submitted. It may take a few minutes to complete."
else
  echo "Failed to rename the DB instance."
fi
