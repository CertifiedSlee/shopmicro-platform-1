# Backup/Restore: PostgreSQL

## Local compose backup
```bash
docker compose ps
docker exec -t <postgres_container> pg_dump -U postgres shopmicro > backup.sql
```

## Kubernetes backup
```bash
kubectl -n shopmicro exec -it deploy/postgres -- pg_dump -U postgres shopmicro > backup.sql
```

## Restore
Local:
```bash
cat backup.sql | docker exec -i <postgres_container> psql -U postgres shopmicro
```

K8s:
```bash
cat backup.sql | kubectl -n shopmicro exec -i deploy/postgres -- psql -U postgres shopmicro
```
