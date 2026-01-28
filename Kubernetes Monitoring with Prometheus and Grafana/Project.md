# Project Document

## Project Title

Kubernetes Monitoring with Prometheus and Grafana on Amazon EKS

---

## Project Overview

This project focuses on designing and implementing a **Kubernetes observability and monitoring solution** using **Prometheus** and **Grafana** deployed on an **Amazon EKS (Elastic Kubernetes Service)** cluster.

The objective is to gain real-time visibility into Kubernetes cluster performance, resource utilization, and application health using industry-standard, cloud-native tools.

This project is suitable for **DevOps engineers, cloud engineers, and SRE learners** who want hands-on experience with Kubernetes monitoring.

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

The solution provides a centralized monitoring platform with prebuilt dashboards and alerting capabilities.

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

1. Applications and Kubernetes components expose metrics endpoints
2. Prometheus scrapes metrics from nodes, pods, and Kubernetes APIs
3. Metrics are stored in Prometheus TSDB
4. Grafana queries Prometheus as a data source
5. Dashboards visualize cluster and workload metrics

All components are deployed inside the Kubernetes cluster using Helm charts.

---

## Implementation Workflow

### 1. Introduction – Kubernetes Monitoring (4 min)

* Overview of Prometheus and Grafana
* Understanding Kubernetes observability

### 2. Infrastructure Setup (3 min)

* Provision Amazon EKS cluster
* Configure kubectl access

### 3. Installing and Configuring Tools (5 min)

* Install kubectl and Helm
* Add Prometheus Helm repository

### 4. Deploying Helm Chart (3 min)

* Deploy kube-prometheus-stack
* Verify running services and pods

### 5. Accessing and Exploring Grafana (3 min)

* Access Grafana via port-forwarding
* Explore Kubernetes dashboards

---

## Key Features

* Cluster-level monitoring
* Node, pod, and namespace metrics
* Preconfigured Grafana dashboards
* Scalable and extensible architecture
* Cloud-native and open-source

---

## Outcomes and Learnings

* Practical understanding of Kubernetes monitoring
* Experience deploying observability tools using Helm
* Hands-on experience with Amazon EKS
* Ability to interpret metrics and dashboards

---

## Limitations

* Prometheus uses local storage (not long-term by default)
* Grafana access via port-forwarding (not production-ready)
* Alerting rules not customized

---

## Future Enhancements

* Enable persistent storage for Prometheus
* Expose Grafana using Ingress or LoadBalancer
* Add custom application metrics
* Configure Alertmanager notifications (Slack / Email)
* Integrate long-term storage (Thanos or Cortex)

---

## Conclusion

This project demonstrates a complete Kubernetes monitoring setup using Prometheus and Grafana on Amazon EKS. It serves as a strong foundation for production-grade observability and a solid portfolio project for cloud and DevOps engineers.

---

## References

* [https://github.com/prometheus-operator/kube-prometheus](https://github.com/prometheus-operator/kube-prometheus)
* [https://prometheus.io](https://prometheus.io)
* [https://grafana.com](https://grafana.com)
