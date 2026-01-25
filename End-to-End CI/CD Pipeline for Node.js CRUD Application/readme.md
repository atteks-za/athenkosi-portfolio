# 🚀 End-to-End CI/CD Pipeline for Node.js CRUD Application

## 📌 Project Overview
This project demonstrates a **fully automated end-to-end CI/CD pipeline** for a Node.js CRUD application using modern DevOps tools and best practices.

The goal of this project was to understand how real-world DevOps automation works from code commit to production deployment  with **quality checks, containerization, and cloud deployment**.

Every code push triggers an automated pipeline that builds, tests, analyzes, packages, and deploys the application without manual intervention.

---

## 🛠️ Tech Stack & Tools
- **Application:** Node.js (CRUD REST API)
- **Version Control:** GitHub
- **CI/CD:** Jenkins
- **Code Quality:** SonarQube
- **Containerization:** Docker
- **Container Registry:** Docker Hub
- **Cloud Platform:** AWS EC2
- **OS:** Linux (Ubuntu)

---

## 🔄 CI/CD Pipeline Workflow

1. Developer pushes code to **GitHub**
2. **GitHub Webhook** automatically triggers Jenkins
3. Jenkins:
   - Pulls the latest code
   - Installs dependencies
   - Builds and tests the Node.js app
4. **SonarQube** analysis runs:
   - Code quality
   - Security vulnerabilities
   - Code smells
5. **Quality Gate** enforcement:
   - Pipeline stops if quality gate fails
6. Docker:
   - Builds application image
   - Pushes image to Docker registry
7. Deployment:
   - Jenkins deploys the latest Docker container to **AWS EC2**

🎯 **Result:**  
A Node.js CRUD application running inside Docker on EC2, deployed automatically on every successful commit.

---

## 🧱 Architecture Diagram
*<img width="940" height="1309" alt="image" src="https://github.com/user-attachments/assets/d6a8e9c2-73c9-4ba1-a80c-879aebbfb662" />*

