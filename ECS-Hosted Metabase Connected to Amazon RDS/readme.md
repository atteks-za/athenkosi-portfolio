## **Project: ECS-Hosted Metabase Connected to Amazon RDS**

**Summary:**  
Launched Metabase on ECS Fargate and connected it to a PostgreSQL RDS instance within the same VPC. Configured secure security group rules to allow traffic only from the ECS tasks to RDS on port 5432, using environment variables to store database connection settings.

**Key Skills:**  
- ECS Fargate  
- RDS PostgreSQL  
- Environment Variables  
- Secure App-to-DB Communication  

**Screenshots:**  
- **RDS PostgreSQL Instance:**  
  ![RDS Instance](images/week6_rds_postgres.png)

- **ECS Task Definition & Running Service:**  
  ![ECS Task & Service](images/week6_ecs_task_service.png)

- **Security Group rules allowing ECS → RDS on port 5432:**  
  ![SG 5432](images/week6_sg_5432.png)

- **Metabase successful connection to the database:**  
  ![Metabase Connection](images/week6_metabase_connection.png)
