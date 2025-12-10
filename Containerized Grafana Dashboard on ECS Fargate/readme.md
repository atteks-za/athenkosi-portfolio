## **Project: Containerized Grafana Dashboard on ECS Fargate**

**Summary:**  
Deployed Grafana using the official Docker image on ECS Fargate, exposed port 3000, configured security groups, and accessed the Grafana dashboard via a public endpoint.

**Key Skills:**  
- ECS Fargate  
- Docker  
- Security Groups  
- Cloud Monitoring  

**Screenshots:**  
- **Security Group showing inbound rule for port 3000:**  
  

- **ECS Cluster Dashboard:**  
  

- **Task Definition (grafana/grafana & port 3000 mapping):**  
  ![Task Definition](images/week5_task_definition.png
- **ECS Service running under Grafana cluster:**  
  ![ECS Service](images/week5_ecs_service.png)

- **Task details showing Public IP:**  
  ![Task Public IP](images/week5_task_public_ip.png)

- **Grafana Login Page:**  
  ![Grafana Login](images/week5_grafana_login.png)
