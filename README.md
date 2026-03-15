### Hexlet tests and linter status:
[![Actions Status](https://github.com/dobro10k2/devops-engineer-from-scratch-project-318/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/dobro10k2/devops-engineer-from-scratch-project-318/actions)

# Bulletin Board Observability Infrastructure

Infrastructure for the **Bulletin Board application** built as part of the **Hexlet DevOps Engineer from Scratch program**, providing containerized deployment and basic observability using Ansible, Docker, Node Exporter, and Spring Boot Actuator.

---

# Project Overview

This repository contains the **infrastructure code** used to deploy the application and prepare the host for observability.

The infrastructure is provisioned using **Ansible** and runs the application inside **Docker** containers.

The project implements:

* automated deployment using Ansible
* containerized application runtime
* object storage using **MinIO**
* PostgreSQL database container
* reverse proxy using **NGINX**
* HTTPS certificates issued by **Let’s Encrypt**
* host monitoring using **Prometheus Node Exporter**
* application metrics using **Spring Boot Actuator** and **Micrometer**

---

# Application URL

Application is accessible at:

```
https://board.dobro10k2.ru
```

---

# Repository Structure

```
.
├── Makefile
└── ansible
    ├── inventory.ini
    ├── playbook.yml
    ├── group_vars
    │   └── all
    │       ├── all.yml
    │       └── vault.yml
    └── roles
        ├── certbot
        ├── docker_deploy
        ├── docker_network
        ├── docker_setup
        ├── firewall
        ├── minio
        ├── nginx
        ├── postgres
        └── node_exporter
```

All infrastructure configuration files are located in the **ansible/** directory.

---

# Deployment Commands

Deployment is performed using the Makefile.

### Initial deployment

```
make ansible
```

### Deploy new application version

```
make deploy
```

### Rollback to specific image

```
make rollback TAG=<docker_tag>
```

The deployment uses a Docker image from **GitHub Container Registry**.

Example image:

```
ghcr.io/dobro10k2/project-devops-deploy:<git_sha>
```

---

# Infrastructure Components

The application server runs the following services:

```
VM
│
├── Nginx reverse proxy
├── Node Exporter
│
├── Docker
│   ├── application container
│   ├── PostgreSQL container
│   └── MinIO container
```

Ports used:

| Port     | Service                          |
| -------- | -------------------------------- |
| 80 / 443 | Nginx                            |
| 8080     | Application                      |
| 9090     | Application management / metrics |
| 9100     | Node Exporter                    |

---

# Metrics Endpoints

### Application metrics

```
http://localhost:9090/actuator/prometheus
```

### Health check

```
https://board.dobro10k2.ru/actuator/health
```

### Host metrics

```
http://localhost:9100/metrics
```

---

# Verification Commands

### Check host metrics

```
curl http://localhost:9100/metrics | head
```

### Check application metrics

```
curl http://localhost:9090/actuator/prometheus | head
```

### Check application health

```
curl https://board.dobro10k2.ru/actuator/health
```

Expected response:

```
{"status":"UP"}
```

---

# Required Metrics

The following metrics are exported and intended to be collected by Prometheus.

## Host Metrics

| Metric                           | Description              |
| -------------------------------- | ------------------------ |
| node_cpu_seconds_total           | CPU usage time           |
| node_load1                       | 1 minute system load     |
| node_memory_MemAvailable_bytes   | available memory         |
| node_filesystem_size_bytes       | filesystem capacity      |
| node_network_receive_bytes_total | incoming network traffic |

---

## Application Metrics

| Metric                             | Description              |
| ---------------------------------- | ------------------------ |
| application_started_time_seconds   | application startup time |
| process_uptime_seconds             | application uptime       |
| http_server_requests_seconds_count | HTTP request count       |
| jvm_memory_used_bytes              | JVM memory usage         |
| disk_free_bytes                    | free disk space          |

---

# Observability Setup

Host metrics are exported by **Prometheus Node Exporter**.

Application metrics are exported via **Spring Boot Actuator** using **Micrometer**.

These metrics can later be collected by **Prometheus** and visualized using **Grafana**.

---

# Prometheus URL:

```
https://prometheus.dobro10k2.ru
```

Check targets:

```
up == 1
```

---

## Grafana

Grafana is deployed on the monitoring server and visualizes metrics collected by Prometheus.

**URL**

```
https://grafana.dobro10k2.ru
```

**Login**

```
admin
```

Password is stored in Ansible Vault.

---

## Dashboards

Grafana dashboards are provisioned automatically during deployment.

Provisioning files are located in:

```
ansible/roles/monitoring/files/grafana/provisioning
```

Dashboards are stored in:

```
ansible/roles/monitoring/files/grafana/dashboards
```

To apply dashboard updates run:

```
make ansible
```

---

## Data Sources

Configured automatically via provisioning:

| Data source | Purpose                          |
| ----------- | -------------------------------- |
| Prometheus  | metrics collection               |
| Loki        | logs (prepared for future steps) |

---

## Dashboards Overview

The following dashboards are included:

| Dashboard           | Description                        |
| ------------------- | ---------------------------------- |
| System Resources    | CPU, memory, disk, network metrics |
| Application Metrics | JVM metrics, uptime, HTTP requests |
| HTTP Status Codes   | request counts and response codes  |

---
