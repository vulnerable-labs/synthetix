#!/bin/sh

echo "Waiting for MinIO to be available..."
until mc alias set myminio http://minio:9000 admin SuperSecretPassword123!; do
    echo "MinIO not ready yet, retrying in 2 seconds..."
    sleep 2
done

# Create the bucket
mc mb myminio/llm-data

# Make the bucket public read/write
mc anonymous set public myminio/llm-data

# Upload the initial training data
mc cp training_data.jsonl myminio/llm-data/

echo "MinIO setup completed."
