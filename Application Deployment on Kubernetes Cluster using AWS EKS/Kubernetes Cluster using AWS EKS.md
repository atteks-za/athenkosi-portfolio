
---

## 1. Project Overview
This project demonstrates the end-to-end deployment of a containerized application on a Kubernetes cluster managed by **AWS Elastic Kubernetes Service (EKS)**.

An **EC2 instance** serves as the management node, responsible for:  

- Building and testing Docker images  
- Pushing Docker images to Docker Hub  
- Managing Kubernetes deployments and services  

The application is exposed to the Internet via an **AWS Load Balancer**, ensuring high availability and public accessibility.

This workflow simulates a production-ready **DevOps pipeline**, providing hands-on experience with:  

- Cloud-native deployment  
- Containerization  
- Orchestration with Kubernetes  

---

## 2. Project Objectives
The objectives of this project are to:  

1. Containerize a web application using Docker  
2. Push the Docker image to **Docker Hub** for version control  
3. Create a scalable **Kubernetes cluster** using AWS EKS  
4. Deploy the application using a **Kubernetes Deployment**  
5. Expose the application using **Kubernetes Service (LoadBalancer)**  
6. Demonstrate cloud-native deployment workflows using **EC2, AWS CLI, and kubectl**  
7. Document and visualize the architecture for better understanding  

---

## 3. Tools & Technologies

| **Category**          | **Tools / Services**                  |
|-----------------------|--------------------------------------|
| Cloud                 | AWS (EKS, EC2, Load Balancer)        |
| Containerization      | Docker, Docker Hub                    |
| Orchestration         | Kubernetes, kubectl, eksctl           |
| DevOps & Management   | AWS CLI, Bash scripting               |
| OS / Environment      | Amazon Linux 2 EC2 Instance           |
| Visualization         | Mermaid diagrams / Infographic images |

---

## 4. Challenges & Solutions

| **Challenge**                   | **Solution**                                                  |
|---------------------------------|---------------------------------------------------------------|
| EKS cluster authentication issues | Configured **aws-auth ConfigMap** for EC2 node IAM roles      |
| Docker image pull failures       | Verified image name and tags; ensured public Docker Hub access |
| Load Balancer delay in provisioning | Waited for AWS to fully provision LB; monitored with **kubectl get svc** |

---

## 5. Screenshots
The screenshots below illustrate the deployment workflow and infrastructure setup:  

- **Internet Access:** Confirming public availability  
- **AWS Load Balancer:** Active and routing traffic  
- **Kubernetes Service & Pods:** Application components running successfully  
- **EKS Cluster & Worker Nodes:** Nodes registered and active  
- **EC2 Management Instance:** Command-line operations for Docker and kubectl  
- **Docker Hub:** Uploaded and versioned Docker images  

*Insert screenshots here*

---

## 6. Architecture Diagram
*Insert architecture diagram here showing EC2 instance, Docker workflow, EKS cluster, pods, and Load Balancer.*

