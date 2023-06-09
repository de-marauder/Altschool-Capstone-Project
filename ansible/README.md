### For monitoring servers with Prometheus and Grafana
### Deployed with ansible


Then run:
```bash
# Run this on the monitoring server
ansible-playbook playbooks/deploy_monitoring.yml  -i inventories/production/ --tags server --limit '<monitoring server>'
# Run this on all machines except for the monitoring server
ansible-playbook playbooks/deploy_monitoring.yml  -i inventories/production/ --tags agent --limit '<agent server group>:!<monitoring server>'
```