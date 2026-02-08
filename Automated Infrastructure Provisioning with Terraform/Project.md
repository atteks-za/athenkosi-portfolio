


---


**Automated Infrastructure Provisioning on AWS using Terraform**

---

## Introduction

This project demonstrates the use of **Terraform** to automate the provisioning of AWS infrastructure. Instead of manually creating cloud resources, Infrastructure as Code (IaC) is used to define, deploy, and manage infrastructure in a consistent and repeatable way.

---

## Project Objectives

* Automate AWS infrastructure deployment using Terraform
* Create a custom VPC and networking components
* Provision an EC2 instance automatically
* Apply Infrastructure as Code best practices
* Improve consistency and reduce configuration errors

---

## Tools & Technologies

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

## Architecture Overview

The infrastructure consists of:

* A custom **VPC**
* A **public subnet**
* An **Internet Gateway**
* A **Route Table**
* A **Security Group** allowing SSH access
* An **EC2 instance** deployed inside the subnet

All resources are provisioned and managed using Terraform configuration files.

---

## Terraform Configuration Files

The project uses the following Terraform files:

* `provider.tf` – AWS provider configuration
* `variables.tf` – Input variables
* `outputs.tf` – Output values
* `instance.tf` – Defines compute resources (EC2 instances).
* `vars.tf` – Declares input variables used across the config.
* `vpc.tf` – Defines VPC and networking resources.


---

## 8. Terraform Workflow

### Step 1: Initialize Terraform

```bash
terraform init
```

<img width="960" height="504" alt="init" src="https://github.com/user-attachments/assets/9dbe0ed5-9e67-470e-8e03-8f733cfe1483" />


---

### Step 2: Plan Infrastructure

```bash
terraform plan
```

<img width="960" height="504" alt="plan" src="https://github.com/user-attachments/assets/6c718b7f-4c12-4172-b276-81c2f7d67c9d" />


---

### Step 3: Apply Configuration

```bash
terraform apply
```

<img width="960" height="504" alt="terraform apply resources" src="https://github.com/user-attachments/assets/54106928-1481-497b-ba6f-0498e2c414ac" />



---

## 9. AWS Resources Verification

### VPC Creation

<img width="960" height="504" alt="vpc" src="https://github.com/user-attachments/assets/39f5ab90-3d92-4e8c-9579-e9a39ddd958c" />




<img width="1920" height="1008" alt="Screenshot 2026-02-03 222637" src="https://github.com/user-attachments/assets/4909686d-5f58-4174-b57b-d93371003d59" />


---

### EC2 Instance

<img width="960" height="504" alt="instance" src="https://github.com/user-attachments/assets/f06f7b45-01f8-4401-a64f-90afb099b2cd" />


---

### Security Group

<img width="960" height="504" alt="sg" src="https://github.com/user-attachments/assets/02938ac0-ed18-4c0a-9868-7314d4945442" />

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

