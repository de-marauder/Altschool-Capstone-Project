# Altschool Capstone Project
## Group 23

<img src='./assets/architecture-diagram.png' alt='Architectural diagram'>

This repo contains a full setup for managing an application. From the application code, to infrastructure managed by terraform and ansible. It also showcases how CICD can be implemented for fast delivery of code changes in the application and in terraform. 

Site reliability is monitored using grafana, prometheus, loki and alertmanager. Node agents such as node_exporter, blackbox, cadvisor and docker-metrics were used to expose server metrics, container metrics and application health metrics.

Security was taken seriously and SSL certs were generated for all http traffic. Also, the database is housed in a private subnet safe from the general internet.


# Configuration Management

All configuration is handled using ansible. From setting up the database and application to implementing monitoring. 

Config files can be found [here](./ansible).

## Procedure

Setup the database.
```bash
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/servers.yml --tags db,agent --limit 'db-server'
```

Setup the application on all application servers.
```bash
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/servers.yml --tags app,agent --limit 'application'
```

Setup monitoring server.
```bash
ansible-playbook playbook/deploy_monitoring.yml  -i inventories/production/servers.yml --tags monitor --limit 'monitoring-server'
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

