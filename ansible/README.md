### For monitoring servers with Prometheus and Grafana
### Deployed with ansible


Then run:
```bash
# Run this on the monitoring server
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags server --limit 'monitoring-server' --private-key <path/to/keyfile>

# Run this on db server
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags db,agent --limit 'db-server' --private-key webserver-1.pem

# Run this on app server
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags app,agent --limit 'app-server' --private-key webserver-1.pem

# Run this on all machines except for the monitoring server
# ansible-playbook playbooks/deploy_monitoring.yml  -i inventories/production/ --tags agent --limit '<agent server group>:!<monitoring server>'
# ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags agent --limit 'app-server' --private-key <path/to/keyfile>
```