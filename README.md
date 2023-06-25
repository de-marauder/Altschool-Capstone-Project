# Altschool Capstone Project
## Group 23

<img src='./assets/architecture-diagram.png' alt='Architectural diagram'>

# Configuration Management

Configuration is handled using ansible. Config files can be found [here](./ansible).

For initial setup, an ansible role is used to setup monitoring on all servers.

```bash
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags server --limit 'monitoring-server' --private-key <path-to-private-key-file>
```
