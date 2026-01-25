## 🏁 Summary

I successfully accomplished an **end-to-end CI/CD pipeline** for a Node.js CRUD application, automating the complete journey from code commit to production deployment. This project reflects real-world DevOps practices, integrating CI, quality gates, containerization, and cloud deployment into a single automated workflow.

---

## 🚀 What I Built

* Configured **GitHub webhooks** to trigger Jenkins automatically on every code push
* Designed and implemented a **Jenkins CI/CD pipeline**
* Integrated **SonarQube** for code quality, security checks, and quality gate enforcement
* Containerized the application using **Docker**
* Pushed Docker images to a **Docker registry**
* Deployed the application to **AWS EC2** as a Docker container
* Achieved **zero manual intervention** from commit to deployment

---

## 🔄 End-to-End Flow (What Happens on Every Commit)

1. Code is pushed to GitHub
2. GitHub webhook triggers Jenkins
3. Jenkins pulls the latest code
4. Application is built and tested
5. SonarQube analyzes code quality
6. Quality gate validates the build
7. Docker image is built and pushed
8. Latest container is deployed to AWS EC2

---

## 📸 Evidence & Screenshots

### 1️⃣ GitHub Webhook Trigger


<img width="1920" height="1031" alt="01-github-webhook" src="https://github.com/user-attachments/assets/e9d6787c-14e0-4840-b35a-767c9a825853" />




---

### 2️⃣ Jenkins CI/CD Pipeline Execution

<img width="1910" height="1080" alt="02-jenkins-pipeline" src="https://github.com/user-attachments/assets/33b832fc-e334-4cb7-86a5-648d1d3af40b" />


---

### 3️⃣ SonarQube Quality Gate – PASSED

<img width="1910" height="1080" alt="03-sonarqube-quality-gate (2)" src="https://github.com/user-attachments/assets/31c3b72e-de13-4890-b4e8-237bdf53e6e5" />



---

### 4️⃣ Docker Image Build & Push

<img width="1932" height="1080" alt="04-docker-build-push" src="https://github.com/user-attachments/assets/41283dd5-f5d2-4302-b858-9872ff9a2098" />


---

### 5️⃣ Application Running on AWS EC2

<img width="1920" height="1080" alt="05-ec2-running-app" src="https://github.com/user-attachments/assets/f0c80828-817a-48a2-8ad2-43e1f6ba0e1f" />


---

## 🎯 Key Outcomes

* Fully automated CI/CD pipeline
* Improved deployment reliability
* Enforced quality standards before production
* Faster release cycles
* Reduced human error

---

## 🧠 What I Learned

* How CI/CD pipelines work in real production environments
* Why quality gates are critical before deployment
* How Jenkins, SonarQube, Docker, and AWS integrate together
* How automation saves time and increases confidence in deployments

---

## 🏆 Conclusion

Completing this project gave me hands-on experience with real-world DevOps automation. It strengthened my understanding of CI/CD pipelines and demonstrated my ability to design, implement, and manage automated deployments in a cloud environment.

---
