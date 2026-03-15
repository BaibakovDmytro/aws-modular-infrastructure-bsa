# Modular AWS Infrastructure with BSA Architecture

This project demonstrates a production-grade Infrastructure as Code (IaC) pattern using **Terraform**. It implements the **BSA (Base-Services-App)** modular framework to ensure logical separation, security, and cost-efficiency.

## 🛠 Architecture Overview (BSA)

The infrastructure is decoupled into three independent layers to minimize the **blast radius**:

1. **BASE Layer**: Foundation & Security.
   * **Security Groups**: Strict IP-whitelisting for administrative access.
   * **IAM Roles**: Least Privilege Principle implementation for EC2, Lambda, and SNS.

2. **SERVICES Layer**: Data Persistence & Messaging.
   * **Amazon S3**: Private bucket with versioning and full Public Access Block.
   * **DynamoDB**: NoSQL storage using `PAY_PER_REQUEST` billing.
   * **SNS (Simple Notification Service)**: Centralized alerting hub with automated access policies for system-wide notifications.

3. **APP Layer**: Compute & Logic.
   * **AWS Lambda**: Serverless data processing implemented in **Python 3.12** with automated CloudWatch integration.
   * **EC2 Instance**: Automated environment setup via UserData (AWS CLI, Boto3).
   * **CloudWatch Alarms**: Proactive monitoring of resource health and processing logic.

## 📊 Monitoring & Alerts
The system includes a built-in monitoring framework:
* **Automated Notifications**: Critical system events are pushed to an SNS topic.
* **Service Interoperability**: Advanced SNS policies allow CloudWatch to publish alerts while maintaining high security.
* **Real-time Logging**: All compute resources (Lambda/EC2) are integrated with CloudWatch Logs for audit trails.

## 📋 Tech Stack & Requirements

* **Terraform**: v1.0+
* **AWS Provider**: v5.0+
* **Cloud**: Amazon Web Services (US-East-1)

## ⚠️ Known Limitations & Assumptions

* **State Management**: Currently uses `local` backend for simplicity. For production environments, a remote backend (S3 + DynamoDB locking) is recommended.
* **Network**: Deployed in the Default VPC. Production workloads should consider a Custom VPC with Private Subnets.
* **SSH Access**: Restricted to a single admin IP.

## 🚀 Deployment Sequence

1. `cd base && terraform init && terraform apply`
2. `cd ../services && terraform init && terraform apply`
3. `cd ../app && terraform init && terraform apply`

---

**Maintained by:** Baibakov Dmytro  
**Project:** QLR-Score Infrastructure Proof of Concept