
---

# Automated Infrastructure Provisioning with Terraform

---

## 1. Project Title

**Automated Infrastructure Provisioning on AWS using Terraform**

---

## 2. Introduction

This project demonstrates the use of **Terraform** to automate the provisioning of AWS infrastructure. Instead of manually creating cloud resources, Infrastructure as Code (IaC) is used to define, deploy, and manage infrastructure in a consistent and repeatable way.

---

## 3. Project Objectives

* Automate AWS infrastructure deployment using Terraform
* Create a custom VPC and networking components
* Provision an EC2 instance automatically
* Apply Infrastructure as Code best practices
* Improve consistency and reduce configuration errors

---

## 4. Tools & Technologies

* Terraform
* Amazon Web Services (AWS)

  * VPC
  * EC2
  * Subnets
  * Internet Gateway
  * Security Groups
* Ubuntu Linux
* GitHub

---

## 5. Architecture Overview

The infrastructure consists of:

* A custom **VPC**
* A **public subnet**
* An **Internet Gateway**
* A **Route Table**
* A **Security Group** allowing SSH access
* An **EC2 instance** deployed inside the subnet

All resources are provisioned and managed using Terraform configuration files.

---

## 6. Terraform Configuration Files

The project uses the following Terraform files:

* `provider.tf` – AWS provider configuration
* `main.tf` – Core infrastructure resources
* `variables.tf` – Input variables
* `outputs.tf` – Output values

---

## 8. Terraform Workflow

### Step 1: Initialize Terraform

```bash
terraform init
```

📸 **Screenshot Placeholder:**

> *(Insert screenshot of `terraform init` output here)*

---

### Step 2: Plan Infrastructure

```bash
terraform plan
```

📸 **Screenshot Placeholder:**

> *(Insert screenshot of `terraform plan` showing resources to be created)*

---

### Step 3: Apply Configuration

```bash
terraform apply
```

📸 **Screenshot Placeholder:**

> *(Insert screenshot of `terraform apply` completion)*

---

## 9. AWS Resources Verification

### VPC Creation

📸 **Screenshot Placeholder:**

> *(Insert AWS Console screenshot showing created VPC)*

---

### Subnet & Internet Gateway

📸 **Screenshot Placeholder:**

> *(Insert AWS Console screenshot of subnet and internet gateway)*

---

### EC2 Instance

📸 **Screenshot Placeholder:**

> *(Insert AWS Console screenshot showing EC2 instance running)*

---

### Security Group

📸 **Screenshot Placeholder:**

> *(Insert AWS Console screenshot of security group rules)*

---

## 10. Security Considerations

* SSH access restricted via Security Group rules
* Only required ports are opened
* Infrastructure managed centrally through Terraform

---

## 11. Benefits of Using Terraform

* Automated and repeatable deployments
* Reduced manual configuration errors
* Version-controlled infrastructure
* Easy modification and cleanup

---

## 12. Conclusion

This project successfully demonstrates how Terraform can be used to automate AWS infrastructure provisioning. By using Infrastructure as Code, cloud environments can be deployed efficiently, consistently, and securely without relying on manual configuration.

---

