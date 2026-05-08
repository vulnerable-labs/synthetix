#!/bin/sh

# Wait for MinIO to be available
sleep 5

# Configure mc with the MinIO server credentials
mc alias set myminio http://minio:9000 admin SuperSecretPassword123!

# Create the bucket
mc mb myminio/llm-data

# Make the bucket public read/write
mc anonymous set public myminio/llm-data

# Upload the initial training data
mc cp training_data.jsonl myminio/llm-data/

echo "MinIO setup completed."
