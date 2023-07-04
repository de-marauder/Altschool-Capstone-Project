[text link](https://www.collidu.com/media/catalog/product/img/8/9/8956d530a6048395848cd08f06a18451ad6a8e6c47a1769db264c2c2ec899358/finops-slide1.png)

![image alt text](https://www.collidu.com/media/catalog/product/img/8/9/8956d530a6048395848cd08f06a18451ad6a8e6c47a1769db264c2c2ec899358/finops-slide1.png)


# <h1> **Group 23** </h1>

## <h2> Finops Strategy/Documentation

## By Finops Team 23 </h2>


### <h3> *Overview* </h3>


The purpose of this document is to provide guidelines and procedures for managing financial operations within the Capstone (Startup Company) Project. FinOps aims to optimize cloud costs, increase cost transparency, and align financial and operational goals. This document outlines the key principles, roles and responsibilities, processes, and tools involved in achieving this project, with correct weekly, monthly and yearly estimates of all the technologies that will be used on the cloud provider of choice (Amazon Web Services, AWS)

*Reasons for choosing AWS:*

1. Broad Service Portfolio
2. Scalability and Flexibility
3. Security and Compliance
4. Global Infrastructure
5. Cost-Effectiveness
6. Continuous Innovation

#### <h3> **Key Principles for Cost Effectiveness:**</h3>

1. Cost Accountability: The team is responsible for managing and optimizing their own cloud costs.

2. Cost Transparency: Accurate and accessible cost information is provided to relevant stakeholders.

3. Continuous Optimization: Regularly monitor and optimize cloud resources to achieve cost-efficiency.

4. Collaboration: Foster collaboration between finance, operations, and engineering teams to achieve financial goals.



### <h3> **Technologies and Services** </h3>
1. *Terraform*: Terraform is an open-source infrastructure as code tool that enables you to safely and predictably provision and manage infrastructure in any cloud or on-premises.

2. *Ansible*: Ansible is an open-source IT automation tool that can configure systems, deploy software, and orchestrate more advanced IT tasks such as continuous deployments or zero downtime rolling updates.

3. *Prometheus*: Prometheus is a free software application used for event monitoring and alerting. It records metrics in a time series database (allowing for high dimensionality) built using an HTTP pull model, with flexible queries and real-time alerting.

4. *Grafana*: Grafana is an open-source observability platform for visualizing metrics, logs, and traces collected from your applications. It’s a cloud-native solution for quickly assembling data dashboards that let you inspect and analyze your stack.

5. *Alert manager*: Alertmanager is an open-source alerting system that handles alerts sent by client applications such as the Prometheus server. It takes care of deduplicating, grouping, and routing them to the correct receiver integration such as email, PagerDuty, or OpsGenie. It also takes care of silencing and inhibiting alerts.


### <h3> **Roles and Responsibilities** </h3>

***CICD Team***: Responsible for DevSecOps strategy

***Infrastructure engineers***: Responsible for designing the core infrastructure. The team will create the terraform configuration.


***FinOps team***: Ensure cost savings from everything everyone else is implementing


***Configuration management***: Responsible for Configuration management.


***SREs***: Responsible for the Site Reliability strategy of the infrastructure




### <h3> **Cost Savings Plan** </h3>

1. There will be 5 servers. For initial operation, t2.micro servers will be used all around except for the monitoring server which will use a t2.medium.

2. An Elastic IP for application and database (should have negligible cost. Only charged for when not attached to a server).


### <h3> **Estimates** </h3>
Weekly Estimates
This will give an overview of what cost will look like over the expense of a week, that is 7 days

### <h3> **Monthly Estimates** </h3>
This will give us a full insight of what cost will look like over the expense of four weeks, that is 28 days

### <h3> **Yearly Estimates** </h3>
This will give us an estimate of what costs look like over a year of using the cloud services, that is 365 days. Thereby giving us a comprehensive study of the financial operations of this capstone startup company.



### <h3> **Detailed Estimates Table** </h3>


| Tools | No | Weekly | Monthly | Yearly | Total |
| --- | --- | --- | --- | --- | --- |
| t2micro | 4 | 1.95 USD | 8.35 USD | 100.22 USD | 400.90 USD |
| t2 medium | 1 | 7.80 USD | 33.41 USD | 400.92 USD | 400.92 USD |
| s3 Bucket | 1 | 0.48 USD | 2.07 USD | 24.84 USD | 24.84 USD |
| Elastic Load Balancer | 1 | 3.83 USD | 16.43 USD | 197.16 USD | 197.16 USD |


For Futher detailed explanation you can check out AWS billing calculator [here](https://calculator.aws/#/)

### <h3> **Conclusion** </h3>
This FinOps documentation provides a framework for managing financial operations within the Capstone (Startup Company) Project. By implementing these guidelines, we aim to optimize cloud costs, improve cost transparency, and align financial and operational objectives. Continuous monitoring, analysis, and optimization will enable us to achieve cost-efficiency while ensuring maximum value from our cloud investments.