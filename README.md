# Overview
This project is a containerized Python web application designed to facilitate human-in-the-loop data validation. The application ingests raw data from a DynamoDB table and presents it in an editable web interface, allowing users to manually review and correct any errors before the cleaned data is persisted to both an RDS relational database and a DynamoDB table. The container image is stored and managed in Amazon ECR, enabling consistent and reproducible deployments across environments.
# Architecture
The networking environment is provisioned entirely from scratch using a custom VPC, designed with both public and private subnets, internet gateways, and routing tables to ensure proper network segmentation and controlled traffic flow. The application integrates multiple data stores, leveraging DynamoDB for raw data ingestion and RDS for structured relational storage of the validated output, demonstrating a full-stack approach to cloud architecture that spans containerization, networking, and both relational and non-relational databases.
# Security
Network-level security is enforced through granular security groups configured following the principle of least privilege. Each component of the architecture is restricted to only accept traffic from explicitly authorized sources, ensuring that no service is exposed beyond its intended scope and that the overall application maintains a strong and deliberate security boundary throughout.
# Containerization & Scaling - WIP
Conatainerize application. 
Storing container images in ECR. 
Deploying the app via ECS.
# CI/CD - WIP
Implement CI/CD via GitHub Actions for developing additional features.
# System Diagram - EC2 Implementation
![EC2 Architecture](documentation/system-diagram-ec2.png)
# System Diagram - ECS Implementation
![ECS Architecture](documentation/system-diagram-ecs.png)