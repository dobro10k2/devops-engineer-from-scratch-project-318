### Hexlet tests and linter status:
[![Actions Status](https://github.com/dobro10k2/devops-engineer-from-scratch-project-318/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/dobro10k2/devops-engineer-from-scratch-project-318/actions)

# Bulletin Board Observability Infrastructure

Infrastructure for the **Bulletin Board application** built as part of the **Hexlet DevOps Engineer from Scratch program**, providing containerized deployment and full observability using Ansible, Docker, Prometheus, and Grafana.

---

# Project Overview

This repository contains the **infrastructure code** used to deploy the application and implement observability.

The infrastructure is provisioned using **Ansible** and runs the application inside **Docker** containers.

The project implements:

* automated deployment using Ansible
* containerized application runtime
* object storage using **MinIO**
* PostgreSQL database container
* reverse proxy using **NGINX**
* HTTPS certificates issued by **Let’s Encrypt**
* monitoring using **Prometheus**
* visualization and alerting using **Grafana**
* host monitoring using **Node Exporter**
* application metrics using **Spring Boot Actuator** and **Micrometer**

---

# Application URL

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
        ├── monitoring
        ├── nginx
        ├── postgres
        └── node_exporter
```

---

# Deployment Commands

### Initial deployment

```
make setup
```

### Deploy new application version

```
make deploy
```

### Rollback

```
make rollback TAG=<docker_tag>
```

---

# Infrastructure Components

```
VM
│
├── Nginx
├── Node Exporter
│
├── Docker
│   ├── Application
│   ├── PostgreSQL
│   ├── MinIO
│   ├── Prometheus
│   └── Grafana
```

---

# Metrics Endpoints

### Application metrics

```
http://localhost:9090/actuator/prometheus
```

### Host metrics

```
http://localhost:9100/metrics
```

---

# Prometheus

```
https://prometheus.dobro10k2.ru
```

Check targets:

```
up == 1
```

---

# Grafana

```
https://grafana.dobro10k2.ru
```

Login:

```
admin
```

Password stored in Vault.

---

# Dashboards

Dashboards are provisioned automatically:

```
ansible/roles/monitoring/files/grafana/dashboards
```

## Available dashboards

| Dashboard           | Description                         |
| ------------------- | ----------------------------------- |
| Status Page         | overall system health               |
| System Metrics      | CPU, memory, disk, network          |
| Application Metrics | RPS, latency, uptime                |
| HTTP Metrics        | request rates, status codes, errors |

---

# Status Page

Provides a quick overview:

* Application status (UP / DOWN)
* CPU usage
* Memory usage
* Disk usage
* 5xx errors

This dashboard directly reflects alert rules.

---

# Alerting

Alerting is configured via Grafana provisioning.

## Config location

```
ansible/roles/monitoring/files/grafana/provisioning/alerting
```

## Files

* rules.yml — alert rules
* policies.yml — routing
* contactpoints.yml — notification channels

---

# Notification Channel

Alerts are sent to **Telegram Bot API**.

Secrets are stored in Vault:

```
telegram_bot_token
telegram_chat_id
```

---

# Implemented Alerts

| Alert            | Description            |
| ---------------- | ---------------------- |
| Application Down | app is not responding  |
| High CPU         | CPU > 80%              |
| High Memory      | RAM > 80%              |
| Disk Almost Full | < 20% free space       |
| No Metrics       | metrics missing        |
| High 5xx         | server errors detected |

All alerts include:

* severity label
* service label

---

# How to View Alerts

Grafana → Alerting → Alert rules

---

# How to Trigger Alerts

### Application Down

```
docker stop <app_container>
```

---

### High CPU

```
yes > /dev/null
```

---

### 5xx Errors

```
curl https://board.dobro10k2.ru/invalid-endpoint
```

---

### No Metrics

Stop application or block metrics endpoint.

---

# Alerting Flow

```
Application / Node Exporter
        ↓
Prometheus
        ↓
Grafana Alerting
        ↓
Telegram
```

---

# Verification

1. Open Grafana
2. Trigger alert
3. Verify:

   * alert appears in Grafana
   * Telegram notification received
   * dashboard reflects issue

---

# Screenshots

### System Metrics

![System](assets/system-metrics.png)

### Application Metrics

![App](assets/application-metrics.png)

### HTTTP Metrics

![HTTP](assets/http-metrics.png)

### Status Page

![Status](assets/status-page.png)

### Prometheus Targets

![Targets](assets/prometheus-targets.png)

### Alert Fired

![Alert](assets/alert-fired.png)
![Alert](assets/alert-fired-telegram.png)

---

# Conclusion

The project implements a full observability stack:

* metrics collection (Prometheus)
* visualization (Grafana dashboards)
* alerting (Grafana Alerting + Telegram)

This setup allows detecting and reacting to:

* application failures
* resource exhaustion
* error spikes
* missing telemetry

---

# Notes

All sensitive data is stored in Ansible Vault.

Deployment is fully reproducible using Makefile commands.

