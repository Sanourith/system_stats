# system_stats

```txt
system_stats/
│
├── terraform/                  # Provisionne l'infra Docker locale
│   ├── main.tf                 # Containers Docker (simulant des nœuds)
│   ├── network.tf              # Réseau Docker dédié
│   ├── variables.tf
│   └── outputs.tf
│
├── ansible/                    # Configure et installe tout
│   ├── inventory/
│   │   └── hosts.yml           # Les nœuds K3s
│   ├── playbooks/
│   │   ├── 01_k3s_install.yml  # Installation K3s
│   │   ├── 02_monitoring.yml   # Déploiement stack Prometheus/Grafana
│   │   └── 03_argocd.yml       # Installation ArgoCD (GitOps)
│   └── roles/
│       ├── k3s/
│       ├── prometheus/
│       ├── grafana/
│       └── argocd/
│
├── app/                        # Ton application Python
│   ├── src/
│   │   ├── main.py             # Serveur HTTP exposant /metrics
│   │   ├── collectors/
│   │   │   ├── cpu.py          # Métriques CPU
│   │   │   ├── memory.py       # Métriques RAM
│   │   │   ├── gpu.py          # Métriques GPU (GPUtil/pynvml)
│   │   │   ├── disk.py         # Métriques disque
│   │   │   └── network.py      # Métriques réseau
│   │   └── exporter.py         # Prometheus exporter
│   ├── tests/
│   ├── Dockerfile
│   └── requirements.txt
│
├── k8s/                        # Manifests Kubernetes / Helm
│   ├── helm/
│   │   └── infrawatch-exporter/
│   │       ├── Chart.yaml
│   │       ├── values.yaml
│   │       └── templates/
│   │           ├── deployment.yaml
│   │           ├── service.yaml
│   │           └── servicemonitor.yaml  # Pour Prometheus Operator
│   └── argocd/
│       └── app.yaml            # Déclaration ArgoCD → GitOps
│
├── grafana/
│   └── dashboards/
│       └── infrawatch.json     # Dashboard prêt à l'import
│
├── docs/
│   └── architecture.md
│
├── Makefile                    # make up / make deploy / make destroy
└── README.md
```

## TODO LIST
```txt
make up
  └── Terraform → crée les containers Docker (nœuds simulés)
        └── Ansible → installe K3s + Prometheus + Grafana + ArgoCD
              └── ArgoCD → détecte k8s/ dans le repo Git
                    └── Déploie l'app Python (Helm chart)
                          └── Prometheus scrape /metrics toutes les 15s
                                └── Grafana affiche CPU/RAM/GPU en temps réel
                                      └── Alertmanager → notif si CPU > 80%
```
