aws rds create-db-snapshot \
  --db-snapshot-identifier "snapshot-$(date +%Y%m%d-%H%M%S)" \
  --db-instance-identifier "temp" \
  --region "us-east-1"
