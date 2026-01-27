# Application Deployment on Kubernetes Cluster using AWS EKS

## Project Overview
This project demonstrates the **end-to-end deployment of a containerized application** on a Kubernetes cluster managed by **AWS Elastic Kubernetes Service (EKS)**.

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

## Project Objectives
The objectives of this project are to:  
1. Containerize a web application using Docker  
2. Push the Docker image to **Docker Hub** for version control  
3. Create a scalable **Kubernetes cluster** using AWS EKS  
4. Deploy the application using a **Kubernetes Deployment**  
5. Expose the application using **Kubernetes Service (LoadBalancer)**  
6. Demonstrate cloud-native deployment workflows using **EC2, AWS CLI, and kubectl**  
7. Document and visualize the architecture for better understanding  

---

## Tools & Technologies

| **Category**          | **Tools / Services**                  |
|-----------------------|--------------------------------------|
| Cloud                 | AWS (EKS, EC2, Load Balancer)        |
| Containerization      | Docker, Docker Hub                    |
| Orchestration         | Kubernetes, kubectl, eksctl           |
| DevOps & Management   | AWS CLI, Bash scripting               |
| OS / Environment      | Amazon Linux 2 EC2 Instance           |
| Visualization         | Mermaid diagrams / Infographic images |

---

## Challenges & Solutions

| **Challenge**                   | **Solution**                                                  |
|---------------------------------|---------------------------------------------------------------|
| EKS cluster authentication issues | Configured **aws-auth ConfigMap** for EC2 node IAM roles      |
| Docker image pull failures       | Verified image name and tags; ensured public Docker Hub access |
| Load Balancer delay in provisioning | Waited for AWS to fully provision LB; monitored with **kubectl get svc** |


---

## Architecture Diagram
Below is the architecture of the deployment pipeline:
<img width="1536" height="1024" alt="ChatGPT Image Jan 27, 2026, 10_05_37 AM" src="https://github.com/user-attachments/assets/59280160-e61d-4611-976b-fc1b97d6e37a" />


---

## How to Run
1. Launch an **Amazon Linux 2 EC2 instance** with necessary IAM roles.  
2. Install Docker, Kubernetes tools (kubectl, eksctl), and AWS CLI.  
3. Build your Docker image and push to Docker Hub:  
   ```bash
   docker build -t <dockerhub-username>/<app-name>:<tag> .
   docker push <dockerhub-username>/<app-name>:<tag>
