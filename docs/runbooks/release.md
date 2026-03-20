# Deployment Runbook -- hello-service (dev)

## Überblick

Dieses Runbook beschreibt den Deployment‑Prozess für den
**hello-service** in der Entwicklungsumgebung.

Der Workflow basiert auf:

-   **GitOps mit ArgoCD**
-   einem **lokalen kind‑Cluster**
-   einem automatisierten **Release‑Skript (`release.sh`)** zu finden unter /gitops-airgap-demo/scripts

Das Skript automatisiert Build, Versionierung, Konfigurationsupdate und
Deployment.

------------------------------------------------------------------------

# Normaler Deploy‑Flow

## 1. Änderungen committen

Änderungen am Code werden zunächst committed und gepusht.

``` bash
git add .
git commit -m "Feature oder Fix beschreiben"
git push
```

Der Zielbranch ist:

    main

------------------------------------------------------------------------

## 2. Release‑Skript ausführen

Ins Skript‑Verzeichnis wechseln:

``` bash
cd gitops-airgap-demo/scripts
```

Standard‑Release starten:

``` bash
./release.sh
```

Standardmäßig wird die **Patch-Version erhöht**.

Beispiele:

Patch-Version:

``` bash
./release.sh
```

Minor-Version:

``` bash
./release.sh --minor
```

Major-Version:

``` bash
./release.sh --major
```

------------------------------------------------------------------------

# Automatisierte Schritte des Skripts

Das Skript führt automatisch folgende Aktionen aus:

1.  aktuelle Version aus `.last_image_tag` lesen
2.  Version erhöhen (patch / minor / major)
3.  aktuellen Git‑Commit‑Hash ermitteln
4.  Docker‑Image bauen
5.  Image in den lokalen **kind‑Cluster** laden
6.  bestehende `values.yaml` sichern
7.  `image.tag` in der Helm‑Konfiguration aktualisieren
8.  Änderungen committen
9.  Änderungen ins Git‑Repository pushen

------------------------------------------------------------------------

# Image‑Tag Format

Der erzeugte Tag besteht aus:

    VERSION-GIT_HASH

Beispiel:

    0.1.2-a1b2c3d

------------------------------------------------------------------------

# Sicherung der alten values.yaml

Vor jeder Änderung wird die bestehende `values.yaml` gesichert.

Speicherort:

    apps/hello-service/chart/old_values_yamls

Beispiele:

    values_0.1.1.yaml
    values_0.1.2-a1b2c3d.yaml

Der Dateiname entspricht dem vorherigen Wert von:

    image.tag

------------------------------------------------------------------------

# ArgoCD Deployment

Nach dem Push:

1.  ArgoCD erkennt die Änderung im Repository
2.  ArgoCD synchronisiert automatisch die Application
3.  Neue Pods werden gestartet

------------------------------------------------------------------------

# Wichtige Konfiguration

Namespace:

    demo

ArgoCD Application:

    hello-service

Helm Chart Pfad:

    apps/hello-service/chart

Helm Values Datei:

    apps/hello-service/chart/values.yaml

------------------------------------------------------------------------

# Versionslogik

Die Versionierung folgt **Semantic Versioning**:

    MAJOR.MINOR.PATCH

Beispiele:

Patch:

    1.2.3 → 1.2.4

Minor:

    1.2.3 → 1.3.0

Major:

    1.2.3 → 2.0.0

Der Git‑Hash wird zusätzlich an den Image‑Tag angehängt.

------------------------------------------------------------------------

# Checks nach dem Deploy

## ArgoCD Status

Der Status der Application sollte sein:

    Healthy

------------------------------------------------------------------------

## Pods prüfen

``` bash
kubectl get pods -n demo
```

------------------------------------------------------------------------

## Service testen

    http://localhost:8081

------------------------------------------------------------------------

## Secrets prüfen

    http://localhost:8081/secret

Erwartete Ausgabe:

    SECRET_VALUE=Super_geheim!

------------------------------------------------------------------------

# Optional: Release ohne Push

Zum Testen kann der Push übersprungen werden:

``` bash
./release.sh --no-push
```

Der Commit wird lokal erstellt, aber nicht zum Remote‑Repository
übertragen.

------------------------------------------------------------------------

# Hinweis zum lokalen Cluster

Images werden lokal gebaut und anschließend direkt in den **kind‑Cluster
geladen**.

Es wird **keine externe Container‑Registry verwendet**.

Dieses Setup simuliert einen **Air‑Gap‑Workflow**.

------------------------------------------------------------------------

# Rollback

Ein Rollback kann durchgeführt werden, indem eine vorherige
`values.yaml` wiederhergestellt wird.

Beispiel:

``` bash
cp apps/hello-service/chart/old_values_yamls/values_0.1.1.yaml apps/hello-service/chart/values.yaml
```

Danach:

``` bash
git add apps/hello-service/chart/values.yaml
git commit -m "Rollback auf Version 0.1.1"
git push
```

ArgoCD synchronisiert anschließend automatisch auf die vorherige
Version.
