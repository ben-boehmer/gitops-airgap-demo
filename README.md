# Projektstruktur – Überblick

Dieses Repository folgt einer GitOps-orientierten Struktur, die **Anwendungscode**,
**Deployment-Templates** und **umgebungsspezifischen Zustand** klar voneinander trennt.

Der Aufbau ist auf lokale Entwicklung (kind), ArgoCD-basierte GitOps-Deployments
und gute Nachvollziehbarkeit ausgelegt. Es wurde auch **Vault** mit eingeabeitet

---

## Gesamtstruktur
```
├── apps 
├── clusters
├── docs
├── kind
└── scripts
```

Jedes Verzeichnis hat eine klar abgegrenzte Verantwortung, die im Folgenden
beschrieben wird.

---

## `apps/` – Anwendungscode & Deployment-Templates

```
apps/
  └── hello-service
      ├── app
      └── chart
```

### `apps/hello-service/app`
Enthält die **eigentliche Anwendung** sowie alles, was zum Bauen des Container-Images
benötigt wird.

- `Dockerfile` – Definition des Container-Images
- `app.py` – Einstiegspunkt der Anwendung
- `requirements.txt` – Python-Abhängigkeiten
- `hello-policy.hcl` – Minimale Vault-Policy für diesen Service (Least Privilege)

Dieses Verzeichnis ist bewusst frei von Kubernetes- oder GitOps-spezifischer Logik.

---

### `apps/hello-service/chart`
Helm-Chart zur Auslieferung der Anwendung in Kubernetes.

```
chart/
  ├── Chart.yaml
  ├── templates
  ├── values.yaml
  ├── note.txt
  └── apps/hello-service/chart/templates
```

- `Chart.yaml` – Metadaten des Helm-Charts (Identität, Versionierung, Abhängigkeiten)
- `values.yaml` – Laufzeitkonfiguration (Image-Tag, Replikate, etc.)
- `templates/` – Parametrisierte Kubernetes-Manifeste:
  - `deployment.yaml`
  - `service.yaml`
  - `serviceaccount.yaml`
  - `externalsecret.yaml`
  - `secretstore.yaml`

Das verschachtelte `apps/hello-service/chart/templates` spiegelt eine GitOps-freundliche
Struktur wider, in der Charts sauber von ArgoCD referenziert und kombiniert werden können.

---

## `clusters/` – Umgebungsbezogene GitOps-Konfiguration

```
clusters/
  ├── dev
  └── postgresql-app
```

Dieses Verzeichnis beschreibt **was in welchem Cluster läuft**, nicht wie Anwendungen
gebaut werden.

---

### `clusters/dev`
Entwicklungsumgebung, verwaltet durch ArgoCD.

```
dev/
  ├── argocd-apps
  ├── artifactory
  └── namespaces
```


- `argocd-apps/hello-service-app.yaml`  
  ArgoCD-`Application`, die auf das Helm-Chart von *hello-service* zeigt
- `artifactory/`  
  GitOps-Definition für Artifactory (Namespace, Application, Values)
- `namespaces/`  
  Namespace-Definitionen für den Dev-Cluster

---

### `clusters/postgresql-app`
Eigenständige GitOps-Definition für eine PostgreSQL-Anwendung.

- `application.yaml` – ArgoCD-Application
- `values.yaml` – Umgebungsabhängige Konfiguration

---

## `docs/` – Dokumentation & Runbooks

```
docs/
└── runbooks
    ├── deploy.md
    ├── rollback.md
    └── troubleshooting.md
```

Betriebsdokumentation für Menschen:
- Deploy-Prozesse
- Rollback-Strategien
- typische Fehlerbilder und deren Behebung

---

## `kind/` – Lokale Cluster-Konfiguration

```
kind/
  └── kind-config.yaml
```

Konfiguration für den lokalen kind-Cluster, der zur Simulation einer realistischen
Kubernetes-Umgebung in der Entwicklung genutzt wird.

---

## `scripts/` – Automatisierung & Bootstrap-Helfer

```
scripts/
  ├── bootstrap-argocd.sh
  ├── create-cluster.sh
  └── load-images.sh
```

Hilfsskripte für lokale Entwicklung und Demos:

- `create-cluster.sh` – Erstellt einen lokalen kind-Cluster
- `bootstrap-argocd.sh` – Installiert und bootstrapped ArgoCD
- `load-images.sh` – Baut Images lokal und lädt sie explizit in kind  
  (Simulation eines air-gapped Workflows)

Diese Skripte sind bewusst **nicht Teil des GitOps-Zustands**.

---

## Designprinzipien

- **Klare Trennung der Verantwortlichkeiten**  
  Anwendungscode, Deployment-Templates und Cluster-Zustand sind strikt getrennt.
- **GitOps-first**  
  Cluster gleichen ihren gewünschten Zustand ausschließlich aus Git ab.
- **Lokale Entwicklung ≠ Produktion**  
  Skripte und kind-Konfiguration unterstützen schnelle Iteration, ohne GitOps-Flows
  zu verwässern.
- **Explizit statt implizit**  
  Die Struktur ist auf Lesbarkeit und Reviewbarkeit ausgelegt, nicht auf „Magie“.

---

