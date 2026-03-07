# Modular AWS Infrastructure with BSA Architecture

This project demonstrates a production-grade Infrastructure as Code (IaC) pattern using **Terraform**. It implements the **BSA (Base-Services-App)** modular framework to ensure logical separation, security, and cost-efficiency.

## 🛠 Architecture Overview (BSA)

The infrastructure is decoupled into three independent layers to minimize the **blast radius**:

1. **BASE Layer**: Foundation & Security.
   * **Security Groups**: Strict IP-whitelisting for administrative access.
   * **IAM Roles**: Least Privilege Principle implementation for EC2 access to S3/DynamoDB.

2. **SERVICES Layer**: Data Persistence.
   * **Amazon S3**: Private bucket with versioning enabled and full Public Access Block.
   * **DynamoDB**: NoSQL storage using `PAY_PER_REQUEST` billing to minimize idle costs.

3. **APP Layer**: Compute & Logic.
   * **EC2 Instance**: Automated environment setup via UserData (AWS CLI, Boto3).
   * **Key Management**: Automated RSA Key Pair generation with secure local permissions (0400).

## 📋 Tech Stack & Requirements

* **Terraform**: v1.0+
* **AWS Provider**: v5.0+
* **Cloud**: Amazon Web Services (US-East-1)

## ⚠️ Known Limitations & Assumptions

* **State Management**: Currently uses `local` backend for simplicity. For production environments, a remote backend (S3 + DynamoDB locking) is recommended.
* **Network**: Deployed in the Default VPC. Production workloads should consider a Custom VPC with Private Subnets.
* **SSH Access**: Restricted to a single admin IP — not suitable for team environments without modification.

## 🚀 Deployment Sequence

1. `cd base && terraform init && terraform apply`
2. `cd ../services && terraform init && terraform apply`
3. `cd ../app && terraform init && terraform apply`

---

**Maintained by:** Baibakov Dmytro  
**Project:** QLR-Score Infrastructure Proof of Concept