# Terraform (module-structured design)

This folder provides a realistic AWS-style architecture layout (can be used for real accounts).
Modules:
- network (VPC, subnets, routing)
- runtime (EKS or ECS patterns)
- data (RDS, ElastiCache)
- security (SGs, IAM boundaries)

Remote state/locking:
- Recommended: S3 backend + DynamoDB lock table.
See `docs/remote-state.md`.

Run:
```bash
terraform fmt -recursive
terraform init
terraform validate
```
