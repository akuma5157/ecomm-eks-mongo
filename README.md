[[_TOC_]]

### Problem Statement
a customer working in the E-commerce platform who wants to host his Web-based application which connects with MongoDB ~~and ElasticSearch (You can implement any one of these)~~. He wants his Environment to be completely scalable and Highly Available and database to be clustered. He also wants you to give him a DR strategy.

He is open to the use of different flavors of Linux with appropriate reasoning.

He wants to stay cloud-agnostic and hence all the installations should be one click using a Configuration Management Tool (preference to Ansible).

Points for help: You have to use ~~AWS Cloudformation~~ Terraform for cloud services provisioning

 Create the whole Infrastructure including EKS, VPC, subnets, load balancers, etc.

 Keep in mind that **security** is very important.

 Create a CI server Jenkins(using Ansible). Create the CICD pipeline (Jenkins Groovy script) deploy code to Kubernetes using Helm charts.

 One-click deployment to any region would be great.

 The architecture design should be the core backbone or microservice.
Container orchestration tools:  AWS EKS.

### Architecture Diagram
![Architecture Diagram](img/arch-diagram.png "Architecture Diagram")

### Tech Stack
| Type | Tool |
| :--- | :--- |
| Cloud Provider | AWS |
| Provisioning | Terraform |
| Config. Mgmt. | Ansible |
| CI/CD | Jenkins |
| Container Orch. | EKS |
| App Deployments | Helm |