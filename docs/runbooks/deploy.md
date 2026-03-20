# Deployment – hello-service (dev)

## Normaler Deploy-Flow

1. Commit auf `main`
2. Script baut Docker-Image und aktualisiert Helm values und läd Image in den Kind Cluster mit Eingabe von neuem ImageTag

    ```console
    gitops-airgap-demo/scripts$ ./load-images.sh
    ```
 
3. Image Tag in gitops-airgap-demo/apps/hello-service/chart/values.yaml anpassen
4. Argo CD synchronisiert automatisch

## Wichtige Punkte
- Namespace: demo
- ArgoCD App: hello-service
- Helm Chart Pfad: apps/hello-service/chart

## Checks nach dem Deploy
- ArgoCD App Status = Healthy
- Pod läuft
- Service erreichbar auf Port 8081
- Kontrolle für Secrets: Unter /secret sollte "SECRET_VALUE=Super_geheim!" angezeigt werden

## Work in Progress
- Image Tag automatisch in Helm (Metadaten: Chart.yaml, Konfiguration:values.yaml)  einfügen
