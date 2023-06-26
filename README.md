# Altschool Capstone Project
## Group 23

<img src='./assets/architecture-diagram.png' alt='Architectural diagram'>

# Configuration Management

Configuration is handled using ansible. Config files can be found [here](./ansible).

For initial setup, an ansible role is used to setup monitoring on all servers.

```bash
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags server --limit 'monitoring-server' --private-key <path-to-private-key-file>
```

```bash
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags monitor --limit 'monitoring-server' --private-key <path-to-private-key-file>
```

```bash
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags db,agent --limit 'db-server' --private-key <path-to-private-key-file>
```

```bash
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/ --tags app,agent --limit 'app-server' --private-key <path-to-private-key-file>
```


##CI/CD Documentation

### Build.yml file
This file contains information for building the the Docker Image and Pushes it to the Docker repository on every push to the main branch. 

The yml file runs the job called "docker-build-push"
- It checks out the codebase for recent changes
- Sets up Docker build to build the Docker Image
- Logs into Dockerhub using the Docker Username and Password that have been set as Environment Secrets
- Builds the image, tags it and pushes it to DockerHub


### Terraform.yml file
This files contains information for running the AWS infrastructure on every push to  the infrastructure branch. It has read and write permissions.

The yml file runs the "Terraform CI-CD" job
- It checks out the codebase for recent changes
- Configures the AWS credentials using the AWS Access Key, AWS Secret Address key and AWS region that have been set as environment variables for GitHub Actions Secrets.
- It then sets up Terraform with the version indicated, installs it and Initialiazing it with the AWS Credentials set in the Github Actions Secrets using the BAsh Shell.
- Still using the AWS Credentials, it sets up the Terraform plan, which previews the actions Terraform would take to modify the infrastructure and save it to be applied later
- Terraform Show uses the AWS Credentials to gain access and show the Terraform plan in a human readable form.
- Terraform Apply as the name implies, uses the AWS Credentials set to Apply the Terraform Plan

