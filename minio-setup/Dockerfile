FROM minio/mc:latest

WORKDIR /setup
COPY setup.sh .
COPY training_data.jsonl .

ENTRYPOINT ["/bin/sh", "setup.sh"]
