# Ansible roles

Roles are structured for idempotent configuration.

Example (local run):
```bash
ansible-playbook -i inventory.ini playbooks/site.yml --check
ansible-playbook -i inventory.ini playbooks/site.yml
```

`--check` demonstrates idempotency (no changes on second run).
