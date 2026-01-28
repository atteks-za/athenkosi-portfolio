# Kubernetes Monitoring with Prometheus and Grafana

## Introduction 

This project demonstrates **Kubernetes monitoring using Prometheus and Grafana** on an **Amazon EKS cluster**. The goal is to provide visibility into cluster health, workloads, and resource usage using open-source, cloud-native tooling.

The project is designed as a **hands-on, end-to-end observability setup**, suitable for learning, demos, or as a foundation for production environments.

---

## Architecture Overview

* **Kubernetes**: Amazon EKS cluster
* **Monitoring**: Prometheus (via kube-prometheus-stack)
* **Visualization**: Grafana
* **Deployment Method**: Helm
* **Container Images**: Public container registry (Docker Hub / OCI-compatible registry)

---

## Infrastructure Setup 

### Prerequisites

* AWS account with EKS permissions
* kubectl configured to access the EKS cluster
* Helm v3 installed
* IAM role/user with sufficient permissions

### Steps

1. Create an EKS cluster (using eksctl or AWS Console)
2. Configure kubeconfig:

   ```bash
   aws eks update-kubeconfig --region <region> --name <cluster-name>
   ```
3. Verify cluster access:

   ```bash
   kubectl get nodes
   ```

---

## Installing and Configuring Tools 

### Install kubectl

```bash
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

### Install Helm

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### Add Prometheus Helm Repository

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

---

## Deploying the Helm Chart 

### Install kube-prometheus-stack

```bash
helm install learn-prom prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

### Verify Deployment

```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
```

This deploys:

* Prometheus
* Alertmanager
* Grafana
* Node Exporter
* kube-state-metrics

---

## Accessing and Exploring Grafana 

### Access Grafana

Since Grafana is exposed as a **ClusterIP** service, use port-forwarding:

```bash
kubectl port-forward -n monitoring svc/learn-prom-grafana 3000:80
```

Access Grafana in your browser:

```
http://localhost:3000
```

### Default Credentials

* **Username:** admin
* **Password:**

```bash
kubectl get secret -n monitoring learn-prom-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode
```

### Explore Dashboards

* Kubernetes / Compute Resources
* Node Metrics
* Pod & Namespace Monitoring
* API Server Metrics

---

## Project Structure

```
.
├── README.md
├── PROJECT.md
└── diagrams/
    └── eks-prometheus-grafana-architecture.png
```

---

## Key Learnings

* How Prometheus collects Kubernetes metrics
* Using Helm to manage complex Kubernetes deployments
* Visualizing cluster health with Grafana dashboards
* Understanding Kubernetes observability fundamentals

---

## Cleanup

```bash
helm uninstall learn-prom -n monitoring
kubectl delete namespace monitoring
```

---

## References

* [https://github.com/prometheus-operator/kube-prometheus](https://github.com/prometheus-operator/kube-prometheus)
* [https://grafana.com](https://grafana.com)
* [https://prometheus.io](https://prometheus.io)
