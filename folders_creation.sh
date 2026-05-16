#!/bin/bash
# =============================================
# Script de création de projet Infrawatch
# =============================================

set -e  # Arrêter en cas d'erreur

PROJECT_NAME="system_stats"
echo "🚀 Création de la structure du projet ${PROJECT_NAME}..."

# Création des répertoires
mkdir -p ${PROJECT_NAME}/{terraform,ansible/{inventory,playbooks,roles/{k3s,prometheus,grafana,argocd}},app/{src/collectors,tests},k8s/{helm/infrawatch-exporter/templates,argocd},grafana/dashboards,docs}

cd ${PROJECT_NAME}

# ====================== TERRAFORM ======================
cat > terraform/main.tf << 'EOF'
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Réseau Docker dédié
resource "docker_network" "infrawatch_net" {
  name   = "infrawatch-net"
  driver = "bridge"
}

# Nœuds simulés (pour K3s)
resource "docker_container" "k3s_node1" {
  name  = "k3s-node1"
  image = "rancher/k3s:latest"
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.infrawatch_net.name
  }
  command = ["server", "--disable=traefik"]
  privileged = true
}

# Ajouter d'autres nœuds si besoin
EOF

cat > terraform/network.tf << 'EOF'
# Réseau déjà créé dans main.tf
EOF

cat > terraform/variables.tf << 'EOF'
variable "environment" {
  description = "Environnement"
  type        = string
  default     = "dev"
}

variable "k3s_version" {
  description = "Version de K3s"
  type        = string
  default     = "latest"
}
EOF

cat > terraform/outputs.tf << 'EOF'
output "docker_network" {
  value = docker_network.infrawatch_net.name
}

output "k3s_node1_ip" {
  value = docker_container.k3s_node1.ip_address
}
EOF

# ====================== ANSIBLE ======================
cat > ansible/inventory/hosts.yml << 'EOF'
---
all:
  children:
    k3s_cluster:
      hosts:
        k3s-node1:
          ansible_host: "172.18.0.2"  # À adapter selon Docker
          node_ip: "{{ ansible_host }}"
      vars:
        ansible_user: root
        ansible_ssh_private_key_file: "~/.ssh/id_rsa"
EOF

cat > ansible/playbooks/01_k3s_install.yml << 'EOF'
---
- name: Installation K3s
  hosts: k3s_cluster
  become: yes
  roles:
    - k3s
EOF

cat > ansible/playbooks/02_monitoring.yml << 'EOF'
---
- name: Déploiement Monitoring
  hosts: k3s_cluster
  become: yes
  roles:
    - prometheus
    - grafana
EOF

cat > ansible/playbooks/03_argocd.yml << 'EOF'
---
- name: Installation ArgoCD
  hosts: k3s_cluster
  become: yes
  roles:
    - argocd
EOF

# Création des rôles (structure vide)
for role in k3s prometheus grafana argocd; do
  mkdir -p ansible/roles/${role}/{tasks,handlers,defaults,vars,meta,templates}
  touch ansible/roles/${role}/tasks/main.yml
done

# ====================== APPLICATION PYTHON ======================
cat > app/requirements.txt << 'EOF'
fastapi
uvicorn
prometheus-client
psutil
GPUtil
pynvml
EOF

cat > app/Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/
EXPOSE 8000

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

cat > app/src/main.py << 'EOF'
from fastapi import FastAPI
from src.exporter import start_metrics_server

app = FastAPI(title="InfraWatch Exporter")

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.get("/metrics")
async def metrics():
    # Prometheus exposition via /metrics
    from prometheus_client import generate_latest
    return generate_latest()

if __name__ == "__main__":
    start_metrics_server()
EOF

cat > app/src/exporter.py << 'EOF'
from prometheus_client import start_http_server, Gauge
import time
import psutil

# Métriques
cpu_usage = Gauge('cpu_usage_percent', 'CPU usage percent')
memory_usage = Gauge('memory_usage_percent', 'Memory usage percent')

def collect_metrics():
    cpu_usage.set(psutil.cpu_percent())
    memory_usage.set(psutil.virtual_memory().percent)

def start_metrics_server():
    start_http_server(8000)
    while True:
        collect_metrics()
        time.sleep(5)
EOF

# Création des collectors
for collector in cpu memory gpu disk network; do
  cat > app/src/collectors/${collector}.py << EOF
from prometheus_client import Gauge

${collector}_gauge = Gauge('${collector}_metric', '${collector} metric description')

def collect_${collector}():
    # À implémenter
    pass
EOF
done

# ====================== KUBERNETES ======================
cat > k8s/helm/infrawatch-exporter/Chart.yaml << 'EOF'
apiVersion: v2
name: infrawatch-exporter
description: InfraWatch custom Prometheus exporter
version: 0.1.0
appVersion: "1.0"
EOF

cat > k8s/helm/infrawatch-exporter/values.yaml << 'EOF'
replicaCount: 1
image:
  repository: infrawatch/exporter
  tag: latest
service:
  type: ClusterIP
  port: 8000
EOF

cat > k8s/helm/infrawatch-exporter/templates/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: infrawatch-exporter
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: infrawatch-exporter
  template:
    metadata:
      labels:
        app: infrawatch-exporter
    spec:
      containers:
      - name: exporter
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        ports:
        - containerPort: 8000
EOF

cat > k8s/helm/infrawatch-exporter/templates/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: infrawatch-exporter
spec:
  selector:
    app: infrawatch-exporter
  ports:
  - port: 8000
    targetPort: 8000
EOF

cat > k8s/argocd/app.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: infrawatch-exporter
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/VOTRE_USER/infrawatch.git
    targetRevision: HEAD
    path: k8s/helm/infrawatch-exporter
    helm:
      releaseName: infrawatch
  destination:
    server: https://kubernetes.default.svc
    namespace: monitoring
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

# ====================== AUTRES FICHIERS ======================
cat > grafana/dashboards/infrawatch.json << 'EOF'
{
  "title": "InfraWatch Dashboard",
  "uid": "infrawatch",
  "tags": ["infrawatch"]
}
EOF

cat > docs/architecture.md << 'EOF'
# Architecture InfraWatch

## Vue d'ensemble
- **Terraform** → Provisionne l'environnement Docker (nœuds K3s)
- **Ansible** → Configure K3s + stack observabilité
- **Python** → Custom Prometheus exporter
- **Kubernetes + ArgoCD** → GitOps

## Flux
1. `make infra-up` → Terraform
2. `make ansible` → Configuration
3. `make deploy` → Application via Helm + ArgoCD
EOF

cat > Makefile << 'EOF'
.PHONY: all infra-up infra-down ansible deploy clean

all: infra-up ansible deploy

infra-up:
	cd terraform && terraform init && terraform apply -auto-approve

infra-down:
	cd terraform && terraform destroy -auto-approve

ansible:
	ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/01_k3s_install.yml
	ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/02_monitoring.yml
	ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/03_argocd.yml

deploy:
	@echo "Déploiement via ArgoCD ou helm..."

clean:
	find . -name "*.tfstate*" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} +
EOF

cat > README.md << 'EOF'
# InfraWatch

Projet complet DevOps / Observabilité : Terraform + Ansible + Python Exporter + K3s + ArgoCD

## Installation rapide
```bash
make all
