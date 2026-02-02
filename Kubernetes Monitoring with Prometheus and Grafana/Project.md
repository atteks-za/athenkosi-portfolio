

---

# Project Document

## Project Title

**Kubernetes Monitoring with Prometheus and Grafana on Amazon EKS**

---

## Project Overview

This project focuses on designing and implementing a **Kubernetes observability and monitoring solution** using **Prometheus** and **Grafana** deployed on an **Amazon EKS (Elastic Kubernetes Service)** cluster.

The objective is to gain real-time visibility into Kubernetes cluster performance, resource utilization, and application health using industry-standard, cloud-native tools.

---

## Problem Statement

Kubernetes clusters are complex and dynamic, making it difficult to monitor:

* Node and pod resource usage
* Application availability and performance
* Cluster health and failures

Without proper monitoring, identifying bottlenecks, failures, or scaling issues becomes challenging.

---

## Solution

To address these challenges, this project implements:

* **Prometheus** for metrics collection and storage
* **Grafana** for visualization and dashboards
* **kube-prometheus-stack** for simplified deployment and management
* **Helm** for package management

<img width="960" height="507" alt="helm repo" src="https://github.com/user-attachments/assets/4b0a86b5-6e6e-4b3d-a25b-33891211401b" />

---

## Technology Stack

| Component  | Description                     |
| ---------- | ------------------------------- |
| Amazon EKS | Managed Kubernetes service      |
| Kubernetes | Container orchestration         |
| Prometheus | Metrics collection & monitoring |
| Grafana    | Metrics visualization           |
| Helm       | Kubernetes package manager      |
| kubectl    | Kubernetes CLI                  |

---

## Architecture Description

1. Kubernetes workloads run on EC2-backed worker nodes
2. The Kubernetes API Server exposes cluster metrics
3. Prometheus scrapes metrics from nodes, pods, and the API server
4. Grafana queries Prometheus for metrics
5. Dashboards visualize real-time cluster performance

<img width="949" height="509" alt="api server" src="https://github.com/user-attachments/assets/cfec7f3f-d3c5-4a6e-977b-e0d2cb8a7a67" />

---

## Implementation Workflow

### 1. Infrastructure Setup

* Provision Amazon EKS cluster
* Verify worker nodes and namespaces

<img width="958" height="508" alt="worker node 1and2" src="https://github.com/user-attachments/assets/a170afbc-4f85-46aa-bcbd-5e301a110811" />
<img width="963" height="512" alt="nodes" src="https://github.com/user-attachments/assets/1ad923fb-9483-4c4e-aae9-466c569c3fa4" />
<img width="958" height="508" alt="worker node 1and2" src="https://github.com/user-attachments/assets/b7e6cfc3-9751-42c9-be64-dd836f6056f3" />

---

### 2. Kubernetes Resources & Workloads

* Deploy application and monitoring workloads
* Verify running pods

<img width="960" height="490" alt="pods" src="https://github.com/user-attachments/assets/69e970d0-e83e-4147-8288-5117c28ce1cd" />

---

### 3. Monitoring Stack Deployment with Helm

* Add Prometheus Helm repository
* Deploy kube-prometheus-stack

<img width="960" height="507" alt="helm repo" src="https://github.com/user-attachments/assets/171ddb50-9e19-4774-acb6-b670dda3ec79" />

---

### 4. Grafana Access & Configuration

* Expose Grafana using AWS Load Balancer (ELB)
* Log in using admin credentials

<img width="962" height="509" alt="grafana elb" src="https://github.com/user-attachments/assets/87543155-fdcf-404b-8d2b-40a388f48ae6" />
<img width="962" height="504" alt="grafana admin cred" src="https://github.com/user-attachments/assets/c6fca34a-377b-410d-b197-e1e3050ef135" />

---

### 5. Monitoring & Visualization

* Explore preconfigured Kubernetes dashboards
* Monitor node, pod, and namespace metrics

<img width="960" height="504" alt="grafana dashboard" src="https://github.com/user-attachments/assets/5bfb3f61-3cab-4f35-8f91-89dc554ea86d" />
<img width="957" height="509" alt="stress workload grafana metrics" src="https://github.com/user-attachments/assets/f52adc46-f5e2-4dd6-8882-4e4b6d9e022a" />

---

### 6. Stress Testing & Metrics Validation

* Run stress workloads on Kubernetes and EC2
* Observe real-time metric changes in Grafana

<img width="956" height="504" alt="ec2 stress" src="https://github.com/user-attachments/assets/036bdef3-4727-45ba-96d0-3af4166b0bc1" />
<img width="957" height="509" alt="stress workload grafana metrics" src="https://github.com/user-attachments/assets/735d3091-d5b5-4484-b049-4297ec30f169" />

---

## Key Features

* Cluster-level monitoring
* Node, pod, and namespace metrics
* Real-time stress test visualization
* Preconfigured Grafana dashboards
* Scalable Helm-based deployment

---

## Outcomes and Learnings

* Hands-on Kubernetes monitoring experience
* Understanding Prometheus metric scraping
* Grafana dashboard analysis under load
* Real-world EKS observability workflow

<img width="956" height="507" alt="k8s dashboard" src="https://github.com/user-attachments/assets/7a1f0ad1-75d8-43e1-be91-afa7d273665b" />

---

## Limitations

* Prometheus uses ephemeral storage
* Grafana exposed via ELB (not production-hardened)
* Alerting rules not customized

---

## Future Enhancements

* Enable persistent storage for Prometheus
* Secure Grafana with Ingress and authentication
* Add custom application metrics
* Configure Alertmanager notifications
* Integrate long-term storage (Thanos)

---

## Conclusion

This project demonstrates a complete Kubernetes monitoring solution on Amazon EKS using Prometheus and Grafana. It showcases real-world observability, performance testing, and dashboard-driven insights suitable for production learning and DevOps portfolios.

---
