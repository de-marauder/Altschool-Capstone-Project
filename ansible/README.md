### For monitoring servers with Prometheus and Grafana
### Deployed with ansible


Then run:
```bash
# Run this on the monitoring server
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags monitor --limit 'monitoring-server' 

# Run this on db server
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags db,agent --limit 'db-server' 

# Run this on app server
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags app,agent --limit 'application'

# Run this on all machines except for the monitoring server
# ansible-playbook playbooks/deploy_monitoring.yml  -i inventories/production/ --tags agent --limit '<agent server group>:!<monitoring server>'
# ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags agent --limit 'app-server' --private-key <path/to/keyfile>
```

## Other commands using tags to only run specific tasks
```bash
# Run nginx tasks on the monitoring server
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags nginx-monitor --limit 'monitoring-server'

# Transfer nginx config to monitor server
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags nginx-monitor-config --limit 'monitoring' 
# Restart nginx on monitor server
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags nginx-monitor-restart --limit 'monitoring' 
# Run nginx ssl cert tasks on monitor server
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags nginx-monitor-cert --limit 'monitoring'

# Run nginx tasks for app server
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags nginx-app --limit 'application' 

# Transfer nginx config to app server
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags nginx-app-config --limit 'application' 
# Restart nginx on app server
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags nginx-app-restart --limit 'application' 
# Run nginx ssl cert tasks on app server
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags nginx-app-cert --limit 'application'

# Run nginx tasks for db server
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags nginx-db --limit 'db-server' 

# Transfer nginx config to db server
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags nginx-db-config --limit 'db-server' 
# Restart nginx on db server
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags nginx-db-restart --limit 'db-server' 

# Restart Prometheus
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags prom --limit 'monitoring' 
# Restart alertmanager
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags alert --limit 'monitoring' 


```

bastion jump server command

```bash
ssh -o ProxyCommand='ssh -i <private-key>.pem -p <port> -W %h:%p ubuntu@<bastion-server>' -p <port> -i <private-key>.pem ubuntu@<private-server>
```