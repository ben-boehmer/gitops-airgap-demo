# GitOps Demo – Kubernetes Deployment mit ArgoCD 🚀

Dieses Projekt demonstriert den Aufbau und Betrieb einer containerisierten Anwendung
unter Verwendung moderner GitOps-Prinzipien.

Der Fokus liegt auf:
- deklarativen Deployments mit ArgoCD
- Trennung von Anwendung, Deployment und Infrastruktur
- reproduzierbaren Umgebungen (kind)
- sicherem Secret-Handling mit Vault

## 🎯 Ziel des Projekts

Dieses Projekt demonstriert den Aufbau und Betrieb einer containerisierten Fullstack-Anwendung unter Berücksichtigung moderner DevOps- und GitOps-Prinzipien.

Der Fokus liegt auf:
- reproduzierbaren Deployments
- klarer Trennung von Infrastruktur und Anwendung
- automatisierbaren Workflows mit Shellscripten
- Runbooks für den täglichen Gebrauch

## 🏛️ Relevanz für die Verwaltung

Dieses Projekt zeigt, wie moderne Deployment-Strategien genutzt werden können, um:

- Systeme stabil und reproduzierbar zu betreiben
- Änderungen nachvollziehbar und revisionssicher zu machen
- manuelle Eingriffe zu minimieren

Dies ist besonders relevant für langfristig betriebene Systeme im öffentlichen Sektor.

## 🏗️ Architektur (vereinfacht)

Git Repository
   ↓
ArgoCD
   ↓
Kubernetes Cluster (kind / später produktiv)
   ↓
Hello-Service + PostgreSQL

## 🚀 Quickstart

### 1. Cluster erstellen
```bash
./scripts/create-cluster.sh
```

### 2. ArgoCD bootstrappen
```bash
./scripts/bootstrap-argocd.sh
```

### 🔁 3. GitOps Workflow

1. Änderungen werden im Git-Repository vorgenommen
2. ArgoCD erkennt Änderungen automatisch
3. Der Cluster wird an den gewünschten Zustand angepasst

Es findet kein manuelles Deployment statt.

## 🔐 Secret Management mit Vault

- Anwendung erhält nur minimal notwendige Rechte (Least Privilege)
- Secrets werden nicht im Repository gespeichert
- Integration erfolgt über External Secrets

Ziel: sichere und nachvollziehbare Konfiguration

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

## 📚 Learnings

- Umsetzung eines GitOps-Workflows mit ArgoCD
- Strukturierung von Repositories für GitOps
- Trennung von Anwendung, Deployment und Cluster-Zustand
- Integration von Secret-Management (Vault)
- Nutzung von kind für lokale Entwicklung

## 👨‍💻 Motivation

Ich interessiere mich besonders für den stabilen und nachvollziehbaren Betrieb von Software-Systemen. Dieses Projekt ist ein praktischer Schritt, um GitOps-Prinzipien nicht nur zu verstehen, sondern konkret umzusetzen.