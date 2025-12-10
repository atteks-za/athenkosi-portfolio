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
  <img width="1047" height="589" alt="image" src="https://github.com/user-attachments/assets/06829d3a-847a-4c16-bf49-d29c24fb5598" />


- **ECS Task Definition & Running Service:**  
  <img width="1038" height="584" alt="image" src="https://github.com/user-attachments/assets/093b2b48-de84-44d9-b69a-0023339d358e" />
  <img width="1033" height="581" alt="image" src="https://github.com/user-attachments/assets/11f3a401-0710-4a14-b665-fadb3273cd10" />



- **Security Group rules allowing ECS → RDS on port 5432:**  
  <img width="1031" height="580" alt="image" src="https://github.com/user-attachments/assets/40d7c23d-0d27-49a5-b99b-9c680b542d87" />


- **Metabase successful connection to the database:**  
  <img width="1060" height="596" alt="image" src="https://github.com/user-attachments/assets/e875ca87-35bd-4fa5-a0b3-ebe122197330" />


