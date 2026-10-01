# ft_service_new

This project is a Kubernetes-based service stack built to deploy a small web hosting environment using multiple containers. It groups together common web and monitoring services into a single orchestration setup, managed with `kubectl` and `kustomize`.

The goal is to provide a realistic infrastructure where a website, database, admin panel, file transfer service, and monitoring tools can run together inside a local cluster.

## Project overview

The stack includes:

- Nginx: main entry point and reverse proxy / public-facing web service
- WordPress: blog and content platform
- MySQL: database backend for WordPress
- phpMyAdmin: web interface for managing MySQL
- FTPS: secure file transfer service
- InfluxDB: time-series database for metrics
- Telegraf: agent collecting system and service metrics
- Grafana: visualization dashboard for monitoring data

This is a classic `ft_services`-style deployment: several independent services are packaged as Docker images and deployed together in a Kubernetes cluster, with MetalLB providing external IPs for local access.

## Architecture

```text
                 ┌───────────────────────┐
                 │        NGINX          │
                 │  public entry point   │
                 └──────────┬────────────┘
                            │
          ┌─────────────────┼──────────────────┐
          │                 │                  │
          ▼                 ▼                  ▼
   ┌──────────────┐   ┌──────────────┐   ┌────────────────┐
   │   WordPress  │   │ phpMyAdmin   │   │      FTPS      │
   │   :5050      │   │   :5000      │   │  :21 / :20    │
   └──────┬───────┘   └──────┬───────┘   └──────┬─────────┘
          │                   │                   │
          ▼                   │                   │
   ┌──────────────┐          │                   │
   │    MySQL     │          │                   │
   │    :3306     │          │                   │
   └──────────────┘          │                   │
                            │
                            ▼
                    ┌──────────────┐
                    │  Telegraf    │
                    │  metrics     │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │ InfluxDB     │
                    │   :8086      │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   Grafana    │
                    │   :3000      │
                    └──────────────┘
```

## Folder structure

```text
ft_service_new/
├── setup.sh                 # Cluster bootstrap and image build script
├── srcs/
│   ├── kustomization.yaml   # Main kustomize entry point
│   ├── install_dir/
│   │   └── config.yaml      # MetalLB address pool configuration
│   ├── nginx.yaml           # Nginx deployment + service
│   ├── wordpress.yaml       # WordPress deployment + service
│   ├── mysql.yaml           # MySQL deployment + service
│   ├── phpmyadmin.yaml      # phpMyAdmin deployment + service
│   ├── ftps.yaml            # FTPS deployment + service
│   ├── influxdb.yaml       # InfluxDB deployment + service
│   ├── telegraf.yaml        # Telegraf deployment + RBAC
│   ├── grafana.yaml        # Grafana deployment + service
│   ├── nginx/              # Nginx Docker image files
│   ├── wordpress/          # WordPress Docker image files
│   ├── mysql/              # MySQL Docker image files
│   ├── phpmyadmin/         # phpMyAdmin Docker image files
│   ├── ftps/               # FTPS Docker image files
│   ├── influxdb/           # InfluxDB Docker image files
│   ├── telegraf/           # Telegraf Docker image files
│   └── grafana/            # Grafana Docker image files
└── README.md
```

## Main configuration

The setup is orchestrated by:

- `setup.sh`: starts Minikube, configures MetalLB, builds all Docker images, and applies the Kubernetes manifests.
- `srcs/kustomization.yaml`: declares the resources to deploy.
- `srcs/install_dir/config.yaml`: defines the external IP ranges used by MetalLB.

MetalLB is configured with multiple address pools:

- default pool: `172.17.0.40-172.17.0.50`
- WordPress pool: `172.17.0.60-172.17.0.60`
- FTPS pool: `172.17.0.65-172.17.0.65`

This allows each service to receive its own accessible IP in the local network.

## Requirements

Before running the project, install:

- Docker
- Minikube
- kubectl

Make sure the Docker daemon is running and that your local environment is able to launch a Kubernetes cluster.

## Quick start

Run the bootstrap script from the project root:

```bash
chmod +x setup.sh
./setup.sh 1
```

The `1` argument is used for the first setup so the script can generate the required secret and initialize the cluster correctly.

After that, the script:

1. starts Minikube with Docker as the driver,
2. configures kube-proxy for ARP compatibility,
3. installs MetalLB,
4. builds all Docker images for the services,
5. applies the Kubernetes manifests,
6. opens the Minikube dashboard.

## Services and access

Once the cluster is running, the services are exposed through Kubernetes LoadBalancer services.

Typical access points are:

- Nginx: HTTP on port `80`, HTTPS on port `443`, SSH on port `22`
- WordPress: port `5050`
- phpMyAdmin: port `5000`
- Grafana: port `3000`
- FTPS: ports `20`, `21`, and passive port `30025`
- MySQL: internal cluster service on port `3306`
- InfluxDB: internal service on port `8086`

These ports are not always public on the host by default; they are usually exposed through the Minikube/MetalLB environment.

## Why this project matters

This project is a good example of how to:

- package multiple services as separate containers,
- deploy them together in Kubernetes,
- connect them through internal cluster networking,
- expose selected services through a load balancer,
- set up monitoring with Telegraf, InfluxDB, and Grafana,
- configure a small hosting environment similar to a lightweight production stack.

## Useful commands

Check cluster status:

```bash
kubectl get pods
kubectl get services
```

Open the dashboard:

```bash
minikube dashboard
```

Rebuild images after changes:

```bash
docker build -t nginx-alpine ./srcs/nginx/
docker build -t ftps_alpine ./srcs/ftps/
docker build -t mysql_alpine ./srcs/mysql/
docker build -t wordpress_alpine ./srcs/wordpress/
docker build -t phpmyadmin_alpine ./srcs/phpmyadmin/
docker build -t influxdb_alpine ./srcs/influxdb/
docker build -t telegraf_alpine ./srcs/telegraf/
docker build -t grafana_alpine ./srcs/grafana/
```

Apply manifests again:

```bash
kubectl apply -k ./srcs/
```

## Conclusion

`ft_service_new` is a compact Kubernetes deployment that combines a web application stack with observability tools in a single local environment. It is ideal for learning container orchestration, service communication, external exposure, and infrastructure automation.
