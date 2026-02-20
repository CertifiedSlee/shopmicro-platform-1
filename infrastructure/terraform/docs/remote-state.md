# Remote state and locking (recommended AWS pattern)

- State: S3 bucket with versioning and encryption
- Locking: DynamoDB table
- Access: least privilege IAM role

In this capstone repo, the backend is documented to avoid requiring live AWS credentials.
