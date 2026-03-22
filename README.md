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

## Nginx Monitoring

### stub_status

Nginx exposes metrics via the `stub_status` module:

```
http://10.129.0.16/nginx_status
```

Access is restricted:

* allowed: 10.129.0.25 (monitoring server)
* denied for others

---

### Verification

#### Check stub_status

```bash
curl http://10.129.0.16/nginx_status
```

Expected output:

```
Active connections: 1
Reading: 0 Writing: 1 Waiting: 0
```

---

#### Check nginx exporter

```bash
curl http://localhost:9113/metrics | grep nginx_
```

---

#### Check Prometheus

```
https://prometheus.dobro10k2.ru
```

Query:

```
nginx_connections_active
```

---

## Grafana

```
https://grafana.dobro10k2.ru
```

Dashboards:

* Nginx Metrics
* HTTP Metrics

---

## 5xx Monitoring

5xx errors are collected from application metrics (Spring Boot + Micrometer).

Nginx exporter does not provide HTTP status codes.

---

### Trigger 5xx errors

```bash
docker stop postgres
docker restart <app_container>
```

Then generate requests:

```bash
for i in {1..10}; do curl -s -o /dev/null https://board.dobro10k2.ru/api/bulletins; done
```

---

### Grafana query (avoid "No data")

```
increase(http_server_requests_seconds_count{status=~"5.."}[1d])
```

---

## Logs Monitoring (Loki + Promtail)

The project includes centralized log collection and analysis using **Loki** and **Promtail**.

### Architecture

```
Application / Nginx logs
        ↓
Promtail
        ↓
Loki
        ↓
Grafana (Explore + Dashboards + Alerts)
```

---

## Log Sources

### Nginx logs

```
/var/log/nginx/access.log
/var/log/nginx/error.log
```

### Application logs

Collected from Docker containers via Promtail.

---

## Promtail

Promtail is installed via Ansible and runs as a systemd service.

### Config location

```
/etc/promtail/config.yml
```

### Positions file

```
/var/lib/promtail/positions.yaml
```

---

## Loki

Loki receives logs from Promtail.

### Endpoint

```
http://<loki_host>:3100
```

### Health check

```bash
curl http://localhost:3100/ready
```

---

## Grafana Logs (Explore)

Logs can be queried in:

```
Grafana → Explore → Loki
```

### Example queries

#### All nginx logs

```
{job="nginx"}
```

#### Only errors (5xx)

```
{job="nginx"} | json | __error__="" | status >= 500
```

#### Application errors

```
{job="app"} |= "ERROR"
```

---

## Logs Dashboard

Dashboard:

```
Logs Overview
```

Panels:

| Panel            | Description       |
| ---------------- | ----------------- |
| Application Logs | app logs stream   |
| Nginx Logs       | nginx logs stream |

Uses Loki as datasource.

---

## Log-based Alerts

Alerts are configured via Grafana provisioning.

### Config file

```
ansible/roles/monitoring/files/grafana/provisioning/alerting/logs-rules.yml
```

---

## Implemented Log Alerts

| Alert              | Description                       |
| ------------------ | --------------------------------- |
| High 5xx rate      | >5 nginx 5xx errors in 5 minutes  |
| High 4xx rate      | >20 nginx 4xx errors in 5 minutes |
| Application errors | >3 ERROR logs in 5 minutes        |

---

## Example Alert Query

```
sum(count_over_time(
  {job="nginx"}
  | json
  | __error__=""
  | status >= 500
[5m]))
```

---

## How to Trigger Log Alerts

### Trigger 5xx errors

```bash
curl https://board.dobro10k2.ru/nonexistent
```

---

### Trigger application errors

```bash
docker stop <app_container>
```

or generate failing requests.

---

## Verification

1. Open Grafana → Explore → Loki
2. Run query:

```
{job="nginx"}
```

3. Verify logs are present
4. Trigger errors
5. Check:

* logs appear
* alerts move to Pending → Firing
* Telegram notification received

---

# Screenshots

### System Metrics

![System](assets/system-metrics.png)

### Application Metrics

![App](assets/application-metrics.png)

### HTTTP Metrics

![HTTP](assets/http-metrics.png)

### Nginx Metrics

![Nginx](assets/nginx-metrics.png)

### Status Page

![Status](assets/status-page.png)

### Prometheus Targets

![Targets](assets/prometheus-targets.png)

### Alert Fired

![Alert](assets/alert-fired.png)
![Alert](assets/alert-fired-telegram.png)

### 5xx Errors

![5xx](assets/5xx-errors.png)

### Prometheus 5xx Errors

![5xx](assets/prometheus-5xx-errors.png)

### Logs in Explore

![Log-explore](assets/logs-explore.png)

### Logs Dashboard

![Log-dash](assets/logs-dashboard.png)

### Log Alert Rules

![Log-alert](assets/logs-alerts.png)

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

