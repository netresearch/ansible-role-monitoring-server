# Ansible role for a monitoring server

This Ansible role sets up Grafana and Prometheus docker containers using some dashboards of [stefanprodan's dockprom](https://github.com/stefanprodan/dockprom).

## Role Variables

| Name                      | Default           | Description                                                                                                                                      |
| ------------------------- | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `grafana_username`        | admin             | Admin username for Grafana                                                                                                                       |
| `grafana_password`        | admin             | Admin password for Grafana                                                                                                                       |
| `grafana_signup`          | false             | Allows the signup of users in Grafana                                                                                                            |
| `grafana_virtual_host`    | monitor.localhost | VIRTUAL_HOST variable for [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy)                                                          |
| `grafana_virtual_port`    | 3000              | VIRTUAL_PORT variable for [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy)                                                          |
| `letsencrypt_host`        | monitor.localhost | LETSENCRYPT_HOST variable for [JrCs/docker-letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion)  |
| `letsencrypt_email`       | monitor@localhost | LETSENCRYPT_EMAIL variable for [JrCs/docker-letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) |

## Example playbook

```yaml
---

- name: Monitoring Server
  hosts: maintenance
  vars:
    grafana_username: "admin"
    grafana_password: "admin"
    grafana_virtual_host: "monitoring.example.com"
    letsencrypt_host: "monitoring.example.com"
    letsencrypt_email: "webmaster@example.com"
  roles:
    - roles/external/ansible-role-monitoring-server
```

## Dashboard overview

### Docker Host Dashboard

The Docker Host Dashboard shows key metrics for monitoring the resource usage of your server:

* Server uptime, CPU idle percent, number of CPU cores, available memory, swap and storage
* System load average graph, running and blocked by IO processes graph, interrupts graph
* CPU usage graph by mode (guest, idle, iowait, irq, nice, softirq, steal, system, user)
* Memory usage graph by distribution (used, free, buffers, cached)
* IO usage graph (read Bps, read Bps and IO time)
* Network usage graph by device (inbound Bps, Outbound Bps)
* Swap usage and activity graphs

For storage and particularly Free Storage graph, you have to specify the fstype in grafana graph request.
You can find it in `files/grafana/dashboards/docker_containers.json`, at line 480 and 407 respectively:

```json
      "expr": "sum(node_filesystem_free_bytes{fstype=\"ext4\"})",
```

You can find right value for your system in Prometheus `http://<host-ip>:9090` launching this request :

```xl
node_filesystem_free_bytes
```

### Docker Containers Dashboard

The Docker Containers Dashboard shows key metrics for monitoring running containers:

* Total containers CPU load, memory and storage usage
* Running containers graph, system load graph, IO usage graph
* Container CPU usage graph
* Container memory usage graph
* Container cached memory usage graph
* Container network inbound usage graph
* Container network outbound usage graph

Note that this dashboard doesn't show the containers that are part of the monitoring stack.

### Monitor Services Dashboard

The Monitor Services Dashboard shows key metrics for monitoring the containers that make up the monitoring stack:

* Prometheus container uptime, monitoring stack total memory usage, Prometheus local storage memory chunks and series
* Container CPU usage graph
* Container memory usage graph
* Prometheus chunks to persist and persistence urgency graphs
* Prometheus chunks ops and checkpoint duration graphs
* Prometheus samples ingested rate, target scrapes and scrape duration graphs
* Prometheus HTTP requests graph

## Extending

### Adding notification channels

To add a notification channel, copy the `files/samples/notification-channel.json` into `files/grafana/notifiers/`, customize and rename it.

### Adding users

To add a user, copy the `files/samples/user.json` into `files/grafana/notifiers/`, customize and rename it.

### Adding alerts

I'm going to refer to [this article](https://cloud.ibm.com/docs/services/cloud-monitoring/alerts?topic=cloud-monitoring-config_alerts_grafana#step4_cag) by IBM's cloud.
